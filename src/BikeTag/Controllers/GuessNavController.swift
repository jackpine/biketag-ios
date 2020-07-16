//
//  GuessNavController.swift
//  BikeTag
//
//  Created by Michael Kirk on 7/16/20.
//  Copyright © 2020 Jackpine. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

protocol GuessNavDelegate: AnyObject {
    func guessNavRequestedStop(_ guessNav: GuessNavController)
    func guessNav(_ guessNav: GuessNavController, didPostNewSpot spot: Spot)
}

class GuessNavController: BaseNavController {
    var game: Game { existingSpot.game }
    var existingSpot: Spot!
    weak var guessNavDelegate: GuessNavDelegate?

    func showCheckGuessViewController(imageData: Data, location: CLLocation) {
        guard let image = UIImage(data: imageData) else {
            Logger.error("New guess image data not captured")
            return
        }

        let newGuess = Guess(spot: existingSpot, user: User.getCurrentUser(), location: location, image: image)
        let checkGuessVC = CheckGuessViewController.fromStoryboard()
        checkGuessVC.checkGuessDelegate = self
        checkGuessVC.guess = newGuess
        pushViewController(checkGuessVC, animated: true)
    }

    func showCorrectGuess(_ guess: Guess) {
        let vc = CorrectGuessViewController.fromStoryboard()
        vc.guess = guess
        if #available(iOS 13.0, *) {
            // Disable swipe to dismiss while the countdown timer is showing.
            vc.isModalInPresentation = true
        }
        vc.correctGuessDelegate = self
        setViewControllers([vc], animated: true)
    }

    func showWrongGuess(_ guess: Guess) {
        let vc = IncorrectGuessViewController.fromStoryboard()
        vc.guess = guess
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                              target: self,
                                                              action: #selector(didTapExitGuessFlow))
        setViewControllers([vc], animated: true)
    }

    @objc
    func didTapExitGuessFlow() {
        guessNavDelegate?.guessNavRequestedStop(self)
    }
}

extension GuessNavController: CheckGuessDelegate {
    func checkedGuess(_: CheckGuessViewController, didGuessCorrect guess: Guess) {
        showCorrectGuess(guess)
    }

    func checkedGuess(_: CheckGuessViewController, didGuessWrong guess: Guess) {
        showWrongGuess(guess)
    }
}

extension GuessNavController: GuessCreationDelegate {
    func guessCreation(_ newGuessVC: GuessSpotViewController, didCaptureImageData imageData: Data, location: CLLocation) {
        let approvalVC = ApprovalViewController.create(imageData: imageData, location: location, game: existingSpot.game)
        approvalVC.approvalDelegate = newGuessVC
        fadeTo(approvalVC)
    }

    func guessCreation(_: GuessSpotViewController, didApproveImageData imageData: Data, location: CLLocation, errorCallback _: @escaping (Error) -> Void) {
        showCheckGuessViewController(imageData: imageData, location: location)
    }
}

extension GuessNavController: CorrectGuessDelegate {
    func correctGuessAtNewSpot(_: CorrectGuessViewController, game: Game) {
        let newSpotVC = NewSpotViewController.fromStoryboard()
        newSpotVC.game = game
        newSpotVC.spotCreationDelegate = self
        pushViewController(newSpotVC, animated: true)
    }
}

extension GuessNavController: SpotCreationDelegate {
    func spotCreation(_ newSpotVC: NewSpotViewController, didCaptureImageData imageData: Data, location: CLLocation) {
        let approvalVC = ApprovalViewController.create(imageData: imageData, location: location, game: nil)
        approvalVC.approvalDelegate = newSpotVC
        fadeTo(approvalVC)
    }

    func spotCreation(_: NewSpotViewController, didApproveImageData imageData: Data, location: CLLocation, errorCallback: @escaping (Error) -> Void) {
        guard let image = UIImage(data: imageData) else {
            Logger.error("New spot image data not captured")
            return
        }

        let spot = Spot(image: image, game: game, user: User.getCurrentUser(), location: location)
        Spot.createNewSpot(image: spot.image!,
                           game: spot.game,
                           location: spot.location!,
                           callback: { newSpot in self.guessNavDelegate?.guessNav(self, didPostNewSpot: newSpot) },
                           errorCallback: errorCallback)
    }
}
