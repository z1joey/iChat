//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Yi Zhang on 2019/4/24.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit

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
        print("login")
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        print("register")
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        print("dismiss")
    }
}
