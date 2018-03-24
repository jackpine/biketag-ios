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
        self.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(openMouth))
        self.addGestureRecognizer(tapGesture)
    }
    
    func rotate() -> () {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        //90 degrees
        rotateAnimation.toValue = CGFloat(.pi * 0.5)
        rotateAnimation.duration = 0.0
        rotateAnimation.fillMode = kCAFillModeForwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.beginTime = CACurrentMediaTime()
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    @objc
    func openMouth() -> () {
        if self.text == "=(" {
            self.text = "=0"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.text = "=("
            }
        }
    }
}
