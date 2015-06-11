import Foundation
import CoreLocation
import UIKit

class Guess {
  let spot: Spot
  let user: User
  let game: Game
  let location: CLLocation
  let image: UIImage

  init(spot: Spot, user: User, location: CLLocation, image: UIImage) {
    self.spot = spot
    self.user = user
    self.location = location
    self.image = image
    self.game = spot.game
  }
}