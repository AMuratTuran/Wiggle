//
//  SafariDelegate.swift
//  Wiggle
//
//  Created by Murat Turan on 22.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

protocol SafariDelegate {
    func presentSafari(urlString: String)
}

final class SafariManager: NSObject, SafariDelegate {
    weak var viewController: UIViewController!
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentSafari(urlString: String) {
        guard var url = URL(string: urlString) else {
            return
        }
        if !["http", "https"].contains(url.scheme?.lowercased()) {
            let httpString = "http://\(urlString)"
            url = URL(string: httpString)!
        }
        let vc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
        vc.delegate = self
        viewController.present(vc, animated: true)
    }
    
}

extension SafariManager: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        viewController.dismiss(animated: true)
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
    }
}
