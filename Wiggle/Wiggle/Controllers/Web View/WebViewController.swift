//
//  WebViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 24.02.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import WebKit

protocol TermsViewDelegate {
    func acceptTapped()
    func declineTapped()
}

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var delegate:TermsViewDelegate?
    var isAcceptingTerms: Bool = true
    var webUrl:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        prepareViews()
    }
    
    func prepareViews() {
        if isAcceptingTerms {
            let acceptButton = UIBarButtonItem(title: "Accept", style: .plain, target: self, action: #selector(acceptTapped))
            self.navigationItem.rightBarButtonItem = acceptButton
            let declineButton = UIBarButtonItem(title: "Decline", style: .plain, target: self, action: #selector(declineTapped))
            self.navigationItem.leftBarButtonItem = declineButton
            let url = URL(string: "http://www.appwiggle.com/terms.html")!
            webView.load(URLRequest(url: url))
        }else {
            let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(acceptTapped))
            self.navigationItem.rightBarButtonItem = closeButton
            let url = URL(string: webUrl)!
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc func acceptTapped() {
        delegate?.acceptTapped()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(true, forKey: "TermsAccepted")
    }
    
    @objc func declineTapped() {
        delegate?.declineTapped()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "TermsAccepted")
    }
    
    @objc func closeTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate {
    
}


