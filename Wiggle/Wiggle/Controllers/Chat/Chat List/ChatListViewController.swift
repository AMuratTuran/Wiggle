//
//  ChatListViewController.swift
//  Wiggle
//
//  Created by Murat Turan on 7.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lineView: UIView!
    
    var matchedUsers: [PFUser]?
    var currentUser: PFUser!
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
           return searchController.searchBar.text?.isEmpty ?? true
    }
    var data: [Chat]?
    var tableData: [ChatListModel]?
    var userId: String? {
        if let currentUser = PFUser.current() {
            return currentUser.objectId
        }
        return nil
    }
    var subscription: Subscription<PFObject>?
    var liveQueryClient: ParseLiveQuery.Client!
    let query = PFQuery(className:"Messages")
    let matchesView = MatchScrollView.instanceFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = PFUser.current() else {
            return
            // navigate to login
        }
        self.currentUser = currentUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initUpwardsAnimation()
        navigationController?.navigationBar.prefersLargeTitles = true
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview()}
        stackView.insertArrangedSubview(matchesView, at: 0)
        stackView.insertArrangedSubview(lineView, at: 1)
        stackView.addArrangedSubview(tableView)
        getChatList()
        getMatchedUsers()
    }
    
    func getMatchedUsers() {
        NetworkManager.getMatchedUsers(success: { (response) in
            self.matchedUsers = response
            self.matchesView.prepare(with: self.matchedUsers ?? [])
        }) { (error) in
            
        }
    }
    func updateChatList() {
        NetworkManager.getChatList(success: { (response) in
            self.data = response
            self.getUserInfo()
        }) { (error) in
            
        }
    }
    
    func getChatList() {
        self.startAnimating(self.view, startAnimate: true)
        NetworkManager.getChatList(success: { (response) in
            self.data = response
            self.getUserInfo()
        }) { (error) in
            self.startAnimating(self.view, startAnimate: false)
        }
    }
    
    func getUserInfo() {
        guard let data = data else { return }
        var tableData: [ChatListModel] = []
        
        data.forEach { chat in
            let id: String = chat.getReceiverId()
            NetworkManager.queryUsersById(id, success: { (user) in
                let chatListModel = ChatListModel(user: user, chat: chat)
                tableData.append(chatListModel)
                if tableData.count == data.count{
                    let sortedDate = tableData.sorted {
                        $0.createdAt > $1.createdAt
                    }
                    self.tableData = sortedDate
                    self.tableView.reloadData()
                    self.startUpwardsAnimation()
                }
            }) { (error) in
                
            }
        }
        self.startAnimating(self.view, startAnimate: false)
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseIn], animations: {
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
        guard let data = tableData else { return 0 }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = self.tableData else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.reuseIdentifier, for: indexPath) as! ChatListCell
        cell.prepare(with: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = tableData else { return }
        tableView.deselectRow(at: indexPath, animated: false)
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        destinationViewController.contactedUser = data[indexPath.row]
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete Chat") { _, _ in
        }
        delete.backgroundColor = UIColor.systemRed
        
        return [delete]
    }
    
}

extension ChatListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}
