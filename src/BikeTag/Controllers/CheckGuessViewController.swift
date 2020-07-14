import UIKit

class CheckGuessViewController: BaseViewController {
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
        spotsService.postSpotGuess(guess: guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
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
                correctGuess(guess: guess)
            } else {
                incorrectGuess(guess: guess)
            }
        }
    }

    func correctGuess(guess _: Guess) {
        performSegue(withIdentifier: "showCorrectGuess", sender: nil)
    }

    func incorrectGuess(guess _: Guess) {
        performSegue(withIdentifier: "showIncorrectGuess", sender: nil)
    }

    @IBAction func touchedPretendIncorrectGuess(_: AnyObject) {
        progressOverlay.isHidden = true
        guess!.correct = false
        guess!.distance = 0.03
        incorrectGuess(guess: guess!)
    }

    @IBAction func touchedPretendCorrectGuess(_: AnyObject) {
        progressOverlay.isHidden = true
        guess!.correct = true
        guess!.distance = 0.0001
        correctGuess(guess: guess!)
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
