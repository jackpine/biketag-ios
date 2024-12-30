import Foundation

class Game: Equatable {
  let id: Int?

  required init(id: Int?) {
    self.id = id
  }
}

// MARK: Equatable

func == (lhs: Game, rhs: Game) -> Bool {
  return lhs.id == rhs.id
}
