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
        startTime = NSDate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(CorrectGuessViewController.updateSecondsLeft), userInfo: nil, repeats: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        // TODO: make guard or comment as to when this is expected to fail
        if let newSpotViewController = segue.destination as? NewSpotViewController {
            newSpotViewController.game = guess!.game
        }
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
        UIView.animate(withDuration: 0.24, delay: 0,
                       options: [.curveEaseInOut, .repeat, .autoreverse],
                       animations: { self.countdownClockLabel.alpha = 0 },
                       completion: nil)
    }
}
