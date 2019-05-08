//
//  LoginViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth

/// LoginViewController controls what is being populated and shown on the login page.
class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField?
    
    @IBOutlet weak var passwordTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Removes back button text
        navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Log in the user if credentials are correct and login is tapped. Dismisses the LoginView
    @IBAction func loginTapped(_ sender: Any) {
        // Do not do anything if username and password are not filled out
        guard let username = usernameTextField?.text, let password = passwordTextField?.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: username, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    /// If register is tapped, pull up RegisterViewController
    @IBAction func registerTapped(_ sender: Any) {
        let registerViewController = RegisterViewController(style: .grouped)
        usernameTextField?.text = Optional.none
        passwordTextField?.text = Optional.none
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
