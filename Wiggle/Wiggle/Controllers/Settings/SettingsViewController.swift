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
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SettingsPremiumTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsPremiumTableViewCell")
        
    }
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingsPremiumTableViewCell", for: indexPath) as! SettingsPremiumTableViewCell
            cell.prepare(type: .gold)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier:  "SettingsPremiumTableViewCell", for: indexPath) as! SettingsPremiumTableViewCell
            cell.prepare(type: .plus)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    
}
