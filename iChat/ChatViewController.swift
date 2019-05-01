//
//  ChatViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/26.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    
    var recentListener: ListenerRegistration!
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.tableFooterView = UIView()
        
        setTableViewHeader()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    // MARK: IBActions
    
    @IBAction func createNewChatButtonTapped(_ sender: Any) {
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userTableView") as! UserTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
        
    }
    
    // MARK: Helpers
    
    func loadRecentChats() {
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as! NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                    
//                    reference(.Recent).whereField(kCHATROOMID, isEqualTo: recent[kCHATROOMID] as! String).getDocuments(completion: { (snapshot, error) in
//
//                    })
                }
                self.tableView.reloadData()
            }
            
        })
        
    }
    
    func showUserProfile(user: FUser) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileTableViewController
        profileVC.user = user
        
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    // MARK: Tableview Header
    
    func setTableViewHeader() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.2834656835, blue: 0.6651299596, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1)
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
        
    }
    
    @objc func groupButtonPressed() {
    
        
    }
}


// MARK: TableView

extension ChatViewController: UITableViewDelegate, UITableViewDataSource, RecentChatsTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("RECENT CHAT COUNT: \(recentChats.count)")
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        
        let recent = recentChats[indexPath.row]
        
        cell.setupCell(recentChat: recent, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
        let recentChat = recentChats[indexPath.row]
        if recentChat[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                if snapshot.exists {
                    
                    let userDict = snapshot.data()! as NSDictionary
                    let tempUser = FUser(_dictionary: userDict)
                    self.showUserProfile(user: tempUser)
                    
                }
                
            }
        }
        
    }
    
}


