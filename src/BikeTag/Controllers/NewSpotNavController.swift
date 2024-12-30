//
//  NewSpotNavController.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/16/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

protocol NewSpotNavDelegate: AnyObject {
  func newSpotNav(_ newSpotNav: NewSpotNavController, didFinishCreatingSpot newSpot: Spot)
}

class NewSpotNavController: BaseNavController {
  weak var newSpotDelegate: NewSpotNavDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    modalPresentationStyle = .fullScreen
  }
}

extension NewSpotNavController: SpotCreationDelegate {
  func spotCreation(
    _ newSpotVC: NewSpotViewController, didCaptureImageData imageData: Data, location: CLLocation
  ) {
    let approvalVC = ApprovalViewController.create(
      imageData: imageData, location: location, game: nil)
    approvalVC.approvalDelegate = newSpotVC
    fadeTo(approvalVC)
  }

  func spotCreation(
    _: NewSpotViewController, didApproveImageData imageData: Data, location: CLLocation,
    errorCallback: @escaping (Error) -> Void
  ) {
    guard let image = UIImage(data: imageData) else {
      Logger.error("New spot image data not captured")
      return
    }

    let spot = Spot(
      image: image, game: Game(id: nil), user: User.getCurrentUser(), location: location)
    Spot.createNewSpot(
      image: spot.image!,
      game: spot.game,
      location: spot.location!,
      callback: { newSpot in self.newSpotDelegate?.newSpotNav(self, didFinishCreatingSpot: newSpot)
      },
      errorCallback: errorCallback)
  }
}
