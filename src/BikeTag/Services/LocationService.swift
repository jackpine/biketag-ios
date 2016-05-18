import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
  let locationManager = CLLocationManager()
  var mostRecentLocation: CLLocation?

  required override init() {
    super.init()
    self.locationManager.delegate = self
  }

  func locationManager(manager: CLLocationManager,
                       didChangeAuthorizationStatus status: CLAuthorizationStatus) {

    startTrackingLocation(onDenied: { Logger.error("sneaky user disabled location authorization status.") } )
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if( self.mostRecentLocation == nil ) {
      Logger.debug("Initialized location: \(locations.last)")
    }
    self.mostRecentLocation = locations.last
  }

  // MARK: CLLocationManagerDelegate
  func waitForLocation(onSuccess successCallback: (CLLocation)->(), onTimeout timeoutCallback: ()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in

      // Don't bombard the user with a redundant warning if they are still reading the location authorization request.
      if ( CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways && CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse ) {
        return self.waitForLocation(onSuccess:successCallback, onTimeout: timeoutCallback)
      }

      if let location = self.mostRecentLocation {
        successCallback(location)
      } else {
        timeoutCallback()
      }
    }
  }

  func startTrackingLocation(onDenied deniedCallback: () -> ()) {
    switch CLLocationManager.authorizationStatus() {
    case .AuthorizedAlways, .AuthorizedWhenInUse:
      locationManager.startUpdatingLocation()
    case .NotDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .Restricted, .Denied:
      deniedCallback()
    }
  }

}