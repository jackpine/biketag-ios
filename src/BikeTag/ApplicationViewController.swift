import Foundation
import UIKit

class ApplicationViewController: UIViewController {

  let spotsService = Config.fakeApiCalls() ? FakeSpotsService() : SpotsService()

}
