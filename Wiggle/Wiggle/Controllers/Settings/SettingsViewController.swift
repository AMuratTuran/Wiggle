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
    
    func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SettingsPremiumTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsPremiumTableViewCell")
        tableView.register(UINib(nibName: "BoostSuperLikeCell", bundle: nil), forCellReuseIdentifier: "BoostSuperLikeCell")
        tableView.register(UINib(nibName: "SettingWithLabelCell", bundle: nil), forCellReuseIdentifier: "SettingWithLabelCell")
        tableView.register(UINib(nibName: "CellWithToggleCell", bundle: nil), forCellReuseIdentifier: "CellWithToggleCell")
        tableView.register(UINib(nibName: "SettingWithSliderCell", bundle: nil), forCellReuseIdentifier: "SettingWithSliderCell")
        
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
                cell.accessoryType = .disclosureIndicator
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
                cell.accessoryType = .disclosureIndicator
                cell.prepareCell(title: "Push Notifications", detail: "")
                return cell
            }
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
        if section == 1 || section == 2 || section == 3{
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
        if indexPath.section == 2 && indexPath.row == 2 {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let destionationViewController = storyboard.instantiateViewController(withIdentifier: "ShowMeGenderViewController") as! ShowMeGenderViewController
            self.navigationController?.pushViewController(destionationViewController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
