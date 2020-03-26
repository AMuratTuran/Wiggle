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
import AuthenticationServices
import PopupDialog

class FirstPageViewController: UIViewController {
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var phoneLoginButton: UIButton!
    @IBOutlet weak var acceptTermsLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func prepareViews() {
        self.view.setGradientBackground()
        
        facebookLoginButton.setTitle(Localize.LoginSignup.FacebookButton, for: .normal)
        phoneLoginButton.setTitle(Localize.LoginSignup.EmailButton, for: .normal)
        facebookLoginButton.layer.cornerRadius = 12.0
        acceptTermsLabel.text = Localize.LoginSignup.AcceptTerms
        
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttonsStackView.addArrangedSubview(facebookLoginButton)
        buttonsStackView.addArrangedSubview(phoneLoginButton)
        setUpSignInAppleButton()
        buttonsStackView.addArrangedSubview(acceptTermsLabel)
    }
    
    func setUpSignInAppleButton() {
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton()
            authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
            authorizationButton.cornerRadius = 12
            let heightConstraint = NSLayoutConstraint(item: authorizationButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
            authorizationButton.addConstraints([heightConstraint])
            self.buttonsStackView.addArrangedSubview(authorizationButton)
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
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
    
    @available(iOS 13.0, *)
    func startAppleLogin(userId: String, credential: ASAuthorizationAppleIDCredential) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: userId) {  (credentialState, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    self.connectParseWithApple(credential: credential)
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                    let okButton = DefaultButton(title: Localize.Common.OKButton, action: nil)
                    self.alertMessage(message: "No credential was found. Please create an AppleID to use Apple Login.", buttons: [okButton], isErrorMessage: true)
                default:
                    break
                }
            }
    }
    
    @available(iOS 13.0, *)
    func connectParseWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let token = credential.identityToken else { return }
        self.createNewAppleUser(credential: credential)
        //        PFUser.register(AuthDelegate(), forAuthType: "apple")
        //        PFUser.logInWithAuthType(inBackground: "apple", authData: ["token": String(data: token, encoding: .utf8)!, "id": credential.user]).continueWith { task -> Any? in
        //            if ((task.error) != nil){
        //                print("ERROR: \(task.error?.localizedDescription ?? "")")
        //
        //                self.createNewAppleUser(credential: credential)
        //
        //                return task
        //
        //            }
        //            if task.result != nil {
        //                DispatchQueue.main.async {
        //                    self.moveToGetNameViewController()
        //                }
        //            } else {
        //                // Failed to log in.
        //                print("ERROR LOGGING IN IN PARSE: \(task.error?.localizedDescription ?? "")")
        //            }
        //            return nil
        //        }
    }
    
    @available(iOS 13.0, *)
    func createNewAppleUser(credential: ASAuthorizationAppleIDCredential) {
        loginUser(credential: credential)
    }
    
    @available(iOS 13.0, *)
    func signupUser(credential: ASAuthorizationAppleIDCredential) {
        let user = PFUser()
        user.username = credential.user
        user.password = "myPassword"
        user.signUpInBackground { (result, error) in
            if let error = error {
                self.loginUser(credential: credential)
            }
            
            if result {
                self.loginUser(credential: credential)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func loginUser(credential: ASAuthorizationAppleIDCredential) {
        PFUser.logInWithUsername(inBackground: credential.user, password: "myPassword") { (user, error) in
            if let error = error {
                if error.localizedDescription.contains("Invalid username") {
                    self.signupUser(credential: credential)
                }
            }
            
            guard let userInfo = user else {
                return
            }
            UserDefaults.standard.set(userInfo.sessionToken, forKey: AppConstants.UserDefaultsKeys.SessionToken)
            
            if let _ = userInfo["gender"] as? Int, let userName = userInfo["first_name"] as? String {
                if userName.isEmpty {
                    DispatchQueue.main.async {
                        self.moveToGetNameViewController()
                    }
                }else {
                    DispatchQueue.main.async {
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        delegate.initializeWindow()
                    }
                }
            }else {
                DispatchQueue.main.async {
                    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    delegate.initializeWindow()
                }
                
            }
            
        }
    }
    @IBAction func facebookLoginTapped(_ sender: Any) {
        LoginManager().logOut()
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

@available(iOS 13.0, *)
extension FirstPageViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
            startAppleLogin(userId: userIdentifier, credential: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}


class AuthDelegate:NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }
    
    func restoreAuthenticationWithAuthData(authData: [String : String]?) -> Bool {
        return true
    }
}
