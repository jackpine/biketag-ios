import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var currentSession: Session = Session(currentSpots:SpotsCollection())
  let locationService = LocationService()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    // Override point for customization after application launch.
    Fabric.with([Crashlytics()])

    PushNotificationManager.register()

    // Load Main App Screen
    if UserDefaults.apiKey() == nil {
      Logger.info("First time user! showing welcome screen")
      let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
      let welcomeViewController = storyboard.instantiateViewControllerWithIdentifier("welcomeViewController")
      self.window!.rootViewController = welcomeViewController
      self.window!.makeKeyAndVisible()
    } else {
      Logger.info("Existing user, not doing any manual ViewController setup")
    }

    // TODO this is the current way to log in as an existing user
    //
    //    ApiKey.setCurrentApiKey([
    //      "client_id": "paste-youre-client-id-here",
    //      "secret": "paste-your-secret-here",
    //      "user_id": 1
    //    ])

    return true
  }

  func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != .None {
      application.registerForRemoteNotifications()
    }
  }

  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var tokenString = ""

    for i in 0..<deviceToken.length {
      tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }

    let logSuccess = {
      Logger.info("Successfully registered for remote notifications with device token: \(tokenString)")
    }

    let logError = { (error: NSError) -> () in
      Logger.error("User registered for notifications with device token \(tokenString), but failed to submit to API: \(error)")
    }

    DevicesService().postNewDevice(tokenString, successCallback: logSuccess, errorCallback: logError)
  }

  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    Logger.info("Failed to register for remote notifications: \(error)")
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

