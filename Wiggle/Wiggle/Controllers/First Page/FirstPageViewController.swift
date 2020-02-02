//
//  FirstPageViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Parse

class FirstPageViewController: UIViewController {
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var phoneLoginButton: UIButton!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acceptTermsLabel.text = Localize.LoginSignup.AcceptTerms
        facebookLoginButton.setTitle(Localize.LoginSignup.FacebookButton, for: .normal)
        phoneLoginButton.setTitle(Localize.LoginSignup.PhoneButton, for: .normal)
        facebookLoginButton.layer.cornerRadius = 12.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func getFacebookInfo(success: @escaping() -> Void, fail: @escaping(String) -> Void) {
        let request = GraphRequest(graphPath:"me", parameters:["fields":"id,email,name,first_name,last_name,birthday,gender,picture"])
        
        // Send request to Facebook
        request.start { (connection, result, error) in
            if error != nil {
                fail(error?.localizedDescription ?? "")
            }
            else if let userData = result as? [String:AnyObject] {
                self.fillParseUserInfo(with: userData, success: {
                    success()
                }) { error in
                    self.displayError(message: error)
                }
            }
        }
    }
    
    func fillParseUserInfo(with userData: [String:AnyObject], success: @escaping() -> Void, fail: @escaping(String) -> Void) {
        
        let firstName = (userData["first_name"] as? String) ?? ""
        PFUser.current()?.setValue(firstName, forKey: "first_name")
        
        let lastName = (userData["last_name"] as? String) ?? ""
        PFUser.current()?.setValue(lastName, forKey: "last_name")
        
        if let pictureResponse = userData["picture"] as? [String:AnyObject], let pictureData = pictureResponse["data"] as? [String:AnyObject], let url = pictureData["url"] as? String, let imageUrl = URL(string: url) {
            if let data = try? Data(contentsOf: imageUrl)
            {
                do {
                    let image: UIImage = UIImage(data: data) ?? UIImage()
                    let imageData: NSData = image.jpegData(compressionQuality: 1.0)! as NSData
                    let imageFile: PFFileObject = PFFileObject(name:"image.jpg", data:imageData as Data)!
                    try imageFile.save()
                    PFUser.current()?.setObject(imageFile, forKey: "photo")
                }catch {
                    
                }
            }
        }
        PFUser.current()?.saveInBackground(block: { (result, error) in
            if let error = error {
                fail(error.localizedDescription)
            }else {
                success()
            }
        })
    }
    
    @IBAction func facebookLoginTapped(_ sender: Any) {
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile","email"]) {
            (user: PFUser?, error: Error?) in
            if let user = user {
                UserDefaults.standard.set(user.sessionToken ?? "", forKey: AppConstants.UserDefaultsKeys.SessionToken)
                if user.isNew {
                    self.startAnimating(self.view, startAnimate: true)
                    self.getFacebookInfo(success: {
                        self.startAnimating(self.view, startAnimate: false)
                        self.moveToGetNameViewController()
                    }) { (error) in
                        self.startAnimating(self.view, startAnimate: false)
                        self.displayError(message: error)
                    }
                } else {
                    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    delegate.initializeWindow()
                }
            } else {
                
            }
        }
    }
    @IBAction func phoneLoginTapped(_ sender: Any) {
        if PFUser.current() != nil {
            self.moveToHomeViewController(navigationController: self.navigationController ?? UINavigationController())
            //            PFUser.logOutInBackground { (error) in
            //                if error != nil {
            //                    self.displayError(message: "Lutfen tekrar deneyiniz.")
            //                }else {
            //                    self.moveToEnterPhoneViewController()
            //                }
            //            }
        }else {
            moveToEnterPhoneViewController()
        }
    }
}
