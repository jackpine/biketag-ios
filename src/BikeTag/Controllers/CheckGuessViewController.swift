import UIKit

class CheckGuessViewController: ApplicationViewController {
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var fakeResponseActions: UIView!
  @IBOutlet var fakeCorrectResponseButton: UIButton!
  @IBOutlet var fakeIncorrectResponseButton: UIButton!
  @IBOutlet var incorrectGuessView: UIView!
  @IBOutlet var correctGuessView: UIView!
  @IBOutlet var countdownContainerView: UIView!
  @IBOutlet var countdownClockView: UILabel!
  @IBOutlet var submittedImageView: UIImageView! {
    didSet {
      updateSubmittedImage()
    }
  }
  @IBOutlet var newSpotButton: UIButton!
  @IBOutlet var guessAgainButton: UIButton!

  var guess: Guess? {
    didSet {
      updateSubmittedImage()
      if (guess != nil) {
        submitGuessToServer()
      }
    }
  }

  func updateSubmittedImage() {
    if ( self.guess != nil && self.submittedImageView != nil ) {
      submittedImageView.image = guess!.image
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.stylePrimaryButton(self.guessAgainButton)
    self.stylePrimaryButton(self.newSpotButton)
    progressView.progress = 0
    updateSubmittedImage()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  func submitGuessToServer() {

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
    SpotsService().postSpotGuess(self.guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
  }

  func handleGuessResponse(guessedCorrectly: Bool) {
    if( Config.testing() ) {
      self.fakeResponseActions.hidden = false
    } else {
      if (guessedCorrectly) {
        correctGuess()
      } else {
        incorrectGuess()
      }
    }
  }

  func correctGuess() {
    self.fakeResponseActions.hidden = true
    self.correctGuessView.hidden = false
    self.countdownContainerView.hidden = false

    let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "decrementSecondsLeft", userInfo: nil, repeats: true)
  }

  func incorrectGuess() {
    self.fakeResponseActions.hidden = true
    self.incorrectGuessView.hidden = false
  }

  @IBAction func touchedPretendIncorrectGuess(sender: AnyObject) {
    incorrectGuess()
  }

  @IBAction func touchedPretendCorrectGuess(sender: AnyObject) {
    correctGuess()
  }

  var secondsLeft:Int = 1800 {
    didSet {
      let clockString = NSString(format:"%02d:%02d", secondsLeft / 60, secondsLeft % 60 )
      self.countdownClockView.text = clockString as String
    }
  }

  func decrementSecondsLeft() {
    self.secondsLeft--
  }
}
