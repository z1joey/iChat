//
//  FinishRegistrationViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/25.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    // MARK: IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                
                self.registerUser()
                
            }
            
        } else {
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    // MARK: Helpers
    
    func goToApp() {
        
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainVC, animated: true, completion: nil)
        
    }
    
    func finishRegistration(withValues: [String : Any]) {
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                
                // running background, need use GCD
                DispatchQueue.main.async {
                    ProgressHUD.showError(error?.localizedDescription)
                    print(error?.localizedDescription)
                }
                return
            }
            
            ProgressHUD.dismiss()
            self.goToApp()
        }
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
    
    func registerUser() {
        
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDict: [String : Any] = [
            kFIRSTNAME: nameTextField.text!,
            kLASTNAME: surnameTextField.text!,
            kFULLNAME: fullName,
            kCOUNTRY: countryTextField.text!,
            kCITY: cityTextField.text!,
            kPHONE: phoneTextField.text!
        ]
        
        if avatarImage == nil {
            // create an image in case it is nil
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                
                // image to data
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDict[kAVATAR] = avatar
                
                self.finishRegistration(withValues: tempDict)
                
            }
        } else {
            
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDict[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDict)
        }
        
    }
    
}
