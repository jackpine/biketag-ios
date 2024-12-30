//
//  CorrectGuessViewController.swift
//  BikeTag
//
//  Created by Michael Kirk on 3/29/16.
//  Copyright © 2016 Jackpine. All rights reserved.
//

import CoreLocation
import UIKit

private let secondsToCapture = 30 * 60

protocol CorrectGuessDelegate: AnyObject {
  func correctGuessAtNewSpot(_ correctGuessVC: CorrectGuessViewController, game: Game)
}

class CorrectGuessViewController: BaseViewController {
  deinit {
    // Run loops create a strong reference to the timer,
    // make sure we explicitly invalidate it.
    self.timer?.invalidate()
  }

  @IBOutlet var countdownClockLabel: UILabel!

  var guess: Guess!
  weak var correctGuessDelegate: CorrectGuessDelegate?

  private var startTime: NSDate?
  private var timer: Timer?

  class func fromStoryboard() -> Self {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard
      let vc = storyboard.instantiateViewController(withIdentifier: "CorrectGuessViewController")
        as? Self
    else {
      preconditionFailure("unexpected vc")
    }
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    startTime = NSDate()
    timer = Timer.scheduledTimer(
      timeInterval: 0.1, target: self,
      selector: #selector(CorrectGuessViewController.updateSecondsLeft), userInfo: nil,
      repeats: true)
  }

  @IBAction
  func didPressAtNextSpot(_: AnyObject) {
    correctGuessDelegate?.correctGuessAtNewSpot(self, game: guess.game)
  }

  var secondsLeft: Int = secondsToCapture {
    didSet {
      let clockString = NSString(format: "%02d:%02d", secondsLeft / 60, secondsLeft % 60)
      countdownClockLabel.text = clockString as String
    }
  }

  @objc func updateSecondsLeft() {
    secondsLeft = secondsToCapture + Int(startTime!.timeIntervalSinceNow)
    // Potentially way passed time if the app was backgrounded for a while.
    if secondsLeft < 11 {
      blinkClock()
    }

    if secondsLeft < 1 {
      timeHasRunOut()
    }
  }

  func timeHasRunOut() {
    timer?.invalidate()
    secondsLeft = 0

    performSegue(withIdentifier: "showTimesUp", sender: self)
  }

  var clockBlinking: Bool = false
  func blinkClock() {
    if clockBlinking {
      return
    }

    clockBlinking = true
    countdownClockLabel.alpha = 1
    UIView.animate(
      withDuration: 0.24, delay: 0,
      options: [.curveEaseInOut, .repeat, .autoreverse],
      animations: { self.countdownClockLabel.alpha = 0 },
      completion: nil)
  }
}
