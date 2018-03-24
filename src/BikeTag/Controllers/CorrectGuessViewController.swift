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
    var timer: Timer?

  override func viewDidLoad() {
    self.startTime = NSDate()
    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CorrectGuessViewController.updateSecondsLeft), userInfo: nil, repeats: true)
  }


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // TODO make guard or comment as to when this is expected to fail
    if let newSpotViewController = segue.destination as? NewSpotViewController {
      newSpotViewController.game = self.guess!.game
    }
  }


  var secondsLeft: Int = secondsToCapture {
    didSet {
      let clockString = NSString(format:"%02d:%02d", secondsLeft / 60, secondsLeft % 60 )
      self.countdownClockLabel.text = clockString as String
    }
  }

    @objc func updateSecondsLeft() {
    self.secondsLeft = secondsToCapture - Int(self.startTime!.timeIntervalSinceNow)
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

    self.performSegue(withIdentifier: "showTimesUp", sender: self)
  }
  
  var clockBlinking: Bool = false
  func blinkClock() {
    if self.clockBlinking {
      return
    }
    
    self.clockBlinking = true
    self.countdownClockLabel.alpha = 1
    UIView.animate(withDuration: 0.24, delay: 0,
                               options: [.curveEaseInOut, .repeat, .autoreverse],
                               animations: { self.countdownClockLabel.alpha = 0 },
                               completion: nil)
  }

}
