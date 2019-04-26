//
//  ProfileTableViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/26.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: IBActions
    
    @IBAction func callButtonTapped(_ sender: Any) {
        print("call: \(user?.fullname)")
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        print("chat with: \(user?.fullname)")
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUser()?.blockedUsers
        if (currentBlockedIds?.contains(user!.objectId))! {
            let index = currentBlockedIds?.firstIndex(of: user!.objectId)
            currentBlockedIds?.remove(at: index!)
        } else {
            currentBlockedIds?.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error : \(error)")
                return
            }
            
            self.updateBlockStatus()
        }
        
    }
    
    // MARK: Setup UI
    
    func setupUI() {
        
        if user != nil {
            self.title = "Profile"
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (image) in
                if image != nil {
                    self.avatarImageView.image = image?.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus() {
        
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        } else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
        
    }

}

