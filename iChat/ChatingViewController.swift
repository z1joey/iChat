//
//  ChatingViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/5/2.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatingViewController: JSQMessagesViewController {
    
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incommingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    
    //fix for Iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    //end of iphone x fix

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        
        // TODO: Fix bottom constraints for iPhone X
        //fix for iphone x
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.inputToolbar.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        ])
        
        //self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        //self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 5)

        //end of iphone x fix
    }
    
}
