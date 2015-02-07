import UIKit
import Foundation

class CaptureCountdownViewController: UIViewController {
  @IBOutlet var countdownView: UILabel!

  var secondsLeft:Int = 1800 {
    didSet {
      let clockString = NSString(format:"%02d:%02d", secondsLeft / 60, secondsLeft % 60 )
      countdownView.text = clockString
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "decrementSecondsLeft", userInfo: nil, repeats: true)

  }

  func decrementSecondsLeft() {
    secondsLeft--
  }



}
