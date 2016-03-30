//
//  CorrectGuessViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/29/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import UIKit

private let secondsToCapture = 30 * 60

class CorrectGuessViewController: ApplicationViewController {

  deinit {
    // Run loops create a strong reference to the timer,
    // make sure we explicitly invalidate it.
    self.timer?.invalidate()
  }

  @IBOutlet var countdownClockLabel: UILabel!

  var guess: Guess?
  var startTime: NSDate?
  var timer: NSTimer?

  override func viewDidLoad() {
    self.startTime = NSDate()
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(CorrectGuessViewController.updateSecondsLeft), userInfo: nil, repeats: true)
  }


  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.destinationViewController is NewSpotViewController {
      let newSpotViewController = segue.destinationViewController as! NewSpotViewController
      newSpotViewController.game = self.guess!.game
    }
  }


  var secondsLeft: Int = secondsToCapture {
    didSet {
      let clockString = NSString(format:"%02d:%02d", secondsLeft / 60, secondsLeft % 60 )
      self.countdownClockLabel.text = clockString as String
    }
  }

  func updateSecondsLeft() {
    self.secondsLeft = secondsToCapture - Int(NSDate().timeIntervalSinceDate(self.startTime!))
    //Potentially way passed time if the app was backgrounded for a while.
    if(self.secondsLeft < 11) {
      self.blinkClock()
    }

    if(self.secondsLeft < 1) {
      timeHasRunOut()
    }
  }

  func timeHasRunOut() {
    self.timer?.invalidate()
    self.secondsLeft = 0

    self.performSegueWithIdentifier("showTimesUp", sender: self)
  }

  func rotateSadFaceView(sadFaceView: UILabel) -> () {
    let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
    rotateAnimation.fromValue = 0.0
    //90 degrees
    rotateAnimation.toValue = CGFloat(M_PI * 0.5)
    rotateAnimation.duration = 2.0
    rotateAnimation.fillMode = kCAFillModeForwards
    rotateAnimation.removedOnCompletion = false
    rotateAnimation.beginTime = CACurrentMediaTime() + 0.5
    sadFaceView.layer.addAnimation(rotateAnimation, forKey: nil)
  }
  
  var clockBlinking: Bool = false
  func blinkClock() {
    if self.clockBlinking {
      return
    }
    
    self.clockBlinking = true
    self.countdownClockLabel.alpha = 1
    UIView.animateWithDuration(0.24, delay: 0,
                               options: [.CurveEaseInOut, .Repeat, .Autoreverse],
                               animations: { self.countdownClockLabel.alpha = 0 },
                               completion: nil)
  }

}
