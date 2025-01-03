//
//  IncorrectGuessViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/29/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class IncorrectGuessViewController: BaseViewController {
  var guess: Guess?

  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var sadFaceView: SadFaceView!

  class func fromStoryboard() -> Self {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard
      let vc = storyboard.instantiateViewController(withIdentifier: "IncorrectGuessViewController")
        as? Self
    else {
      preconditionFailure("unexpected vc")
    }
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    distanceLabel.text = guess!.distanceMessage()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    sadFaceView.rotate()
  }
}
