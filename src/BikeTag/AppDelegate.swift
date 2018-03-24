import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var currentSession: Session = Session(currentSpots:SpotsCollection())
  let locationService = LocationService()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    // Override point for customization after application launch.
    Fabric.with([Crashlytics(), Answers()])

    if UserDefaults.prefersReceivingNotifications() {
      PushNotificationManager.register()
    } else {
      Logger.debug("Skipping APN registration.")
    }

    // Load Main App Screen
    if UserDefaults.apiKey() == nil {
      Logger.info("First time user! showing welcome screen")
      let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "welcomeViewController")
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

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    if notificationSettings.types != [] {
      application.registerForRemoteNotifications()
    }
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushNotificationManager.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
  }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    Logger.info("Failed to register for remote notifications: \(error)")
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


}

