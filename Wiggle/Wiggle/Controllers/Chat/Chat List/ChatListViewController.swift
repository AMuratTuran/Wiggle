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
    
    var matchedUsers: [PFUser]?
    var currentUser: PFUser!
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    var data: [Chat]?
    var tableData: [ChatListModel]? = nil
    var filteredChats: [ChatListModel]?
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
        self.title = Localize.Chat.Chats
        guard let currentUser = PFUser.current() else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        self.hidesBottomBarWhenPushed = true
        self.currentUser = currentUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initUpwardsAnimation()
        hideBackBarButtonTitle()
        navigationController?.navigationBar.prefersLargeTitles = true
        getChatList()
        getMatchedUsers()
    }
    
    func getMatchedUsers() {
        NetworkManager.getMatchedUsers(success: { (response) in
            self.matchedUsers = response
            self.matchesView.prepare(with: self.matchedUsers ?? [], delegate: self)
        }) { (error) in
            self.matchesView.prepare(delegate: self)
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
        if data.isEmpty {
            self.tableData = []
        }
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
                    DispatchQueue.main.async {
                        self.startUpwardsAnimation()
                        self.tableView.reloadData()
                    }
                }
            }) { (error) in
                
            }
        }
        self.tableView.reloadData()
        self.startUpwardsAnimation()
        self.startAnimating(self.view, startAnimate: false)
    }
    
    func prepareViews() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: ChatListCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: ChatListCell.reuseIdentifier)
        tableView.register(UINib(nibName: EmptyCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: EmptyCell.reuseIdentifier)
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
        guard let data = tableData else { return }
        filteredChats = data.filter { (chatModel: ChatListModel) -> Bool in
            return chatModel.getFullName().lowercased().contains(searchText.lowercased()) || chatModel.lastMessage.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = tableData else { return 0 }
        if data.isEmpty {
            return 1
        }
        if isFiltering {
            return filteredChats?.count ?? 0
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = self.tableData else { return UITableViewCell() }
        if data.count == 0 {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: EmptyCell.reuseIdentifier, for: indexPath) as! EmptyCell
            emptyCell.prepare(icon: UIImage(named: "emptyCellImage") ?? UIImage(), description: Localize.Chat.EmptyChatScreenMessage, isButtonVisible: true, buttonText: Localize.Chat.BackToHomeScreen, buttonAction: {
                self.navigationController?.popViewController(animated: true)
            })
            return emptyCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.reuseIdentifier, for: indexPath) as! ChatListCell
        let chat: ChatListModel
        if isFiltering, let filteredChats = filteredChats {
            chat = filteredChats[indexPath.row]
        } else {
            chat = data[indexPath.row]
        }
        cell.prepare(with: chat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let data = self.tableData else { return 0 }
        if data.count == 0 {
            return self.tableView.frame.height
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let data = tableData, !data.isEmpty else { return }
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        let chat: ChatListModel
        if isFiltering, let filteredChats = filteredChats {
            chat = filteredChats[indexPath.row]
        } else {
            chat = data[indexPath.row]
        }
        destinationViewController.contactedUser = chat
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let data = tableData, !data.isEmpty else { return nil}
        
        let delete = UITableViewRowAction(style: .normal, title: Localize.Chat.DeleteChat) { (action, indexPath) in
            let chat: ChatListModel
            if self.isFiltering, let filteredChats = self.filteredChats {
                chat = filteredChats[indexPath.row]
            } else {
                chat = data[indexPath.row]
            }
            self.startAnimating(self.view, startAnimate: true)
            NetworkManager.deleteChat(chat: chat, success: {
                self.getChatList()
            }) { (error) in
                self.getChatList()
            }
        }
        delete.backgroundColor = UIColor.systemRed
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard tableData != nil else { return nil}
        return matchesView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
}

extension ChatListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text ?? "")
    }
}

extension ChatListViewController: MatchViewDelegate {
    func matchViewTapped(user: PFUser?) {
        if let user = user {
            let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
            let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            let chat: ChatListModel?
            chat = ChatListModel(user: user, chat: Chat())
            destinationViewController.contactedUser = chat
            self.navigationController?.pushViewController(destinationViewController, animated: true)
        }else {
            let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
            let destinationViewController = storyBoard.instantiateViewController(withIdentifier: "WhoLikedViewController") as! WhoLikedViewController
            let nav = UINavigationController(rootViewController: destinationViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}
