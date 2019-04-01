//
//  LoginViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField?
    
    @IBOutlet weak var passwordTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "" // remove back button text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func loginTapped(_ sender: Any) {
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
