import UIKit

class CheckGuessViewController: UIViewController {
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

  var submittedImage: UIImage! {
    didSet {
      updateSubmittedImage()
    }
  }

  func updateSubmittedImage() {
    if ( self.submittedImage != nil && self.submittedImageView != nil ) {
      submittedImageView.image = submittedImage
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    progressView.progress = 0
    updateSubmittedImage()
    self.navigationItem.title = "Checking";
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    submitGuessToServer()
  }

  func submitGuessToServer() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(0.1, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(0.5, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      dispatch_async(dispatch_get_main_queue(), {
        self.progressView.setProgress(1.0, animated:true)
      })

      NSThread.sleepForTimeInterval(0.2)
      Spot.checkGuess(self.submittedImage, correctCallback: self.handleGuessResponse, incorrectCallback: self.handleGuessResponse)
    })
  }

  func handleGuessResponse() {
    self.fakeResponseActions.hidden = false
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
      self.countdownClockView.text = clockString
    }
  }

  func decrementSecondsLeft() {
    self.secondsLeft--
  }
}
