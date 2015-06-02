import UIKit

private let secondsToCapture = 1800

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
  @IBOutlet var countdownSubheader: UILabel!
  @IBOutlet var countdownHeader: UILabel!
  @IBOutlet var newSpotButton: UIButton!
  @IBOutlet var guessAgainButton: UIButton!

  var timer: NSTimer? = nil
  var startTime: NSDate? = nil

  var guess: Guess? {
    didSet {
      updateSubmittedImage()
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
    self.submitGuessToServer()
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
    self.spotsService.postSpotGuess(self.guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
  }

  func handleGuessResponse(guessedCorrectly: Bool) {
    if( Config.fakeApiCalls() ) {
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
    self.startTime = NSDate()
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateSecondsLeft", userInfo: nil, repeats: true)
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

  var secondsLeft: Int = secondsToCapture {
    didSet {
      let clockString = NSString(format:"%02d:%02d", secondsLeft / 60, secondsLeft % 60 )
      self.countdownClockView.text = clockString as String
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

    self.newSpotButton.userInteractionEnabled = false

    UIView.animateWithDuration(1.0, delay: 0,
      options: .CurveEaseInOut,
      animations: {
        self.countdownSubheader.alpha = 0
        self.countdownHeader.alpha = 0
      },
      completion: nil)

    UIView.animateWithDuration(2.0, delay: 1.0,
      options: .CurveEaseInOut,
      animations: {
        self.countdownClockView.frame.origin.y = self.countdownClockView.frame.origin.y / 3
        self.sadFaceView = self.countdownClockView.frame.origin.y + 16
      },
      completion: nil)
  }

  var clockBlinking: Bool = false
  func blinkClock() {
    if self.clockBlinking {
      return
    }

    self.clockBlinking = true
    self.countdownClockView.alpha = 1
    UIView.animateWithDuration(0.24, delay: 0,
      options: .CurveEaseInOut | .Repeat | .Autoreverse,
      animations: { self.countdownClockView.alpha = 0 },
      completion: nil)
  }

  deinit {
    // Run loops create a strong reference to the timer, 
    // make sure we explicitly invalidate it.
    self.timer?.invalidate()
  }

}
