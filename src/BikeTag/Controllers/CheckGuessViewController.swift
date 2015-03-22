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

  var guessedSpot: Spot? {
    didSet {
      updateSubmittedImage()
      if (guessedSpot != nil) {
        submitGuessToServer()
      }
    }
  }

  func updateSubmittedImage() {
    if ( self.guessedSpot != nil && self.submittedImageView != nil ) {
      submittedImageView.image = guessedSpot!.image
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    progressView.progress = 0
    updateSubmittedImage()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  func submitGuessToServer() {
    let displayAlert = { (error: NSError) -> () in
      println(error.localizedDescription)
    }
    SpotsService.postSpotGuess(self.guessedSpot!, callback: handleGuessResponse, errorCallback: displayAlert)
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
      self.countdownClockView.text = clockString
    }
  }

  func decrementSecondsLeft() {
    self.secondsLeft--
  }
}
