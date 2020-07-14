//
//  FirstSpotCreatedController.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class FirstSpotCreatedViewController: BaseViewController {
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var subHeaderLabel: UILabel!
    @IBOutlet var prepareForNotificationLabel: UILabel!
    @IBOutlet var askForNotificationPermissionButton: PrimaryButton!

    @IBAction func pressedAskButton() {
        UserDefaults.setPrefersReceivingNotifications(val: true)
        PushNotificationManager.register()
        performSegue(withIdentifier: "unwindToHomeWithSegue", sender: nil)
    }

    override func viewDidLoad() {
        headerLabel.layer.opacity = 0
        subHeaderLabel.layer.opacity = 0
        prepareForNotificationLabel.layer.opacity = 0
        askForNotificationPermissionButton.layer.opacity = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: { self.headerLabel.layer.opacity = 1.0 }) { (_: Bool) -> Void in
            UIView.animate(withDuration: 1, delay: 0.0, options: .curveEaseIn, animations: { self.subHeaderLabel.layer.opacity = 1.0 }) { (_: Bool) -> Void in
                UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseIn, animations: { self.prepareForNotificationLabel.layer.opacity = 1.0 }) { (_: Bool) -> Void in
                    UIView.animate(withDuration: 1, delay: 1.5, options: .curveEaseIn, animations: { self.askForNotificationPermissionButton.layer.opacity = 1.0 }, completion: nil)
                }
            }
        }
    }
}
