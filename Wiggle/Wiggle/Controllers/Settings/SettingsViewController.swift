//
//  SettingsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 22.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var isChanged: Bool = false {
        didSet {
            rightBarButton.title = isChanged ? Localize.Common.Save : Localize.Common.Close
        }
    }
    var selectedDistance: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        transparentNavigationBar()
        initUpwardsAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startUpwardsAnimation()
    }

    func initUpwardsAnimation() {
        tableView.alpha = 0
        tableView.transform = CGAffineTransform(translationX: 0, y: 50)
    }
    
    func startUpwardsAnimation() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseIn], animations: {
            self.tableView.alpha = 1
            self.tableView.transform = CGAffineTransform.identity
        })
    }
    
    func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: SettingsPremiumTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SettingsPremiumTableViewCell.reuseIdentifier)
        tableView.register(UINib(nibName: BoostSuperLikeCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: BoostSuperLikeCell.reuseIdentifier)
        tableView.register(UINib(nibName: SettingWithLabelCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SettingWithLabelCell.reuseIdentifier)
        tableView.register(UINib(nibName: CellWithToggleCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: CellWithToggleCell.reuseIdentifier)
        tableView.register(UINib(nibName: SettingWithSliderCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SettingWithSliderCell.reuseIdentifier)
        tableView.register(UINib(nibName: LogoutCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: LogoutCell.reuseIdentifier)
        
    }
    
    func saveDistanceInfo() {
        if let distance = self.selectedDistance {
            AppConstants.Settings.SelectedDistance = distance
            UserDefaults.standard.set(distance, forKey: "MaximumDistance")
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        if isChanged {
            saveDistanceInfo()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func openWebView(url: String) {
        let storyBoard = UIStoryboard(name: "WebView", bundle: nil)
        let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.webUrl = url
        webViewController.isAcceptingTerms = false
        let nav = UINavigationController(rootViewController: webViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }else if section == 1 {
            return 1
        }else if section == 2 {
            return 2
        }else if section == 3 {
            return 3
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingsPremiumTableViewCell", for: indexPath) as! SettingsPremiumTableViewCell
                cell.prepare(type: .plus)
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "BoostSuperLikeCell", for: indexPath) as! BoostSuperLikeCell
                return cell
            }
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithLabelCell", for: indexPath) as! SettingWithLabelCell
            if indexPath.row == 0 {
                if let user = PFUser.current(), user.isFacebookLogin() {
                    cell.prepareCell(title: Localize.Settings.FacebookProfile, detail: "\(user.getFirstName()) \(user.getLastName())")
                    cell.arrowImage.isHidden = true
                }else {
                    if let user = PFUser.current() {
                        let phone = user.getUsername()
                        cell.prepareCell(title: Localize.Settings.PhoneNumber, detail: phone)
                    }
                }
            }
            return cell
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithSliderCell", for: indexPath) as! SettingWithSliderCell
                cell.delegate = self
                cell.prepareCell(title: Localize.Settings.MaxDistance)
                return cell 
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithLabelCell", for: indexPath) as! SettingWithLabelCell
                if AppConstants.Settings.SelectedShowMeGender == 1 {
                    cell.prepareCell(title: Localize.Gender.ShowMe, detail: Localize.Gender.Male)
                }else if AppConstants.Settings.SelectedShowMeGender == 2{
                    cell.prepareCell(title: Localize.Gender.ShowMe, detail: Localize.Gender.Female)
                }else {
                    cell.prepareCell(title: Localize.Gender.ShowMe, detail: Localize.Gender.Everyone)
                }
                return cell
            }else {
                return UITableViewCell()
            }
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.reuseIdentifier, for: indexPath) as! LogoutCell
            if indexPath.row == 0 {
                cell.prepareForWebView(title: "Terms Of Use")
            }else if indexPath.row == 1 {
                cell.prepareForWebView(title: "Privacy Policy")
            }else if indexPath.row == 2 {
                cell.prepareViews()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return Localize.Settings.AccountSettings
        }else if section == 2 {
            return Localize.Settings.Discovery
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 || section == 3 {
            return 50
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75.0
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                return 80.0
            }else {
                return 50.0
            }
        }else {
            return 50.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 60))
        let label = UILabel(frame: CGRect(x: 15.0, y: 0, width: tableView.bounds.size.width, height: 60))
        headerView.addSubview(label)
        label.font = FontHelper.regular(16)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            label.textColor = UIColor.gray
        }
        if section == 1 {
            label.text = Localize.Settings.AccountSettings
        }else if section == 2 {
            label.text = Localize.Settings.Discovery
        }
        headerView.backgroundColor = UIColor.clear

        return headerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        if indexPath.section == 0 && indexPath.row == 0{
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "InAppPurchaseViewController") as! InAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }else if indexPath.section == 0 && indexPath.row == 1{
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "SuperLikeInAppPurchase") as! SuperLikeInAppPurchaseViewController
            self.navigationController?.present(destionationViewController, animated: true, completion: {})
        }else if indexPath.section == 2 && indexPath.row == 1 {
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "ShowMeGenderViewController") as! ShowMeGenderViewController
            self.navigationController?.pushViewController(destionationViewController, animated: true)
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
                self.openWebView(url: "http://www.appwiggle.com/terms.html")
            }else if indexPath.row == 1 {
                self.openWebView(url: "http://www.appwiggle.com/privacy.html")
            }else {
                self.startAnimating(self.view, startAnimate: true)
                PFUser.logOutInBackground { (error) in
                    self.startAnimating(self.view, startAnimate: false)
                    if let error = error {
                        self.displayError(message: error.localizedDescription)
                    }else {
                        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.SessionToken)
                        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        delegate.initializeWindow()
                    }
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}

extension SettingsViewController: DistanceChanged {
    func maxDistanceChanged(value: Int) {
        isChanged = true
        self.selectedDistance = value
    }
}
