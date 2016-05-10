import Foundation

class SpotsCollection {
  var spots: [Spot] = []

  func count() -> Int {
    return spots.count
  }

  subscript(index: Int) -> Spot {
    return spots[index]
  }

  func addNewSpot(newSpot: Spot) -> () {
    let oldSpot = spots.filter() { (existingSpot: Spot) -> Bool in
      existingSpot.game == newSpot.game
    }.first

    if oldSpot != nil {
      let gameIndex = spots.indexOf(oldSpot!)!
      spots.removeAtIndex(gameIndex)
    }

    spots.insert(newSpot, atIndex: 0)
  }

  func replaceSpots(spots:[Spot]) -> () {
    self.spots = spots
  }
}