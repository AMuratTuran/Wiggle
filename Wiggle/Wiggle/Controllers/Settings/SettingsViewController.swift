//
//  SettingsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 22.11.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initUpwardsAnimation()
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
    
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else if section == 1 {
            return 2
        }else if section == 2 {
            return 5
        }else if section == 3 {
            return 1
        }else if section == 4 {
            return 1
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingsPremiumTableViewCell", for: indexPath) as! SettingsPremiumTableViewCell
                cell.prepare(type: .gold)
                return cell
            }else if indexPath.row == 1{
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
                cell.prepareCell(title: "Phone Number", detail: "905395773787")
            }else {
                cell.prepareCell(title: "Email", detail: "0muratturan@gmail.com")
            }
            return cell
        }else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithLabelCell", for: indexPath) as! SettingWithLabelCell
                cell.prepareCell(title: "Location", detail: "My Current Location")
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithSliderCell", for: indexPath) as! SettingWithSliderCell
                cell.prepareCell(title: "Maximum Distance")
                return cell 
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithLabelCell", for: indexPath) as! SettingWithLabelCell
                cell.prepareCell(title: "Show Me", detail: "Women")
                return cell
            }else if indexPath.row == 3 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithSliderCell", for: indexPath) as! SettingWithSliderCell
                cell.prepareCell(title: "Age Range")
                return cell
            }else if indexPath.row == 4 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "CellWithToggleCell", for: indexPath) as! CellWithToggleCell
                cell.prepareCell(title: "Show me on Wiggle")
                return cell
            }else {
                return UITableViewCell()
            }
        }else if indexPath.section == 3 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingWithLabelCell", for: indexPath) as! SettingWithLabelCell
                cell.prepareCell(title: "Push Notifications", detail: "")
                return cell
            }
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.reuseIdentifier, for: indexPath) as! LogoutCell
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Account Settings"
        }else if section == 2 {
            return "Discovery"
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 || section == 3 || section == 4{
            return 50
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75.0
        }else if indexPath.section == 2 {
            if indexPath.row == 1 || indexPath.row == 3 {
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
        label.textColor = UIColor(hexString: "4a4a4a")
        if section == 1 {
            label.text = "Account Settings"
        }else if section == 2 {
            label.text = "Discovery"
        }else if section == 3 {
            label.text = "Notifications"
        }
        headerView.backgroundColor = UIColor.clear

        return headerView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        if indexPath.section == 2 && indexPath.row == 2 {
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "ShowMeGenderViewController") as! ShowMeGenderViewController
            self.navigationController?.pushViewController(destionationViewController, animated: true)
        }else if indexPath.section == 3 {
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "NotificationSettingsViewController") as! NotificationSettingsViewController
            self.navigationController?.pushViewController(destionationViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
