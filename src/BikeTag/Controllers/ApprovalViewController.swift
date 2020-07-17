//
//  ApprovalViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/15/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

protocol ApprovalDelegate: AnyObject {
    var approvalButtonText: String { get }
    func approvalView(_ approvalViewController: ApprovalViewController, didApproveImageData imageData: Data, location: CLLocation, errorCallback: @escaping (Error) -> Void)
}

extension ApprovalViewController: ImageEditorViewDelegate {
    func imageEditor(presentFullScreenView viewController: UIViewController, isTransparent _: Bool) {
        let navController = BaseNavController(rootViewController: viewController)
        // MJK: This is clobberedd by setting the modalPresentationStyle later....
        // navController.modalPresentationStyle = (isTransparent
        //     ? .overFullScreen
        //     : .fullScreen)
        // navigationController.ows_prefersStatusBarHidden = true

//        if let navigationBar = navigationController.navigationBar as? OWSNavigationBar {
//            navigationBar.switchToStyle(.clear)
//        } else {
//            owsFailDebug("navigationBar was nil or unexpected class")
//        }

        navController.modalPresentationStyle = .overCurrentContext
        present(navController, animated: false)
    }

    func imageEditorUpdateNavigationBar() {
        // I don't think we have to do anything here...
        updateImageEditorToolbar()
    }

    func imageEditorUpdateControls() {
        // I don't think we have to do anything here...
        // maybe eventually show/hide the "hint" text field?
        updateImageEditorToolbar()
    }
}

class ApprovalViewController: BaseViewController {
    var game: Game?
    var originalImageData: Data!
    var location: CLLocation!
    var imageEditorModel: ImageEditorModel!

    weak var approvalDelegate: ApprovalDelegate?

    class func create(imageData: Data, location: CLLocation, game: Game?) -> ApprovalViewController {
        let vc = ApprovalViewController()
        vc.game = game
        vc.originalImageData = imageData
        vc.location = location

        do {
            let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            try imageData.write(to: url)

            vc.imageEditorModel = try ImageEditorModel(srcImagePath: url.path)
        } catch {
            fatalError("error: \(error)")
        }

        return vc
    }

    // MARK: - UIViewController

    lazy var imageEditorToolbar: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 16
        return stack
    }()

    func updateImageEditorToolbar() {
        Logger.debug("")
        imageEditorToolbar.subviews.forEach { $0.removeFromSuperview() }
        imageEditorView.navigationBarItems().forEach { imageEditorToolbar.addArrangedSubview($0) }
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .black

        let imageEditorView = ImageEditorView(model: imageEditorModel, delegate: self)
        imageEditorView.configureSubviews()
        self.imageEditorView = imageEditorView
        view.addSubview(imageEditorView)
        imageEditorView.autoPinEdgesToSuperviewEdges()

        view.addSubview(loadingView)
        loadingView.autoCenterInSuperview()
        loadingView.autoSetDimensions(to: CGSize(square: 80))

        view.addSubview(bottomSection)
        bottomSection.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: imageEditorToolbar)
        updateImageEditorToolbar()
        loadingView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(approvalDelegate != nil)
        setApprovalButtonTitle()
    }

    // MARK: - Subviews

    var imageEditorView: ImageEditorView!

    lazy var loadingView: UIView = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        view.addSubview(activityIndicatorImageView)
        activityIndicatorImageView.autoPinEdgesToSuperviewMargins()

        return view
    }()

    lazy var activityIndicatorImageView: UIImageView = {
        let image = UIImage.animatedImageNamed("biketag-spinner-", duration: 0.5)!
        let imageView = UIImageView(image: image)

        return imageView
    }()

    lazy var approvalButton: PrimaryButton! = {
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(didTapApprove), for: .touchUpInside)

        return button
    }()

    lazy var bottomSection: UIView = {
        let bottomSection = UIView()
        bottomSection.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        bottomSection.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        bottomSection.preservesSuperviewLayoutMargins = true

        approvalButton.autoSetDimension(.height, toSize: 80)

        let label = UILabel()
        label.font = UIFont.bt_bold_label.withSize(16)
        label.textColor = .bt_whiteText
        label.text = NSLocalizedString("Everything looking good? 😎", comment: "label text overlaying camera view")
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [label, approvalButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        bottomSection.addSubview(stack)
        stack.autoPinEdgesToSuperviewMargins()

        return bottomSection
    }()

    // MARK: -

    func startLoadingAnimation() {
        loadingView.isHidden = false
        approvalButton.setTitle("Uploading...", for: UIControl.State.disabled)
        approvalButton.isEnabled = false
    }

    func stopLoadingAnimation() {
        loadingView.isHidden = true
        approvalButton.isEnabled = true
        setApprovalButtonTitle()
    }

    func setApprovalButtonTitle() {
        let text = approvalDelegate?.approvalButtonText ?? "Post! "
        // let attributes: [NSAttributedString.Key : Any] = [
        //     .strokeColor : UIColor.bt_whiteText,
        //     .foregroundColor : UIColor.bt_red,
        //     .strokeWidth : -2.0,
        // ]
        //
        // let title = NSAttributedString(string: text, attributes: attributes)
        // approvalButton.setAttributedTitle(title, for: .normal)
        approvalButton.setTitle(text, for: .normal)
    }

    func presentAlert(error: Error) {
        stopLoadingAnimation()

        let alertController: UIAlertController
        if case let ApiService.APIError.serviceError(errorCode, _) = error,
            errorCode == 133 {
            alertController = UIAlertController(
                title: "Try a little harder!",
                message: "You're too close to the last spot. Go a bit farther and try again.",
                preferredStyle: .alert
            )

            // TODO: this is spots specific... I guess it should be passed to the delegate?

            let retryAction = UIAlertAction(title: "OK, I'm Sorry.", style: .default) { _ in
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else { // presented modally
                    self.dismiss(animated: true, completion: nil)
                }
            }
            alertController.addAction(retryAction)
        } else {
            Logger.error("unexpected error: \(error)")
            alertController = UIAlertController(
                title: "There was trouble uploading your new Spot.",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.approveImage()
            }
            alertController.addAction(retryAction)
        }

        present(alertController, animated: true, completion: nil)
    }

    @objc
    func didTapApprove() {
        approveImage()
    }

    func approveImage() {
        startLoadingAnimation()

        let outputImageData: Data
        if imageEditorModel.isDirty() {
            outputImageData = imageEditorModel.renderOutput()!.jpegData(compressionQuality: 0.95)!
        } else {
            outputImageData = originalImageData
        }
        approvalDelegate?.approvalView(self, didApproveImageData: outputImageData, location: location, errorCallback: presentAlert(error:))
    }
}
