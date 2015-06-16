import UIKit

private let secondsToCapture = 1800

class CheckGuessViewController: ApplicationViewController {
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var fakeResponseActions: UIView!
  @IBOutlet var timesUpResponseActions: UIView!
  @IBOutlet var fakeCorrectResponseButton: UIButton!
  @IBOutlet var fakeIncorrectResponseButton: UIButton!
  @IBOutlet var incorrectGuessView: UIView!
  @IBOutlet var incorrectOverlayView: UIView!
  @IBOutlet var correctGuessView: UIView!
  @IBOutlet var countdownContainerView: UIView!
  @IBOutlet var countdownClockView: UILabel!
  @IBOutlet var submittedImageView: UIImageView! {
    didSet {
      updateSubmittedImageView()
    }
  }
  @IBOutlet var countdownSubheader: UILabel!
  @IBOutlet var countdownHeader: UILabel!
  @IBOutlet var newSpotButton: UIButton!
  @IBOutlet var guessAgainButton: UIButton!
  @IBOutlet var timesUpGuessAgainButton: UIButton!

  @IBOutlet var timesUpSadFaceView: UILabel!
  @IBOutlet var incorrectSadFaceView: UILabel!
  @IBOutlet var incorrectDistanceLabel: UILabel!
  var timer: NSTimer? = nil
  var startTime: NSDate? = nil

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
    self.stylePrimaryButton(self.guessAgainButton)
    self.stylePrimaryButton(self.timesUpGuessAgainButton)
    self.stylePrimaryButton(self.newSpotButton)

    self.submitGuessToServer()
    progressView.progress = 0
    updateSubmittedImageView()
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

  func handleGuessResponse(guess: Guess) {
    if( Config.fakeApiCalls() ) {
      self.fakeResponseActions.hidden = false
    } else {
      if guess.correct! {
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
    self.incorrectOverlayView.hidden = false
    self.incorrectDistanceLabel.text = self.guess!.distanceMessage()
    self.rotateSadFaceView(incorrectSadFaceView)
  }

  @IBAction func touchedPretendIncorrectGuess(sender: AnyObject) {
    self.guess!.correct = false
    self.guess!.distance = 0.03
    incorrectGuess()
  }

  @IBAction func touchedPretendCorrectGuess(sender: AnyObject) {
    self.guess!.correct = true
    self.guess!.distance = 0.0001
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

    //Animate out "you got it" text
    UIView.animateWithDuration(1.0, delay: 0,
      options: .CurveEaseInOut,
      animations: {
        self.countdownSubheader.alpha = 0
        self.countdownHeader.alpha = 0
        self.correctGuessView.alpha = 0
      },
      completion: nil)

    //Animate in "Times Up" elements
    self.timesUpResponseActions.hidden = false
    self.timesUpResponseActions.alpha = 0

    UIView.animateWithDuration(3.0, delay: 1.0,
      options: .CurveEaseInOut,
      animations: {
        // slide up clock and sad face
        self.countdownClockView.frame.origin.y = self.countdownClockView.frame.origin.y / 2.5
        self.timesUpSadFaceView.center.y = self.countdownContainerView.center.y

        // fade in retry actions
        self.timesUpResponseActions.alpha = 1
      },
      completion: { (someBool: Bool) -> () in
        self.rotateSadFaceView(self.timesUpSadFaceView)
      }
    )
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
    self.countdownClockView.alpha = 1
    UIView.animateWithDuration(0.24, delay: 0,
      options: .CurveEaseInOut | .Repeat | .Autoreverse,
      animations: { self.countdownClockView.alpha = 0 },
      completion: nil)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) -> Void {
    super.prepareForSegue(segue, sender: sender)
    if segue.destinationViewController is NewSpotViewController {
      let newSpotViewController = segue.destinationViewController as! NewSpotViewController
      newSpotViewController.game = self.guess!.game
    }
  }

  deinit {
    // Run loops create a strong reference to the timer, 
    // make sure we explicitly invalidate it.
    self.timer?.invalidate()
  }

}
