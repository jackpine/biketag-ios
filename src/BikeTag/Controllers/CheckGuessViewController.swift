import UIKit

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

        let displayErrorAlert = { (error: Error) -> Void in
            let alertController = UIAlertController(
                title: "Unable to submit your guess.",
                message: error.localizedDescription,
                preferredStyle: .alert)

            let retryAction = UIAlertAction(title: "Retry", style: .default) { action in
                self.submitGuessToServer()
            }
            alertController.addAction(retryAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                let navigationController: UINavigationController = self.navigationController!
                navigationController.popToRootViewController(animated: true)
            }
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }
        self.spotsService.postSpotGuess(guess: self.guess!, callback: handleGuessResponse, errorCallback: displayErrorAlert)
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
                       completion: nil
        )
    }

    func handleGuessResponse(guess: Guess) {
        if( Config.fakeApiCalls() ) {
            self.fakeResponseActions.isHidden = false
        } else {
            self.progressOverlay.isHidden = true
            if guess.correct! {
                correctGuess(guess: guess)
            } else {
                incorrectGuess(guess: guess)
            }
        }
    }

    func correctGuess(guess: Guess) {
        self.performSegue(withIdentifier: "showCorrectGuess", sender: nil)
    }

    func incorrectGuess(guess: Guess) {
        self.performSegue(withIdentifier: "showIncorrectGuess", sender: nil)
    }

    @IBAction func touchedPretendIncorrectGuess(sender: AnyObject) {
        self.progressOverlay.isHidden = true
        self.guess!.correct = false
        self.guess!.distance = 0.03
        incorrectGuess(guess: self.guess!)
    }

    @IBAction func touchedPretendCorrectGuess(sender: AnyObject) {
        self.progressOverlay.isHidden = true
        self.guess!.correct = true
        self.guess!.distance = 0.0001
        correctGuess(guess: self.guess!)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.destination is IncorrectGuessViewController {
            let incorrectGuessViewController = segue.destination as! IncorrectGuessViewController
            incorrectGuessViewController.guess = self.guess!
        } else if segue.destination is CorrectGuessViewController {
            let correctGuessViewController = segue.destination as! CorrectGuessViewController
            correctGuessViewController.guess = self.guess!
        }
    }

}
