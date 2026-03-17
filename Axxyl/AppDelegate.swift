//
//  AppDelegate.swift
//  Axxyl
//
//  Created by Bajirao Bhosale on 17/09/22.
//

import UIKit
import UserNotifications
import Reachability
import FirebaseCore
import FirebaseMessaging
import IQKeyboardManagerSwift
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    let reachability = try! Reachability()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        loadLanding()
        window?.makeKeyAndVisible()
        registerForPushNotifications()
        startReachability()
        IQKeyboardManager.shared.enable = true
        StripeAPI.defaultPublishableKey = "pk_test_51T7RrFPeNGecK3XbFn0yUp2mDGBsjPYypbghIgMi250ivrSrhsdmICEQl5HmTtKEXlzLc639ap5R8qYyl1ngOwaQ00RDSHtpLq"
      //  ConsoleOverlay.shared.enable()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        reachability.stopNotifier()
    }
    
    func loadHome() {
        let maianStoryBoard = UIStoryboard(name: "Home", bundle: nil)

        let homeNavController = maianStoryBoard.instantiateViewController(withIdentifier: "HomeNavViewController") as! UINavigationController
        window?.rootViewController = homeNavController
    }
    
    func loadLanding() {
        let maianStoryBoard = UIStoryboard(name: "Main", bundle: nil)
         let landingNavController = maianStoryBoard.instantiateViewController(withIdentifier: "GetStartedNavViewController") as! UINavigationController
        window?.rootViewController = landingNavController
    }
    
    func startReachability() {
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            AlertManager.showErrorAlert(message: "The internet is not reachable.")
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

// MARK:- Push notification
extension AppDelegate {

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
          }
    }

    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        print("Device Token: \(token)")
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    // Handles background / silent pushes
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("did receive remote notification :  \(userInfo)")
        APNNotificationService.instance.parseRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
    
    // Handles pushes while the app is in the FOREGROUND
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("did receive foreground remote notification: \(userInfo)")
        APNNotificationService.instance.parseRemoteNotification(userInfo: userInfo)
        
        // Hide the OS banner for 'arrivalNotify' because we just want the app to transition screens silently
        if let msgType = userInfo["msgType"] as? String, msgType == "arrivalNotify" {
            print("Suppressing OS banner for arrivalNotify since we handle it in-app.")
            completionHandler([])
            return
        }
        
        // Show banner and play sound even if app is in foreground for other notifications
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("firebase didReceiveRegistrationToken : \(String(describing: fcmToken))")
        UserDefaults.standard.set(fcmToken, forKey: AppUserDefaultsKeys.deviceToken)
    }
}

extension AppDelegate {
    struct Constants {
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
    }
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: Constants.CFBundleShortVersionString) as! String
    }
  
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
  
    class func appVersionBuild() -> String {
        let version = appVersion(), build = appBuild()
      
        return version == build ? "\(version)" : "\(version)-\(build)"
    }
}
