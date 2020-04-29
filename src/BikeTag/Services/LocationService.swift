import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var mostRecentLocation: CLLocation?

    required override init() {
        super.init()
    }

    func waitForLocation(onSuccess successCallback: @escaping (CLLocation) -> Void, onTimeout timeoutCallback: @escaping () -> Void) {
        // call successCallback immediately if possible.
        if let location = self.mostRecentLocation {
            successCallback(location)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Don't bombard the user with a redundant warning if they are still reading the location authorization request.

            // TODO refactor with switch
            if  CLLocationManager.authorizationStatus() != .authorizedAlways && CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                return self.waitForLocation(onSuccess: successCallback, onTimeout: timeoutCallback)
            }

            if let location = self.mostRecentLocation {
                successCallback(location)
            } else {
                timeoutCallback()
            }
        }
    }

    func startTrackingLocation(onDenied deniedCallback: () -> Void) {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager!.startUpdatingLocation()
        case .notDetermined:
            locationManager!.requestWhenInUseAuthorization()
        case .restricted, .denied:
            deniedCallback()
        @unknown default:
            assertionFailure("unknown CLLocationManager.authorizationStatus: \(CLLocationManager.authorizationStatus().rawValue)")
        }
    }

    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        startTrackingLocation(onDenied: { Logger.error("sneaky user disabled location authorization status.") })
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard locations.last != nil else {
            Logger.error("location did update, but was nil")
            return
        }

        if  self.mostRecentLocation == nil {
            Logger.debug("Initialized location: \(String(describing: locations.last))")
        }
        self.mostRecentLocation = locations.last
    }
}
