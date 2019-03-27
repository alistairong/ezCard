//
//  RegisterViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import Contacts
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UITableViewController, UITextFieldDelegate {
    
    private enum RowIdentifier: Int, CaseIterable {
        case firstName
        case lastName
        case email
        case password
        case confirmPassword
    }
    
    private struct ReuseIdentifiers {
        static let textField = "TextFieldTableViewCell"
        static let centeredText = "CenteredTextTableViewCell"
    }
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var confirmPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.textField)
        tableView.register(UINib(nibName: "CenteredTextTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.centeredText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //one for data fields, one for register button
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? RowIdentifier.allCases.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.section == 0) ? ReuseIdentifiers.textField : ReuseIdentifiers.centeredText, for: indexPath)

        cell.backgroundColor = .clear
        
        if indexPath.section == 0 { // data fields section
            let cell = cell as! TextFieldTableViewCell
            
            cell.textField.borderStyle = .roundedRect
            cell.textField.delegate = self
            
            guard let rowIdentifier = RowIdentifier(rawValue: indexPath.row) else {
                fatalError("Row \(indexPath.row) did not have an associated RowIdentifier.")
            }
            
            switch rowIdentifier {
            case .firstName:
                cell.textField.placeholder = "First Name"
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.firstName = textField.text
                }
            case .lastName:
                cell.textField.placeholder = "Last Name"
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.lastName = textField.text
                }
            case .email:
                cell.textField.placeholder = "Email"
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.email = textField.text
                }
            case .password:
                cell.textField.placeholder = "Password"
                cell.textField.isSecureTextEntry = true
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.password = textField.text
                }
            case .confirmPassword:
                cell.textField.placeholder = "Confirm Password"
                cell.textField.isSecureTextEntry = true
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.confirmPassword = textField.text
                }
            }
        } else if indexPath.section == 1 { // button section
            let cell = cell as! CenteredTextTableViewCell
            cell.selectionStyle = .none

            cell.titleLabel.text = "Sign Up".uppercased()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 { // register tapped
            guard let firstName = self.firstName, let lastName = self.lastName, let email = self.email, let password = self.password, let confirmPassword = self.confirmPassword, firstName.count > 0, lastName.count > 0, email.count > 0, password.count > 0, confirmPassword.count > 0 else {
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
            
            // TODO: check password against security requirements
            
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    strongSelf.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // user has been created and signed in
                
                let newUser = (authResult?.user)!
                
                // update display name for quick reference
                let changeRequest = newUser.createProfileChangeRequest()
                changeRequest.displayName = firstName + " " + lastName
                changeRequest.commitChanges { (error) in
                    guard let error = error else {
                        return
                    }
                    print("error changing user display name:", error)
                }
                
                // create the user's entry in the database
                let user = User(uid: newUser.uid, firstName: firstName, lastName: lastName, email: email)
                let userRef = strongSelf.usersRef.child(newUser.uid)
                userRef.setValue(user.toAnyObject())
                
                // upload initial vCard
                let contact = CNMutableContact()
                contact.givenName = firstName
                contact.familyName = lastName
                
                let dataManager = UserDataManager(user: newUser)
                dataManager.upload(contact, completion: { (error) in
                    if let error = error {
                        print("error uploading initial vCard:", error)
                    }
                })
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

}
