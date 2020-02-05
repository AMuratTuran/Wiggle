//
//  UIViewController + Extensions.swift
//  Wiggle
//
//  Created by Murat Turan on 19.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Hero
import Parse
import SwiftMessages

extension UIViewController {
    
    func initializeMainTabBar() {
        let homeStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = homeStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        self.navigationController?.viewControllers.removeAll()
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToFirstPageViewController () {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "FirstPageViewController") as! FirstPageViewController
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToEnterPhoneViewController() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "EnterPhoneViewController") as! EnterPhoneViewController
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToEnterVerificationCodeViewController(smsCode: Int,countryCode: String, phone: String) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "EnterVerificationCodeViewController") as! EnterVerificationCodeViewController
        destinationViewController.sentSMSCode = smsCode
        destinationViewController.countryCode = countryCode
        destinationViewController.phoneNumber = phone
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToGetNameViewController() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "GetNameViewController") as! GetNameViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToGenderViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "GenderViewController") as! GenderViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToGetBioViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "GetBioViewController") as! GetBioViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToPickImageViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "PickImageViewController") as! PickImageViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToBirthdayViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "BirthdayViewController") as! BirthdayViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToEnableLocationViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "EnableLocationViewController") as! EnableLocationViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToEnableNotificationsViewController(navigationController: UINavigationController) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = mainStoryBoard.instantiateViewController(withIdentifier: "EnableNotificationsViewController") as! EnableNotificationsViewController
        destinationViewController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToHomeViewController(navigationController: UINavigationController) {
        let homeStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = homeStoryboard.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func moveToProfileViewController() {
        let profileStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let destinationViewController = profileStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        destinationViewController.isHeroEnabled = true
        destinationViewController.heroModalAnimationType = .zoomSlide(direction: .right)
        if let nc = self.navigationController {
            nc.hero_replaceViewController(with: destinationViewController)
        }else {
            self.hero_replaceViewController(with: destinationViewController)
        }
        
    }
    
    func moveToHomeViewControllerFromProfile() {
        let homeStoryboard: UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let destinationViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        destinationViewController.isHeroEnabled = true
        destinationViewController.heroModalAnimationType = .zoomSlide(direction: .left)
        self.hero_replaceViewController(with: destinationViewController)
    }
    
    func moveToSettingsViewController() {
        let settingsStoryboard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let destinationViewController = settingsStoryboard.instantiateInitialViewController() as! UINavigationController
        self.present(destinationViewController, animated: true, completion: nil)
    }
    
    func moveToProfileDetailViewController(data : WiggleCardModel) {
        let profileStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let destinationViewController = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
        destinationViewController.isHeroEnabled = true
        destinationViewController.modalPresentationStyle = .fullScreen
        destinationViewController.wiggleCardModel = data
        self.present(destinationViewController, animated: true, completion: nil)
    }
    
    func moveToProfileDetailFromWhoLiked(data: PFUser, index: Int) {
        let profileStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
        let destinationViewController = profileStoryboard.instantiateViewController(withIdentifier: "ProfileDetailViewController") as! ProfileDetailViewController
        destinationViewController.hero.isEnabled = true
        destinationViewController.modalPresentationStyle = .fullScreen
        destinationViewController.userData = data
        destinationViewController.indexOfParentCell = index
        self.present(destinationViewController, animated: true, completion: nil)
    }
    
    func moveToHomeViewControllerFromProfileDetail() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func moveToChatListViewController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = UIWindow()
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let destinationViewController = chatStoryboard.instantiateInitialViewController() as! UINavigationController
        window.rootViewController = destinationViewController
        window.frame = UIScreen.main.bounds
        window.backgroundColor = UIColor.black
        window.makeKeyAndVisible()
        appDelegate.window = window
    }
    
    func moveToMatchResultsViewController(result: HeartRateKitResult) {
        let storyboard = UIStoryboard(name: "Heartbeat", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "MatchResultsViewController") as! MatchResultsViewController
        destinationVC.result = result 
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
    func addMessageIconToNavigationBar() {
        let messageImage = UIImage(named: "icon_smartsearch_message")
        let messageBT = UIBarButtonItem(image: messageImage, style: .plain, target: self, action: #selector(messageTapped))
        navigationItem.rightBarButtonItems = [messageBT]
    }
    
    @objc private func messageTapped() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.fade
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let chatListVC = storyboard.instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(chatListVC, animated: true)
    }
    
    
    func displayError(message: String) {
        let alertController = UIAlertController(title: Localize.Common.Error, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: Localize.Common.OKButton, style: .destructive, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func hideBackBarButtonTitle() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
}


extension UIViewController {
    func getCountryPhoneCode(_ country : String) -> String{
        let countryDictionary  = ["AF":"93",
                                  "AL":"355",
                                  "DZ":"213",
                                  "AS":"1",
                                  "AD":"376",
                                  "AO":"244",
                                  "AI":"1",
                                  "AG":"1",
                                  "AR":"54",
                                  "AM":"374",
                                  "AW":"297",
                                  "AU":"61",
                                  "AT":"43",
                                  "AZ":"994",
                                  "BS":"1",
                                  "BH":"973",
                                  "BD":"880",
                                  "BB":"1",
                                  "BY":"375",
                                  "BE":"32",
                                  "BZ":"501",
                                  "BJ":"229",
                                  "BM":"1",
                                  "BT":"975",
                                  "BA":"387",
                                  "BW":"267",
                                  "BR":"55",
                                  "IO":"246",
                                  "BG":"359",
                                  "BF":"226",
                                  "BI":"257",
                                  "KH":"855",
                                  "CM":"237",
                                  "CA":"1",
                                  "CV":"238",
                                  "KY":"345",
                                  "CF":"236",
                                  "TD":"235",
                                  "CL":"56",
                                  "CN":"86",
                                  "CX":"61",
                                  "CO":"57",
                                  "KM":"269",
                                  "CG":"242",
                                  "CK":"682",
                                  "CR":"506",
                                  "HR":"385",
                                  "CU":"53",
                                  "CY":"537",
                                  "CZ":"420",
                                  "DK":"45",
                                  "DJ":"253",
                                  "DM":"1",
                                  "DO":"1",
                                  "EC":"593",
                                  "EG":"20",
                                  "SV":"503",
                                  "GQ":"240",
                                  "ER":"291",
                                  "EE":"372",
                                  "ET":"251",
                                  "FO":"298",
                                  "FJ":"679",
                                  "FI":"358",
                                  "FR":"33",
                                  "GF":"594",
                                  "PF":"689",
                                  "GA":"241",
                                  "GM":"220",
                                  "GE":"995",
                                  "DE":"49",
                                  "GH":"233",
                                  "GI":"350",
                                  "GR":"30",
                                  "GL":"299",
                                  "GD":"1",
                                  "GP":"590",
                                  "GU":"1",
                                  "GT":"502",
                                  "GN":"224",
                                  "GW":"245",
                                  "GY":"595",
                                  "HT":"509",
                                  "HN":"504",
                                  "HU":"36",
                                  "IS":"354",
                                  "IN":"91",
                                  "ID":"62",
                                  "IQ":"964",
                                  "IE":"353",
                                  "IL":"972",
                                  "IT":"39",
                                  "JM":"1",
                                  "JP":"81",
                                  "JO":"962",
                                  "KZ":"77",
                                  "KE":"254",
                                  "KI":"686",
                                  "KW":"965",
                                  "KG":"996",
                                  "LV":"371",
                                  "LB":"961",
                                  "LS":"266",
                                  "LR":"231",
                                  "LI":"423",
                                  "LT":"370",
                                  "LU":"352",
                                  "MG":"261",
                                  "MW":"265",
                                  "MY":"60",
                                  "MV":"960",
                                  "ML":"223",
                                  "MT":"356",
                                  "MH":"692",
                                  "MQ":"596",
                                  "MR":"222",
                                  "MU":"230",
                                  "YT":"262",
                                  "MX":"52",
                                  "MC":"377",
                                  "MN":"976",
                                  "ME":"382",
                                  "MS":"1",
                                  "MA":"212",
                                  "MM":"95",
                                  "NA":"264",
                                  "NR":"674",
                                  "NP":"977",
                                  "NL":"31",
                                  "AN":"599",
                                  "NC":"687",
                                  "NZ":"64",
                                  "NI":"505",
                                  "NE":"227",
                                  "NG":"234",
                                  "NU":"683",
                                  "NF":"672",
                                  "MP":"1",
                                  "NO":"47",
                                  "OM":"968",
                                  "PK":"92",
                                  "PW":"680",
                                  "PA":"507",
                                  "PG":"675",
                                  "PY":"595",
                                  "PE":"51",
                                  "PH":"63",
                                  "PL":"48",
                                  "PT":"351",
                                  "PR":"1",
                                  "QA":"974",
                                  "RO":"40",
                                  "RW":"250",
                                  "WS":"685",
                                  "SM":"378",
                                  "SA":"966",
                                  "SN":"221",
                                  "RS":"381",
                                  "SC":"248",
                                  "SL":"232",
                                  "SG":"65",
                                  "SK":"421",
                                  "SI":"386",
                                  "SB":"677",
                                  "ZA":"27",
                                  "GS":"500",
                                  "ES":"34",
                                  "LK":"94",
                                  "SD":"249",
                                  "SR":"597",
                                  "SZ":"268",
                                  "SE":"46",
                                  "CH":"41",
                                  "TJ":"992",
                                  "TH":"66",
                                  "TG":"228",
                                  "TK":"690",
                                  "TO":"676",
                                  "TT":"1",
                                  "TN":"216",
                                  "TR":"90",
                                  "TM":"993",
                                  "TC":"1",
                                  "TV":"688",
                                  "UG":"256",
                                  "UA":"380",
                                  "AE":"971",
                                  "GB":"44",
                                  "US":"1",
                                  "UY":"598",
                                  "UZ":"998",
                                  "VU":"678",
                                  "WF":"681",
                                  "YE":"967",
                                  "ZM":"260",
                                  "ZW":"263",
                                  "BO":"591",
                                  "BN":"673",
                                  "CC":"61",
                                  "CD":"243",
                                  "CI":"225",
                                  "FK":"500",
                                  "GG":"44",
                                  "VA":"379",
                                  "HK":"852",
                                  "IR":"98",
                                  "IM":"44",
                                  "JE":"44",
                                  "KP":"850",
                                  "KR":"82",
                                  "LA":"856",
                                  "LY":"218",
                                  "MO":"853",
                                  "MK":"389",
                                  "FM":"691",
                                  "MD":"373",
                                  "MZ":"258",
                                  "PS":"970",
                                  "PN":"872",
                                  "RE":"262",
                                  "RU":"7",
                                  "BL":"590",
                                  "SH":"290",
                                  "KN":"1",
                                  "LC":"1",
                                  "MF":"590",
                                  "PM":"508",
                                  "VC":"1",
                                  "ST":"239",
                                  "SO":"252",
                                  "SJ":"47",
                                  "SY":"963",
                                  "TW":"886",
                                  "TZ":"255",
                                  "TL":"670",
                                  "VE":"58",
                                  "VN":"84",
                                  "VG":"284",
                                  "VI":"340"]
        if countryDictionary[country] != nil {
            return "+\(countryDictionary[country]!)"
        }else {
            return ""
        }
    }
}

extension UIViewController {
    func transparentNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .white
    }
    
    func addProductLogoToNavigationBar(selector: Selector? = nil, logoName: String = "labeled-wiggle-logo") {
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
//        let image = UIImage(named: logoName)
//        button.setImage(image, for: .normal)
//        button.setImage(image, for: .highlighted)
//        button.setImage(image, for: .disabled)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.isEnabled = false
//
//        if let selector = selector {
//            button.isEnabled = true
//            button.addTarget(self, action: selector, for: .touchUpInside)
//        }
//        navigationItem.titleView = button
        navigationItem.title = "wiggle"
    }
}
