//
//  SadFaceView.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/30/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

class SadFaceView: UILabel {

  required override init(frame: CGRect) {
    super.init(frame: frame)
    configureTapGesture()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configureTapGesture()
  }

  func configureTapGesture() -> () {
    self.userInteractionEnabled = true
    let tapGesture = UITapGestureRecognizer(target:self, action:#selector(openMouth))
    self.addGestureRecognizer(tapGesture)
  }

  func rotate() -> () {
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = 0.0
    //90 degrees
    rotateAnimation.toValue = CGFloat(M_PI * 0.5)
    rotateAnimation.duration = 0.0
    rotateAnimation.fillMode = kCAFillModeForwards
    rotateAnimation.removedOnCompletion = false
    rotateAnimation.beginTime = CACurrentMediaTime()
    self.layer.addAnimation(rotateAnimation, forKey: nil)
  }

  func openMouth() -> () {
    if self.text == "=(" {
      self.text = "=0"
      let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
      dispatch_after(dispatchTime, dispatch_get_main_queue(), {
        self.text = "=("
      })
    }
  }
}