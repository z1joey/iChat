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
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    var initialLoadComplete = false
    
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
        
//        self.present(optionMenu, animated: true, completion: nil)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            
            if let currentPopoverPresentionController = optionMenu.popoverPresentationController {
                
                currentPopoverPresentionController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverPresentionController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverPresentionController.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
                
            }
            
        } else {
            
            self.present(optionMenu, animated: true, completion: nil)
            
        }
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != ""{
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            updateSendButton(isSend: false)
        } else {
            updateSendButton(isSend: true)
        }
        
    }
    
    // MARK: CustomSendButton
    
    override func textViewDidChange(_ textView: UITextView) {
        
        if textView.text != "" {
            updateSendButton(isSend: true)
        } else {
            updateSendButton(isSend: false)
        }
        
    }
    
    func updateSendButton(isSend: Bool) {
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        } else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
        
    }
    
    // MARK: Helper functions
    
    func removebadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        
        var tempMessages = allMessages
        
        for message in tempMessages {
            
            if message[kTYPE] != nil {
                if !self.legitTypes.contains(message[kTYPE] as! String) {
                    // remove the message
                    tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
                }
            } else {
                tempMessages.remove(at: tempMessages.firstIndex(of: message)!)
            }
        }
        return tempMessages
    }
    
}

// MARK: Send/Load Messages

extension ChatingViewController {
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        
        var outgoingMessage: OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        // text message
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoomId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: memberIds, membersToPush: membersToPush)
        
    }
    
    func loadMessages() {
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else {
                self.initialLoadComplete = true
                return
            }
            
            let sorted = (dictionaryFromSnapshots(snapshots: snapshot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages = self.removebadMessages(allMessages: sorted)
            
            self.initialLoadComplete = true
            
            // TODO: get picture messages
            
            // TODO: get old messages in background
            
            // Start listening for new chats
            
        }
    }
    
}
