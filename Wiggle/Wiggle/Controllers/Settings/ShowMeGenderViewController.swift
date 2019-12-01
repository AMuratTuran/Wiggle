//
//  ShowMeGenderViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 1.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class ShowMeGenderViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var genders: [String] = ["Women", "Men", "Everyone"]
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        navigationItem.largeTitleDisplayMode = .never
    }
    
    func configureViews() {
        self.title = "Show Me"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LabelWithCheckmarkCell", bundle: nil), forCellReuseIdentifier: "LabelWithCheckmarkCell")
    }
}

extension ShowMeGenderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelWithCheckmarkCell", for: indexPath) as! LabelWithCheckmarkCell
        cell.prepareCell(title: genders[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 60))
        let label = UILabel(frame: CGRect(x: 15.0, y: 30, width: tableView.bounds.size.width, height: 21))
        headerView.addSubview(label)
        label.textColor = UIColor(hexString: "4a4a4a")
        
        label.text = "Show Me"
        
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .none{
                cell.accessoryType = .checkmark
            }else {
                cell.accessoryType = .none
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
