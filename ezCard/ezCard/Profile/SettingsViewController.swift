//
//  SettingsViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 4/15/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

enum DataField: String, CaseIterable {
    case phone
    case email
    case address
    case title
    case company
    case website
    case birthday
    case socialProfile = "social profile"
}

extension Notification.Name {
    static let currentUserInfoDidChange = Notification.Name("currentUserInfoDidChange")
}

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    private struct Constants {
        static let basicCellReuseIdentifier = "basic"
        static let dataCellReuseIdentifier = "data"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var user: User!
    
    var signingOut = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signOutButton = UIBarButtonItem(title: "Sign Out".uppercased(), style: .done, target: self, action: #selector(signOut))
        signOutButton.tintColor = .red
        navigationItem.rightBarButtonItem = signOutButton
        
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicCellReuseIdentifier)
        tableView.register(UINib(nibName: "DataFieldTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.dataCellReuseIdentifier)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.backgroundColor = .clear
        
        let profileButtonView = ProfileButtonView()
        profileButtonView.tappedCallback = {
            // TODO: select profile image
        }
        headerView.addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true
        
        let firstNameTextField = UITextField()
        firstNameTextField.delegate = self
        firstNameTextField.addTarget(self, action: #selector(firstNameValueChanged(_:)), for: .editingChanged)
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.text = user.firstName
        firstNameTextField.font = UIFont.systemFont(ofSize: 17)
        headerView.addSubview(firstNameTextField)
        
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        firstNameTextField.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        firstNameTextField.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: 30).isActive = true
        firstNameTextField.topAnchor.constraint(equalTo: profileButtonView.topAnchor).isActive = true
        
        let lastNameTextField = UITextField()
        lastNameTextField.delegate = self
        lastNameTextField.addTarget(self, action: #selector(lastNameValueChanged(_:)), for: .editingChanged)
        lastNameTextField.borderStyle = .roundedRect
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.text = user.lastName
        lastNameTextField.font = UIFont.systemFont(ofSize: 17)
        headerView.addSubview(lastNameTextField)
        
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor).isActive = true
        lastNameTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor).isActive = true
        lastNameTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor).isActive = true
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 8).isActive = true
        
        tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
        if !signingOut {
            let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
            changeRequest.displayName = (user.type == .individual) ? user.firstName! + " " + user.lastName! : user.organizationName!
            changeRequest.commitChanges { (error) in
                guard let error = error else {
                    NotificationCenter.default.post(name: .currentUserInfoDidChange, object: nil)
                    
                    return
                }
                print("error changing user display name:", error)
            }
            
            usersRef.child(user.uid).setValue(user.dictionaryRepresentation())
        }
    }
    
    @objc func signOut() {
        signingOut = true
        
        do {
            try Auth.auth().signOut()
            
            let loginViewController = LoginViewController()
            present(UINavigationController(rootViewController: loginViewController), animated: false, completion: nil)
            
            tabBarController?.selectedIndex = 0
            navigationController?.popViewController(animated: false)
        } catch {
            let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func firstNameValueChanged(_ sender: UITextField) {
        user.firstName = sender.text ?? ""
    }
    
    @objc func lastNameValueChanged(_ sender: UITextField) {
        user.lastName = sender.text ?? ""
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataField.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataField = DataField.allCases[section]
        return (user.data[dataField.rawValue]?.count ?? 0) + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataField = DataField.allCases[indexPath.section]
        let fieldData = (user.data[dataField.rawValue] ?? [:]).sorted(by: { $0.key < $1.key })
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.row < fieldData.count) ? Constants.dataCellReuseIdentifier : Constants.basicCellReuseIdentifier, for: indexPath)
        
        if indexPath.row < fieldData.count {
            // data cell
            let cell = cell as! DataFieldTableViewCell
            
            //let index = fieldData[indexPath.row].key
            let dataDict = fieldData[indexPath.row].value // ["label": String, "data" : Any]
            
            cell.textField.delegate = self
            
            cell.textField.placeholder = dataField.rawValue
            
            cell.textFieldEditedAction = { [weak self] (textField) in
                self?.user.data[dataField.rawValue]?[String(indexPath.row)]?["data"] = textField.text
            }
            
            cell.button.setTitle((dataDict["label"] as! String), for: .normal)
            cell.textField.text = dataDict["data"] as? String ?? "???"
            
            cell.selectionStyle = .none
        } else {
            // add cell
            cell.textLabel?.text = "add \(dataField.rawValue)"
            
            cell.selectionStyle = .default
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let dataField = DataField.allCases[indexPath.section]
        let fieldData = user.data[dataField.rawValue] ?? [:]
        return (indexPath.row < fieldData.count) ? .delete : .insert
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dataField = DataField.allCases[indexPath.section]
            
            let fieldData = user.data[dataField.rawValue]!.sorted(by: { $0.key < $1.key })
            
            let entry = fieldData[indexPath.row]
            user.data[dataField.rawValue]!.removeValue(forKey: entry.key)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            insertNewField(in: indexPath.section)
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        insertNewField(in: indexPath.section)
    }
    
    func insertNewField(in section: Int) {
        let dataField = DataField.allCases[section]
        
        let defaultDataDict = ["label" : "personal", "data": ""]
        
        let newKey = String(user.data[dataField.rawValue]?.count ?? 0)
        
        if user.data[dataField.rawValue] != nil {
            user.data[dataField.rawValue]![newKey] = defaultDataDict
        } else {
            user.data[dataField.rawValue] = [newKey : defaultDataDict]
        }
        
        tableView.insertRows(at: [IndexPath(row: user.data[dataField.rawValue]!.count - 1, section: section)], with: .automatic)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
