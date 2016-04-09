//
//  FirstSpotCreatedController.swift
//  BikeTag
//
//  Created by Michael Kirk on 4/9/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class FirstSpotCreatedViewController: ApplicationViewController {
  @IBOutlet var headerLabel: UILabel!
  @IBOutlet var subHeaderLabel: UILabel!
  @IBOutlet var prepareForNotificationLabel: UILabel!
  @IBOutlet var askForNotificationPermissionButton: PrimaryButton!

  @IBAction func pressedAskButton() {
    registerForPushNotifications()
    self.performSegueWithIdentifier("unwindToHome", sender: nil)
  }

  override func viewDidLoad() {
    headerLabel.layer.opacity = 0
    subHeaderLabel.layer.opacity = 0
    prepareForNotificationLabel.layer.opacity = 0
    askForNotificationPermissionButton.layer.opacity = 0
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.headerLabel.layer.opacity = 1.0 }) { (finished: Bool) -> () in
      UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.subHeaderLabel.layer.opacity = 1.0 }) { (finished: Bool) -> () in
        UIView.animateWithDuration(1, delay: 0.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.prepareForNotificationLabel.layer.opacity = 1.0 }) { (finished: Bool) -> () in
          UIView.animateWithDuration(1, delay: 1.5, options: UIViewAnimationOptions.CurveEaseIn, animations: { self.askForNotificationPermissionButton.layer.opacity = 1.0 }, completion: nil)
        }
      }
    }
  }

  func registerForPushNotifications() {
    let application = UIApplication.sharedApplication()
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
  }

}