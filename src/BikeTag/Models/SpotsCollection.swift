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
        let gameIndex = spots.index(of: oldSpot!)!
        spots.remove(at: gameIndex)
    }

    spots.insert(newSpot, at: 0)
  }

  func replaceSpots(spots:[Spot]) -> () {
    self.spots = spots
  }
}
