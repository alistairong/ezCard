//
//  RegisterViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField?
    
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var confirmPasswordTextField: UITextField?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any?) {
        guard let username = usernameTextField?.text, let password = passwordTextField?.text, let confirmPassword = confirmPasswordTextField?.text, username.count > 0, password.count > 0, confirmPassword.count > 0 else {
            let alertController = UIAlertController(title: "Oops!", message: "It looks like one or more fields is empty. Make sure to fill out all the fields!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard password == confirmPassword else {
            let alertController = UIAlertController(title: "Oops!", message: "The password fields do not match.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // TODO: check input against username/password requirements
        
        Auth.auth().createUser(withEmail: username, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if error != nil {
                let alertController = UIAlertController(title: "Oops!", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                strongSelf.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // user has been created and signed in
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
