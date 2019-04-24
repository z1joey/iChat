//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/24.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController
{    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: IBAction
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            loginUser()
        } else {
            ProgressHUD.showError("Email and Password is missing")
        }
        
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" {
            if (passwordTextField.text == repeatPasswordTextField.text) {
                registerUser()
            } else {
                ProgressHUD.showError("Passwords do not match!")
            }
        } else {
            ProgressHUD.showError("All fields are required")
        }
        
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    // MARK: HelperFunctions
    
    func loginUser() {
        
        ProgressHUD.show("Login...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            self.goToApp()
            
        }
        
    }
    
    func registerUser() {
        print("register")
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatPasswordTextField.text = ""
    }
    
    // MARK: GoToApp
    func goToApp() {
        
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        // present app here
        print("show the app")
        
    }
}
