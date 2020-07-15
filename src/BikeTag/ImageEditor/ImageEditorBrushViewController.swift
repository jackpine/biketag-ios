//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import UIKit

@objc
public protocol ImageEditorBrushViewControllerDelegate: AnyObject {
    func brushDidComplete(currentColor: ImageEditorColor)
}

// MARK: -

public class ImageEditorBrushViewController: BaseViewController {
    private weak var delegate: ImageEditorBrushViewControllerDelegate?

    private let model: ImageEditorModel

    private let canvasView: ImageEditorCanvasView

    private let paletteView: ImageEditorPaletteView

    // We only want to let users undo changes made in this view.
    // So we snapshot any older "operation id" and prevent
    // users from undoing it.
    private let firstUndoOperationId: String?

    init(delegate: ImageEditorBrushViewControllerDelegate,
         model: ImageEditorModel,
         currentColor: ImageEditorColor) {
        self.delegate = delegate
        self.model = model
        canvasView = ImageEditorCanvasView(model: model)
        paletteView = ImageEditorPaletteView(currentColor: currentColor)
        firstUndoOperationId = model.currentUndoOperationId()

        super.init(nibName: nil, bundle: nil)

        model.add(observer: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .black
        view.isOpaque = true

        canvasView.configureSubviews()
        view.addSubview(canvasView)
        canvasView.autoPinEdgesToSuperviewEdges()

        paletteView.delegate = self
        view.addSubview(paletteView)
        paletteView.autoAlignAxis(toSuperviewAxis: .horizontal)
        paletteView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 0)

        view.isUserInteractionEnabled = true

        let brushGestureRecognizer = ImageEditorPanGestureRecognizer(target: self, action: #selector(handleBrushGesture(_:)))
        brushGestureRecognizer.maximumNumberOfTouches = 1
        brushGestureRecognizer.referenceView = canvasView.gestureReferenceView
        brushGestureRecognizer.delegate = self
        view.addGestureRecognizer(brushGestureRecognizer)

        updateNavigationBar()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.layoutSubviews()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutSubviews()
    }

    private func updateNavigationBar() {
        // Hide controls during stroke.
        let hasStroke = currentStroke != nil
        guard !hasStroke else {
            updateNavigationBar(navigationBarItems: [])
            return
        }

        let undoButton = navigationBarButton(imageName: "image_editor_undo",
                                             selector: #selector(didTapUndo(sender:)))
        let doneButton = navigationBarButton(imageName: "image_editor_checkmark_full",
                                             selector: #selector(didTapDone(sender:)))

        // Prevent users from undo any changes made before entering the view.
        let canUndo = model.canUndo() && firstUndoOperationId != model.currentUndoOperationId()
        var navigationBarItems = [UIView]()
        if canUndo {
            navigationBarItems = [undoButton, doneButton]
        } else {
            navigationBarItems = [doneButton]
        }
        updateNavigationBar(navigationBarItems: navigationBarItems)
    }

    private func updateControls() {
        // Hide controls during stroke.
        let hasStroke = currentStroke != nil
        paletteView.isHidden = hasStroke
    }

    // MARK: - Actions

    @objc func didTapUndo(sender _: UIButton) {
        Logger.verbose("")
        guard model.canUndo() else {
            assertionFailure("Can't undo.")
            return
        }
        model.undo()
    }

    @objc func didTapDone(sender _: UIButton) {
        Logger.verbose("")

        completeAndDismiss()
    }

    private func completeAndDismiss() {
        delegate?.brushDidComplete(currentColor: paletteView.selectedValue)

        dismiss(animated: false) {
            // Do nothing.
        }
    }

    // MARK: - Brush

    // These properties are non-empty while drawing a stroke.
    private var currentStroke: ImageEditorStrokeItem? {
        didSet {
            updateControls()
            updateNavigationBar()
        }
    }

    private var currentStrokeSamples = [ImageEditorStrokeItem.StrokeSample]()

    @objc
    public func handleBrushGesture(_ gestureRecognizer: ImageEditorPanGestureRecognizer) {
        assert(Thread.isMainThread)

        let removeCurrentStroke = {
            if let stroke = self.currentStroke {
                self.model.remove(item: stroke)
            }
            self.currentStroke = nil
            self.currentStrokeSamples.removeAll()
        }
        let tryToAppendStrokeSample = { (locationInView: CGPoint) in
            let view = self.canvasView.gestureReferenceView
            let viewBounds = view.bounds
            let newSample = ImageEditorCanvasView.locationImageUnit(forLocationInView: locationInView,
                                                                    viewBounds: viewBounds,
                                                                    model: self.model,
                                                                    transform: self.model.currentTransform())

            if let prevSample = self.currentStrokeSamples.last,
                prevSample == newSample {
                // Ignore duplicate samples.
                return
            }
            self.currentStrokeSamples.append(newSample)
        }

        let strokeColor = paletteView.selectedValue.color
        let unitStrokeWidth = ImageEditorStrokeItem.defaultUnitStrokeWidth() / model.currentTransform().scaling

        switch gestureRecognizer.state {
        case .began:
            removeCurrentStroke()

            // Apply the location history of the gesture so that the stroke reflects
            // the touch's movement before the gesture recognized.
            for location in gestureRecognizer.locationHistory {
                tryToAppendStrokeSample(location)
            }

            let locationInView = gestureRecognizer.location(in: canvasView.gestureReferenceView)
            tryToAppendStrokeSample(locationInView)

            let stroke = ImageEditorStrokeItem(color: strokeColor, unitSamples: currentStrokeSamples, unitStrokeWidth: unitStrokeWidth)
            model.append(item: stroke)
            currentStroke = stroke

        case .changed, .ended:
            let locationInView = gestureRecognizer.location(in: canvasView.gestureReferenceView)
            tryToAppendStrokeSample(locationInView)

            guard let lastStroke = currentStroke else {
                assertionFailure("Missing last stroke.")
                removeCurrentStroke()
                return
            }

            // Model items are immutable; we _replace_ the
            // stroke item rather than modify it.
            let stroke = ImageEditorStrokeItem(itemId: lastStroke.itemId, color: strokeColor, unitSamples: currentStrokeSamples, unitStrokeWidth: unitStrokeWidth)
            model.replace(item: stroke, suppressUndo: true)

            if gestureRecognizer.state == .ended {
                currentStroke = nil
                currentStrokeSamples.removeAll()
            } else {
                currentStroke = stroke
            }
        default:
            removeCurrentStroke()
        }
    }
}

// MARK: -

extension ImageEditorBrushViewController: ImageEditorModelObserver {
    public func imageEditorModelDidChange(before _: ImageEditorContents,
                                          after _: ImageEditorContents) {
        updateNavigationBar()
    }

    public func imageEditorModelDidChange(changedItemIds _: [String]) {
        updateNavigationBar()
    }
}

// MARK: -

extension ImageEditorBrushViewController: ImageEditorPaletteViewDelegate {
    public func selectedColorDidChange() {
        // TODO:
    }
}

// MARK: -

extension ImageEditorBrushViewController: UIGestureRecognizerDelegate {
    @objc public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Ignore touches that begin inside the palette.
        let location = touch.location(in: paletteView)
        return !paletteView.bounds.contains(location)
    }
}
