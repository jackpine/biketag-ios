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
        game = spot.game
    }

    func distanceMessage() -> String {
        guard let distance = self.distance else {
            return "I can't tell how far away you are."
        }

        // TODO: localize
        if distance < 200 {
            return "Shoot! You're super close.\n🤏"
        } else if distance < 800 {
            return "You're in the neighborhood.\n👋"
        } else if distance < 2000 {
            return "You are like a mile away.\n🙃"
        } else if distance < 10000 {
            return "You're on the wrong side of town.\n😜"
        } else if distance < 50000 {
            return "I don't think you're even in the right town.\n🤷‍♀️"
        } else if distance < 3_000_000 {
            return "You're far. Like REALLY far. Like across the country far. \n🥺🏳"
        } else {
            return "I'm not even sure you're on the right contintent.\n😝"
        }
    }

    func base64ImageData() -> String {
        return image.jpegData(compressionQuality: 0.9)!.base64EncodedString()
    }
}
