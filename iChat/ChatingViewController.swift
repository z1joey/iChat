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
//    override func viewDidLayoutSubviews() {
//        perform(Selector(("jsq_updateCollectionViewInsets")))
//    }
    //end of iphone x fix

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        
        // TODO: Fix bottom constraints for iPhone X
        //fix for iphone x
//        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
//        
//        constraint.priority = UILayoutPriority(rawValue: 1000)
//        
//        let guide = view.safeAreaLayoutGuide
//        NSLayoutConstraint.activate([
//            self.inputToolbar.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
//        ])
        
        //self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        //self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 5)

        //end of iphone x fix
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    // MARK: IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


// MARK: JSQMessage Delegate

extension ChatingViewController {
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("photo library")
        }
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("video library")
        }
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("share location")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        print("send")
    }
    
}
