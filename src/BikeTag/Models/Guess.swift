import CoreLocation
import Foundation
import UIKit

class Guess {
    let spot: Spot
    let user: User
    let game: Game
    let location: CLLocation
    let image: UIImage
    var distance: Double?
    var correct: Bool?

    init(spot: Spot, user: User, location: CLLocation, image: UIImage) {
        self.spot = spot
        self.user = user
        self.location = location
        self.image = image
        self.game = spot.game
    }

    func distanceMessage() -> String {
        guard let distance = self.distance else {
            return "I can't tell how far away you are."
        }

        // TODO localize
        if distance < 0.002 {
            return "Shoot! You're super close."
        } else if distance < 0.005 {
            return "You're close though."
        } else if distance < 0.015 {
            return "You are like a mile away."
        } else if distance < 0.1 {
            return "You're in the wrong neighborhood."
        } else if distance < 1.0 {
            return "I don't think you're even in the right town."
        } else if distance < 200 { // ~2,500 miles / 4,000km
            return "You're far. Like REALLY far away."
        } else {
            return "I'm not even sure you're on the right contintent."
        }
    }

    func base64ImageData() -> String {
        return self.image.jpegData(compressionQuality: 0.9)!.base64EncodedString()
    }
}
