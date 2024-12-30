//
//  TimesUpController.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/30/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class TimesUpViewController: BaseViewController {
  @IBOutlet var sadFaceView: SadFaceView!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    sadFaceView.rotate()
  }
}
