import UIKit

protocol CheckGuessDelegate: AnyObject {
    func checkedGuess(_ checkGuessViewController: CheckGuessViewController, didGuessCorrect guess: Guess)
    func checkedGuess(_ checkGuessViewController: CheckGuessViewController, didGuessWrong guess: Guess)
}

class CheckGuessViewController: BaseViewController {
    weak var checkGuessDelegate: CheckGuessDelegate?

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

    class func fromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CheckGuessViewController") as? Self else {
            preconditionFailure("unexpected vc")
        }
        return vc
    }

    var guess: Guess? {
        didSet {
            updateSubmittedImageView()
        }
    }

    func updateSubmittedImageView() {
        // Wait until both are set before updating - since they are set async
        if guess != nil, submittedImageView != nil {
            submittedImageView.image = guess!.image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        submitGuessToServer()
        updateSubmittedImageView()
    }

    func submitGuessToServer() {
        animateProgress()

        let displayErrorAlert = { (error: Error) -> Void in
            let alertController = UIAlertController(
                title: "Unable to submit your guess.",
                message: error.localizedDescription,
                preferredStyle: .alert
            )

            let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
                self.submitGuessToServer()
            }
            alertController.addAction(retryAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        Config.spotsService.postSpotGuess(guess: guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
    }

    func animateProgress() {
        let progressMessages = ["Hmmm...", "O.K.", "...maybe", "Well, actually...", "Ummmm...", "Hold on."]

        UIView.animate(withDuration: 1.0, delay: 1.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse],
                       animations: {
                           let randomIndex = Int(arc4random_uniform(UInt32(progressMessages.count)))
                           let message = progressMessages[randomIndex]
                           self.progressLabel.alpha = 0
                           self.progressLabel.text = message
                       },
                       completion: nil)
    }

    func handleGuessResponse(guess: Guess) {
        if Config.shouldFakeAPICalls {
            fakeResponseActions.isHidden = false
        } else {
            progressOverlay.isHidden = true
            if guess.correct! {
                checkGuessDelegate?.checkedGuess(self, didGuessCorrect: guess)
            } else {
                checkGuessDelegate?.checkedGuess(self, didGuessWrong: guess)
            }
        }
    }

    @IBAction func touchedPretendIncorrectGuess(_: AnyObject) {
        guard let guess = guess else {
            assertionFailure("guess was unexpectedly nil")
            return
        }
        progressOverlay.isHidden = true
        guess.correct = false
        guess.distance = 5000
        checkGuessDelegate?.checkedGuess(self, didGuessWrong: guess)
    }

    @IBAction func touchedPretendCorrectGuess(_: AnyObject) {
        guard let guess = guess else {
            assertionFailure("guess was unexpectedly nil")
            return
        }
        progressOverlay.isHidden = true
        guess.correct = true
        guess.distance = 10
        checkGuessDelegate?.checkedGuess(self, didGuessCorrect: guess)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is IncorrectGuessViewController {
            let incorrectGuessViewController = segue.destination as! IncorrectGuessViewController
            incorrectGuessViewController.guess = guess!
        } else if segue.destination is CorrectGuessViewController {
            let correctGuessViewController = segue.destination as! CorrectGuessViewController
            correctGuessViewController.guess = guess!
        }
    }
}
