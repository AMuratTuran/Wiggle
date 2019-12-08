//
//  ChatListViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 7.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
           return searchController.searchBar.text?.isEmpty ?? true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareViews()
        startUpwardsAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        initUpwardsAnimation()
    }
    
    func prepareViews() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        self.navigationItem.hidesSearchBarWhenScrolling = true
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ChatListCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ChatListCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
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
    
    private func filterContentForSearchText(_ searchText: String) {
//        guard let data = data else { return }
//        filteredEmployees = data.employeeList.filter { (employee: Employee) -> Bool in
//            return employee.getFullName().lowercased().contains(searchText.lowercased())
//        }
//
//        tableView.reloadData()
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.reuseIdentifier, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
}

extension ChatListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}
