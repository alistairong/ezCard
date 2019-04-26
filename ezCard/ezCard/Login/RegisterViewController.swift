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

/// RegisterViewController controls what is being populated and shown on the sign up / register page.
class RegisterViewController: UITableViewController, UITextFieldDelegate {
    
    private struct Constants {
        static let segmentedControlHeight = CGFloat(44.0)
        static let tableViewHeaderPadding = CGFloat(30.0)
        static let textFieldHeight = CGFloat(35.0)
        static let textFieldContainerViewTag = 938472
    }
    
    private enum OrganizationTypeRowIdentifier: Int, CaseIterable {
        case organizationName
        case email
        case password
        case confirmPassword
    }
    
    private enum IndividualTypeRowIdentifier: Int, CaseIterable {
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
    
    var type: UserType = .individual
    
    var organizationName: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    var confirmPassword: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Register"
        
        tableView.tableHeaderView = createSegmentedControl()
        
        tableView.isScrollEnabled = false
        
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "RoundedRectTextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.textField)
        tableView.register(UINib(nibName: "CenteredTextTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.centeredText)
    }
    
    /// create the segmented control to switch between individuals and organizations
    func createSegmentedControl() -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.segmentedControlHeight + Constants.tableViewHeaderPadding))
        containerView.clipsToBounds = true
        
        let segmentedControlXExtension = CGFloat(3.0) // used to "hide" segmented control corner radius
        
        let typeSegmentedControl = UISegmentedControl(items: UserType.allQuantifiableCases.map({ $0.rawValue.uppercased() }))
        typeSegmentedControl.backgroundColor = .white
        typeSegmentedControl.frame = CGRect(x: -segmentedControlXExtension, y: 0, width: containerView.bounds.width + segmentedControlXExtension * 2, height: Constants.segmentedControlHeight)
        typeSegmentedControl.selectedSegmentIndex = UserType.allQuantifiableCases.index(of: type)!
        typeSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14.0, weight: .bold)], for: .normal)
        typeSegmentedControl.addTarget(self, action: #selector(accountTypeValueChanged(_:)), for: .valueChanged)
        containerView.addSubview(typeSegmentedControl)
        
        return containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func accountTypeValueChanged(_ sender: UISegmentedControl) {
        type = UserType.allQuantifiableCases[sender.selectedSegmentIndex]
        
        clearText()
        tableView.reloadData()
    }
    
    func clearText() {
        organizationName = nil
        firstName = nil
        lastName = nil
        email = nil
        password = nil
        confirmPassword = nil
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
        let caseCount = (type == .individual) ? IndividualTypeRowIdentifier.allCases.count : OrganizationTypeRowIdentifier.allCases.count
        return (section == 0) ? caseCount : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.section == 0) ? ReuseIdentifiers.textField : ReuseIdentifiers.centeredText, for: indexPath)

        cell.backgroundColor = .clear
        
        if indexPath.section == 0 { // data fields section
            let cell = cell as! TextFieldTableViewCell
            
            cell.textField.delegate = self
            
            if indexPath.row == OrganizationTypeRowIdentifier.organizationName.rawValue && type == .organization {
                cell.textField.placeholder = "Organization Name"
                
                cell.textField.text = organizationName
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.organizationName = textField.text
                }
            } else if indexPath.row == IndividualTypeRowIdentifier.firstName.rawValue && type == .individual {
                cell.textField.placeholder = "First Name"
                
                cell.textField.text = firstName
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.firstName = textField.text
                }
            } else if indexPath.row == IndividualTypeRowIdentifier.lastName.rawValue && type == .individual {
                cell.textField.placeholder = "Last Name"
                
                cell.textField.text = lastName
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.lastName = textField.text
                }
            } else if (indexPath.row == IndividualTypeRowIdentifier.email.rawValue && type == .individual) || (indexPath.row == OrganizationTypeRowIdentifier.email.rawValue && type == .organization) {
                cell.textField.placeholder = (type == .individual) ? "Email" : "Admin Email"
                cell.textField.isSecureTextEntry = false
                
                cell.textField.text = email
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.email = textField.text
                }
            } else if (indexPath.row == IndividualTypeRowIdentifier.password.rawValue && type == .individual) || (indexPath.row == OrganizationTypeRowIdentifier.password.rawValue && type == .organization) {
                cell.textField.placeholder = "Password"
                cell.textField.isSecureTextEntry = true
                cell.textField.textContentType = .oneTimeCode
                
                cell.textField.text = password
                
                cell.textFieldEditedAction = { [weak self] (textField: UITextField) in
                    self?.password = textField.text
                }
            } else if (indexPath.row == IndividualTypeRowIdentifier.confirmPassword.rawValue && type == .individual) || (indexPath.row == OrganizationTypeRowIdentifier.confirmPassword.rawValue && type == .organization) {
                cell.textField.placeholder = "Confirm Password"
                cell.textField.isSecureTextEntry = true
                cell.textField.textContentType = .oneTimeCode
                
                cell.textField.text = confirmPassword
                
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
            // check if fields are filled
            guard let email = self.email, let password = self.password, let confirmPassword = self.confirmPassword, email.count > 0, password.count > 0, confirmPassword.count > 0, ((organizationName?.count ?? 0) > 0) || (type == .individual && (firstName?.count ?? 0) > 0 && (lastName?.count ?? 0) > 0) else {
                let alertController = UIAlertController(title: "Oops!", message: "It looks like one or more fields is empty. Make sure to fill out all the fields!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
                
                return
            }
            
            // check that confirm password matches password
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
                changeRequest.displayName = (strongSelf.type == .individual) ? strongSelf.firstName! + " " + strongSelf.lastName! : strongSelf.organizationName!
                changeRequest.commitChanges { (error) in
                    guard let error = error else {
                        return
                    }
                    print("error changing user display name:", error)
                }
                
                let userRef = strongSelf.usersRef.child(newUser.uid)
                
                // create the user's entry in the database
                switch strongSelf.type {
                case .individual:
                    let user = User(uid: newUser.uid, type: strongSelf.type, email: email, firstName: strongSelf.firstName!, lastName: strongSelf.lastName!)
                    userRef.setValue(user.dictionaryRepresentation())
                case .organization:
                    let user = User(uid: newUser.uid, type: strongSelf.type, email: email, organizationName: strongSelf.organizationName!)
                    userRef.setValue(user.dictionaryRepresentation())
                case .unknown:
                    fatalError("UserType was unknown.")
                }
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }

}
