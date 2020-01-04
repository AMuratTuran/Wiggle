//
//  AppDelegate + Notification.swift
//  Wiggle
//
//  Created by Murat Turan on 3.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import SwiftMessages

extension AppDelegate {
    
    func presentTopMessage(aps: [String:AnyObject], title: String, body: String) {
        let view: InAppBannerView = try! SwiftMessages.viewFromNib(named: "InAppBannerView")
        view.backgroundColor = .clear
        view.configureDropShadow()
        let messageTitle = (aps["alert"] as? String) ?? ""
        view.configure(title: "New Message", body: messageTitle)
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10
        SwiftMessages.pauseBetweenMessages = 1.0
        if  (window?.rootViewController as? UITabBarController)?.selectedIndex != 1 {
            SwiftMessages.show(view: view)
        }else if let chatListNavigationViewController = (window?.rootViewController as? UITabBarController)?.selectedViewController as? UINavigationController {
            let vc = chatListNavigationViewController.topViewController as? ChatListViewController
            vc?.updateChatList()
        }
    }
}
