//
//  NotificationSettingsViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 8.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class NotificationSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
    }
    
    func prepareViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: CellWithToggleCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: CellWithToggleCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
        self.navigationItem.largeTitleDisplayMode = .never
    }
}

extension NotificationSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellWithToggleCell.reuseIdentifier, for: indexPath) as! CellWithToggleCell
        if indexPath.row == 0 {
            cell.prepareCell(title: "New Matches")
        }else if indexPath.row == 1 {
            cell.prepareCell(title: "Messages")
        }else if indexPath.row == 2 {
            cell.prepareCell(title: "Super Likes")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
