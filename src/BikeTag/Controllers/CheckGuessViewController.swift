import UIKit
import Crashlytics

class CheckGuessViewController: ApplicationViewController {
  @IBOutlet var fakeResponseActions: UIView!
  @IBOutlet var fakeCorrectResponseButton: UIButton!
  @IBOutlet var fakeIncorrectResponseButton: UIButton!
  @IBOutlet var submittedImageView: UIImageView! {
    didSet {
      updateSubmittedImageView()
    }
  }
  @IBOutlet var progressLabel: UILabel!
  @IBOutlet var progressOverlay: UIView!

  var guess: Guess? {
    didSet {
      updateSubmittedImageView()
    }
  }

  func updateSubmittedImageView() {
    // Wait until both are set before updating - since they are set async
    if ( self.guess != nil && self.submittedImageView != nil ) {
      submittedImageView.image = guess!.image
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.submitGuessToServer()
    self.updateSubmittedImageView()
  }

  func submitGuessToServer() {
    animateProgress()

    let displayErrorAlert = { (error: NSError) -> () in
      let alertController = UIAlertController(
        title: "Unable to submit your guess.",
        message: error.localizedDescription,
        preferredStyle: .Alert)

      let retryAction = UIAlertAction(title: "Retry", style: .Default) { (action) in
        self.submitGuessToServer()
      }
      alertController.addAction(retryAction)

      let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        let navigationController: UINavigationController = self.navigationController!
        navigationController.popToRootViewControllerAnimated(true)
      }
      alertController.addAction(cancelAction)

      self.presentViewController(alertController, animated: true, completion: nil)
    }
    self.spotsService.postSpotGuess(self.guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
  }

  func animateProgress() {
    let progressMessages = ["Hmmm...", "O.K.", "...maybe", "Well, actually...", "Ummmm...", "Hold on."]


    UIView.animateWithDuration(1.0, delay: 1.0,
      options: [.CurveEaseInOut, .Repeat, .Autoreverse],
      animations: {
        let randomIndex = Int(arc4random_uniform(UInt32(progressMessages.count)))
        let message = progressMessages[randomIndex]
        self.progressLabel.alpha = 0
        self.progressLabel.text = message
      },
      completion: nil
    )
  }

  func handleGuessResponse(guess: Guess) {
    if( Config.fakeApiCalls() ) {
      self.fakeResponseActions.hidden = false
    } else {
      self.progressOverlay.hidden = true
      if guess.correct! {
        correctGuess(guess)
      } else {
        incorrectGuess(guess)
      }
    }
  }

  func correctGuess(guess: Guess) {
    Answers.logCustomEventWithName("correct_guess", customAttributes: ["spot_id": guess.spot.id!,
      "user_id": User.getCurrentUser().id])
    self.performSegueWithIdentifier("showCorrectGuess", sender: nil)
  }

  func incorrectGuess(guess: Guess) {
    Answers.logCustomEventWithName("incorrect_guess", customAttributes: ["spot_id": guess.spot.id!, "user_id": User.getCurrentUser().id])
    self.performSegueWithIdentifier("showIncorrectGuess", sender: nil)
  }

  @IBAction func touchedPretendIncorrectGuess(sender: AnyObject) {
    self.progressOverlay.hidden = true
    self.guess!.correct = false
    self.guess!.distance = 0.03
    incorrectGuess(self.guess!)
  }

  @IBAction func touchedPretendCorrectGuess(sender: AnyObject) {
    self.progressOverlay.hidden = true
    self.guess!.correct = true
    self.guess!.distance = 0.0001
    correctGuess(self.guess!)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    if segue.destinationViewController is IncorrectGuessViewController {
      let incorrectGuessViewController = segue.destinationViewController as! IncorrectGuessViewController
      incorrectGuessViewController.guess = self.guess!
    } else if segue.destinationViewController is CorrectGuessViewController {
      let correctGuessViewController = segue.destinationViewController as! CorrectGuessViewController
      correctGuessViewController.guess = self.guess!
    }
  }

}
