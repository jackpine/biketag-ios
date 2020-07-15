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

class ApprovalViewController: BaseViewController {
    var game: Game?
    var editedImageData: Data!
    var location: CLLocation!

    weak var approvalDelegate: ApprovalDelegate?

    class func create(imageData: Data, location: CLLocation, game: Game?) -> ApprovalViewController {
        let vc = ApprovalViewController()
        vc.game = game
        vc.editedImageData = imageData
        vc.location = location
        vc.imageView.image = UIImage(data: imageData)!

        return vc
    }

    // MARK: - UIViewController

    override func loadView() {
        view = UIView()
        view.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()

        view.addSubview(loadingView)
        loadingView.autoCenterInSuperview()
        loadingView.autoSetDimensions(to: CGSize(square: 80))

        view.addSubview(approvalButton)
        approvalButton.autoAlignAxis(toSuperviewAxis: .vertical)
        approvalButton.autoPinEdge(toSuperviewMargin: .bottom)

        loadingView.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(approvalDelegate != nil)
        approvalButton.setTitle(approvalDelegate?.approvalButtonText ?? "Post! ", for: .normal)

        title = NSLocalizedString("Everything looking good? 😎", comment: "navbar title while reviewing the spot you're about to upload")
    }

    // MARK: - Subviews

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

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill

        return imageView
    }()

    lazy var approvalButton: PrimaryButton! = {
        let button = PrimaryButton()
        button.addTarget(self, action: #selector(didTapApprove), for: .touchUpInside)

        return button
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
        let title = approvalDelegate?.approvalButtonText ?? "Post! "
        approvalButton.setTitle(title, for: .normal)
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
                guard let self = self else { return }
                self.approvalDelegate?.approvalView(self, didApproveImageData: self.editedImageData, location: self.location, errorCallback: self.presentAlert(error:))
            }
            alertController.addAction(retryAction)
        }

        present(alertController, animated: true, completion: nil)
    }

    @objc
    func didTapApprove() {
        startLoadingAnimation()
        approvalDelegate?.approvalView(self, didApproveImageData: editedImageData, location: location, errorCallback: presentAlert(error:))
    }
}
