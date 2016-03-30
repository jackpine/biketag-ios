//
//  IncorrectGuessViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/29/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class IncorrectGuessViewController: ApplicationViewController {

  var guess: Guess?
  
  @IBOutlet var distanceLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.distanceLabel.text = guess!.distanceMessage()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    // TODO self.rotateSadFaceView(incorrectSadFaceView)
  }

}

