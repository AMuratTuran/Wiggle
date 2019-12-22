//
//  AppDelegate.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Parse configuration
        
        configureBackButton()
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = AppConstants.ParseConstants.ApplicationId
            $0.clientKey = AppConstants.ParseConstants.ClientKey
            $0.server = AppConstants.ParseConstants.Server
        }
        
        Parse.initialize(with: parseConfig)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        // Facebook SDK configuration
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        registerForPushNotifications(application)
        return true
    }
    
    func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func configureBackButton() {
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        let attributes = [NSAttributedString.Key.font:  UIFont(name: "OpenSans-Bold", size: 0.1)!, NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        barButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
    }
    // Handle Facebook authorization URLs
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        )
    }
    
    //Make sure it isn't already declared in the app delegate (possible redefinition of func error)
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEvents.activateApp()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 1. Convert device token to string
        let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        print("Device Token: \(token)")
        let bundleID = Bundle.main.bundleIdentifier;
        print("Bundle ID: \(token) \(bundleID)");
        // 3. Save the token to local storeage and post to app server to generate Push Notification. ...
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        let aps = userInfo["aps"] as! [String: Any]
        print("\(aps)")
        PFPush.handle(userInfo)
    }
}

extension AppDelegate {
    func initializeWindow() {
        let w = UIWindow()
        
        if let _ = UserDefaults.standard.value(forKey: AppConstants.UserDefaultsKeys.SessionToken) {
             let homeStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                   let destinationViewController = homeStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            w.rootViewController = destinationViewController
            w.frame = UIScreen.main.bounds
            w.backgroundColor = UIColor.black
            w.makeKeyAndVisible()
            self.window = w
        } else {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "FirstPageViewController") as! FirstPageViewController
            let nav = UINavigationController(rootViewController: destinationViewController)
            w.rootViewController = nav
            w.frame = UIScreen.main.bounds
            w.backgroundColor = UIColor.black
            w.makeKeyAndVisible()
            self.window = w
        }
    }
}
