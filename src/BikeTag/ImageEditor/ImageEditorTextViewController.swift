//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public protocol VAlignTextViewDelegate: AnyObject {
    func textViewDidComplete()
}

// MARK: -

private class VAlignTextView: UITextView {
    fileprivate weak var textViewDelegate: VAlignTextViewDelegate?

    enum Alignment: String {
        case top
        case center
        case bottom
    }

    private let alignment: Alignment

    @objc override public var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                updateInsets()
            }
        }
    }

    @objc override public var frame: CGRect {
        didSet {
            if oldValue != frame {
                updateInsets()
            }
        }
    }

    public init(alignment: Alignment) {
        self.alignment = alignment

        super.init(frame: .zero, textContainer: nil)

        addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }

    @available(*, unavailable, message: "use other init() instead.")
    public required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }

    deinit {
        self.removeObserver(self, forKeyPath: "contentSize")
    }

    private func updateInsets() {
        let topOffset: CGFloat
        switch alignment {
        case .top:
            topOffset = 0
        case .center:
            topOffset = max(0, (frame.height - contentSize.height) * 0.5)
        case .bottom:
            topOffset = max(0, frame.height - contentSize.height)
        }
        contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: 0, right: 0)
    }

    override open func observeValue(forKeyPath _: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        updateInsets()
    }

    // MARK: - Key Commands

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\r", modifierFlags: .command, action: #selector(modifiedReturnPressed(sender:)), discoverabilityTitle: "Add Text"),
            UIKeyCommand(input: "\r", modifierFlags: .alternate, action: #selector(modifiedReturnPressed(sender:)), discoverabilityTitle: "Add Text"),
        ]
    }

    @objc
    public func modifiedReturnPressed(sender _: UIKeyCommand) {
        Logger.trace()

        textViewDelegate?.textViewDidComplete()
    }
}

// MARK: -

@objc
public protocol ImageEditorTextViewControllerDelegate: AnyObject {
    func textEditDidComplete(textItem: ImageEditorTextItem)
    func textEditDidDelete(textItem: ImageEditorTextItem)
    func textEditDidCancel()
}

// MARK: -

// A view for editing text item in image editor.
public class ImageEditorTextViewController: BaseViewController, VAlignTextViewDelegate {
    private weak var delegate: ImageEditorTextViewControllerDelegate?

    private let textItem: ImageEditorTextItem

    private let isNewItem: Bool

    private let maxTextWidthPoints: CGFloat

    private let textView = VAlignTextView(alignment: .center)

    private let model: ImageEditorModel

    private let canvasView: ImageEditorCanvasView

    private let paletteView: ImageEditorPaletteView

    init(delegate: ImageEditorTextViewControllerDelegate,
         model: ImageEditorModel,
         textItem: ImageEditorTextItem,
         isNewItem: Bool,
         maxTextWidthPoints: CGFloat) {
        self.delegate = delegate
        self.model = model
        self.textItem = textItem
        self.isNewItem = isNewItem
        self.maxTextWidthPoints = maxTextWidthPoints
        canvasView = ImageEditorCanvasView(model: model,
                                           itemIdsToIgnore: [textItem.itemId])
        paletteView = ImageEditorPaletteView(currentColor: textItem.color)

        super.init(nibName: nil, bundle: nil)

        textView.textViewDelegate = self
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.becomeFirstResponder()

        view.layoutSubviews()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textView.becomeFirstResponder()

        view.layoutSubviews()
    }

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .black
        view.isOpaque = true

        canvasView.configureSubviews()
        view.addSubview(canvasView)
        canvasView.autoPinEdgesToSuperviewEdges()

        let tintView = UIView()
        tintView.backgroundColor = UIColor(white: 0, alpha: 0.33)
        tintView.isOpaque = false
        view.addSubview(tintView)
        tintView.autoPinEdgesToSuperviewEdges()
        tintView.layer.opacity = 0
        UIView.animate(withDuration: 0.25, animations: {
            tintView.layer.opacity = 1
        }, completion: { _ in
            tintView.layer.opacity = 1
        })

        configureTextView()

        view.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)

        view.addSubview(textView)
        textView.autoPinEdge(toSuperviewMargin: .top)
        textView.autoAlignAxis(toSuperviewAxis: .vertical)
        textView.autoPinEdge(toSuperviewMargin: .bottom)

        paletteView.delegate = self
        view.addSubview(paletteView)
        paletteView.autoAlignAxis(.horizontal, toSameAxisOf: textView)
        paletteView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)
        // This will determine the text view's size.
        paletteView.autoPinEdge(.leading, to: .trailing, of: textView, withOffset: 0)

        let pinchGestureRecognizer = ImageEditorPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGestureRecognizer.referenceView = view
        view.addGestureRecognizer(pinchGestureRecognizer)

        updateNavigationBar()
    }

    private func configureTextView() {
        textView.text = textItem.text
        textView.font = textItem.font
        textView.textColor = textItem.color.color

        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.isOpaque = false
        // We use a white cursor since we use a dark background.
        textView.tintColor = .white
        // TODO: Limit the size of the text?
        // textView.delegate = self
        textView.isScrollEnabled = true
        textView.scrollsToTop = false
        textView.isUserInteractionEnabled = true
        textView.textAlignment = .center
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = .zero
    }

    private func updateNavigationBar() {
        let undoButton = navigationBarButton(imageName: "image_editor_undo",
                                             selector: #selector(didTapUndo(sender:)))
        let doneButton = navigationBarButton(imageName: "image_editor_checkmark_full",
                                             selector: #selector(didTapDone(sender:)))

        let navigationBarItems = [undoButton, doneButton]
        updateNavigationBar(navigationBarItems: navigationBarItems)
    }

    // MARK: - Pinch Gesture

    private var pinchFontStart: UIFont?

    @objc
    public func handlePinchGesture(_ gestureRecognizer: ImageEditorPinchGestureRecognizer) {
        assert(Thread.isMainThread)

        switch gestureRecognizer.state {
        case .began:
            pinchFontStart = textView.font
        case .changed, .ended:
            guard let pinchFontStart = pinchFontStart else {
                return
            }
            var pointSize: CGFloat = pinchFontStart.pointSize
            if gestureRecognizer.pinchStateLast.distance > 0 {
                pointSize *= gestureRecognizer.pinchStateLast.distance / gestureRecognizer.pinchStateStart.distance
            }
            let minPointSize: CGFloat = 12
            let maxPointSize: CGFloat = 64
            pointSize = max(minPointSize, min(maxPointSize, pointSize))
            let font = pinchFontStart.withSize(pointSize)
            textView.font = font
        default:
            pinchFontStart = nil
        }
    }

    // MARK: - Events

    @objc func didTapUndo(sender _: UIButton) {
        Logger.trace()

        delegate?.textEditDidCancel()

        dismiss(animated: false) {
            // Do nothing.
        }
    }

    @objc func didTapDone(sender _: UIButton) {
        Logger.trace()

        completeAndDismiss()
    }

    private func completeAndDismiss() {
        // TODO:
        // textView.acceptAutocorrectSuggestion()

        var newTextItem = textItem

        if isNewItem {
            let view = canvasView.gestureReferenceView
            let viewBounds = view.bounds

            // Ensure continuity of the new text item's location
            // with its apparent location in this text editor.
            let locationInView = view.convert(textView.bounds.center, from: textView).clamp(view.bounds)
            let textCenterImageUnit = ImageEditorCanvasView.locationImageUnit(forLocationInView: locationInView,
                                                                              viewBounds: viewBounds,
                                                                              model: model,
                                                                              transform: model.currentTransform())

            // Same, but for size.
            let imageFrame = ImageEditorCanvasView.imageFrame(forViewSize: viewBounds.size,
                                                              imageSize: model.srcImageSizePixels,
                                                              transform: model.currentTransform())
            let unitWidth = textView.frame.width / imageFrame.width
            newTextItem = textItem.copy(unitCenter: textCenterImageUnit).copy(unitWidth: unitWidth)
        }

        var font = textItem.font
        if let newFont = textView.font {
            font = newFont
        } else {
            assertionFailure("Missing font.")
        }
        newTextItem = newTextItem.copy(font: font)

        // FIXME:
        // guard let text = textView.text?.ows_stripped(),
        guard let text = textView.text, text.count > 0 else {
            delegate?.textEditDidDelete(textItem: textItem)

            dismiss(animated: false) {
                // Do nothing.
            }

            return
        }

        newTextItem = newTextItem.copy(withText: text, color: paletteView.selectedValue)

        // Hide the text view immediately to avoid animation glitches in the dismiss transition.
        textView.isHidden = true

        if textItem == newTextItem {
            // No changes were made.  Cancel to avoid dirtying the undo stack.
            delegate?.textEditDidCancel()
        } else {
            delegate?.textEditDidComplete(textItem: newTextItem)
        }

        dismiss(animated: false) {
            // Do nothing.
        }
    }

    // MARK: - VAlignTextViewDelegate

    public func textViewDidComplete() {
        completeAndDismiss()
    }
}

// MARK: -

extension ImageEditorTextViewController: ImageEditorPaletteViewDelegate {
    public func selectedColorDidChange() {
        textView.textColor = paletteView.selectedValue.color
    }
}
