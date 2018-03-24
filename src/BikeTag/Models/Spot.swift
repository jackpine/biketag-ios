import UIKit
import CoreLocation
import Alamofire

class Spot: NSObject {
    
    static let didSetImageNotification: NSNotification.Name = NSNotification.Name("SpotDidSetImageNotification")
    static let newSpotCost = 25
    
    var image: UIImage? {
        didSet {
            NotificationCenter.default.post(name: Spot.didSetImageNotification, object: self)
        }
    }
    var imageUrl: URL?
    var location: CLLocation?
    var imageView: UIImageView?
    var id: Int?
    let game: Game
    let user: User
    
    init(image: UIImage, game: Game, user: User, id: Int) {
        self.user = user
        self.image = image
        self.id = id
        self.game = game
    }
    
    init(image: UIImage, game: Game, user: User, location: CLLocation) {
        self.user = user
        self.image = image
        self.location = location
        self.game = game
    }
    
    init(parsedSpot: ParsedSpot) {
        self.user = User(id: parsedSpot.userId, name: parsedSpot.userName)
        self.id = parsedSpot.spotId
        self.game = Game(id: parsedSpot.gameId)
        self.imageUrl = parsedSpot.imageUrl
        //placeholder while image is fetched async
        
        super.init()
        
        // TODO pretty weird to make a network request in init.
        Alamofire.request(parsedSpot.imageUrl, method: .get).response() { response in
            guard let data = response.data else {
                Logger.error("Empty image data for spot: \(parsedSpot)")
                return
            }
            guard let image = UIImage(data: data) else {
                Logger.error("Unable to build image from data: \(parsedSpot)")
                return
            }
            
            self.image = image
        }
    }
    
    class func fetchCurrentSpots(spotsService: SpotsService, location: CLLocation, callback:@escaping ([Spot])->(), errorCallback:@escaping (Error)->()) {
        let callbackWithBuiltSpots = { (parsedSpots: [ParsedSpot]) -> () in
            let spots = parsedSpots.map { Spot(parsedSpot: $0) }
            callback(spots)
        }
        
        spotsService.fetchCurrentSpots(location: location, successCallback: callbackWithBuiltSpots, errorCallback: errorCallback)
    }
    
    class func createNewSpot(spotsService: SpotsService, image: UIImage, game: Game, location: CLLocation, callback: @escaping (Spot) ->(), errorCallback:@escaping (Error)->()) {
        let callbackWithBuiltSpot = { (parsedSpot: ParsedSpot) -> () in
            //hydrate spot with server response - should be more-or-less identical to newSpot
            let spot = Spot(parsedSpot: parsedSpot)
            callback(spot)
        }
        
        let newSpot = Spot(image: image, game: game, user: User.getCurrentUser(), location: location)
        spotsService.postNewSpot(spot: newSpot, callback: callbackWithBuiltSpot, errorCallback: errorCallback)
    }
    
    // static spot, used to seed game and for testing
    class func lucileSpot() -> Spot {
        let image = UIImage( named: "952 lucile" )!
        let lat = 34.086582
        let lon = -118.281633
        let location = CLLocation(latitude: lat, longitude: lon)
        return Spot(image: image, game: Game(id: 2), user: User(id: 2, name: "lucile user"), location: location)
    }
    
    // static spot, used to seed game and for testing
    class func griffithSpot() -> Spot {
        let image = UIImage(named: "griffith")!
        let lat = 34.1186
        let lon = -118.3004
        let location = CLLocation(latitude: lat, longitude: lon)
        return Spot(image: image, game: Game(id: 1), user: User(id: 1, name: "griffith user"), location: location)
    }
    
    func isCurrentUserOwner() -> Bool {
        if User.getCurrentUser() == self.user {
            return true
        } else {
            return false
        }
    }
    
    func base64ImageData() -> String {
        return UIImageJPEGRepresentation(self.image!, 0.9)!.base64EncodedString()
    }
    
    func name() -> String {
        return "Spot:\(id ?? 0)"
    }
}
