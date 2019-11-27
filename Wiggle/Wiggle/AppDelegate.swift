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
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = "EfuNJeqL484fqElyGcCuiTBjNHalE2BhAP2LIv7s"
            $0.clientKey = "L22P6I1Hxd3WMf8QT0umoy1HRuQit97Zd5i5HCjG"
            $0.server = "https://parseapi.back4app.com/"
        }
        Parse.initialize(with: parseConfig)
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)
        // Facebook SDK configuration
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
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
}

