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
    case url
    case socialProfile = "social profile"
}

extension Notification.Name {
    static let currentUserInfoDidChange = Notification.Name("currentUserInfoDidChange")
}

class SettingsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, LabelSelectionViewControllerDelegate {
    
    private struct Constants {
        static let basicCellReuseIdentifier = "basic"
        static let dataCellReuseIdentifier = "data"
        static let profileImageMaxHeight = CGFloat(85)
        static let headerViewPadding = CGFloat(16)
        static let textFieldHeight = CGFloat(30)
        static let textFieldSpacing = CGFloat(8)
        static let numTextFields = 4
    }
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var user: User!
    
    var signingOut = false
    
    let imagePickerController = UIImagePickerController()
    
    let profileButtonView = ProfileButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signOutButton = UIBarButtonItem(title: "Sign Out".uppercased(), style: .done, target: self, action: #selector(signOut))
        signOutButton.tintColor = .red
        navigationItem.rightBarButtonItem = signOutButton
        
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicCellReuseIdentifier)
        tableView.register(UINib(nibName: "DataFieldTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.dataCellReuseIdentifier)
        
        let headerViewHeight = Constants.headerViewPadding * 2 + (CGFloat(Constants.numTextFields) * Constants.textFieldHeight) + (Constants.textFieldSpacing * CGFloat(Constants.numTextFields - 1))
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerViewHeight))
        headerView.backgroundColor = .clear
        
        profileButtonView.tappedCallback = { [weak self] in
            guard let self = self else { return }
            
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            
            self.present(self.imagePickerController, animated: true)
        }
        headerView.addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.profileImageMaxHeight).isActive = true
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: Constants.headerViewPadding).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Constants.headerViewPadding).isActive = true
        
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
        firstNameTextField.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.headerViewPadding).isActive = true
        firstNameTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
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
        lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: Constants.textFieldSpacing).isActive = true
        
        let companyTextField = UITextField()
        companyTextField.delegate = self
        companyTextField.addTarget(self, action: #selector(companyValueChanged(_:)), for: .editingChanged)
        companyTextField.borderStyle = .roundedRect
        companyTextField.placeholder = "Company"
        companyTextField.text = user.company
        companyTextField.font = UIFont.systemFont(ofSize: 17)
        headerView.addSubview(companyTextField)
        
        companyTextField.translatesAutoresizingMaskIntoConstraints = false
        companyTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor).isActive = true
        companyTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor).isActive = true
        companyTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor).isActive = true
        companyTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: Constants.textFieldSpacing).isActive = true
        
        let jobTitleTextField = UITextField()
        jobTitleTextField.delegate = self
        jobTitleTextField.addTarget(self, action: #selector(jobTitleValueChanged(_:)), for: .editingChanged)
        jobTitleTextField.borderStyle = .roundedRect
        jobTitleTextField.placeholder = "Job Title"
        jobTitleTextField.text = user.jobTitle
        jobTitleTextField.font = UIFont.systemFont(ofSize: 17)
        headerView.addSubview(jobTitleTextField)
        
        jobTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        jobTitleTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor).isActive = true
        jobTitleTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor).isActive = true
        jobTitleTextField.heightAnchor.constraint(equalTo: firstNameTextField.heightAnchor).isActive = true
        jobTitleTextField.topAnchor.constraint(equalTo: companyTextField.bottomAnchor, constant: Constants.textFieldSpacing).isActive = true
        
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

    @objc func companyValueChanged(_ sender: UITextField) {
        user.company = sender.text ?? ""
    }
    
    @objc func jobTitleValueChanged(_ sender: UITextField) {
        user.jobTitle = sender.text ?? ""
    }
    
    func labelSelectionViewController(_ labelSelectionViewController: LabelSelectionViewController, didFinishWithLabel label: String, for field: String?, at row: Int?) {
        guard let field = field, let row = row else {
            return
        }
        
        user.data[field]?[row]["label"] = label
        
        tableView.reloadRows(at: [IndexPath(row: row, section: DataField.allCases.map({ $0.rawValue }).index(of: field)!)], with: .automatic)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let currentUser = Auth.auth().currentUser else {
            print("uid was nil")
            return
        }
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 0.3) else {
            print("Image was nil")
            return
        }
        
        let profileImgRef = Storage.storage().reference().child("profile_images").child("\(currentUser.uid).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profileImgRef.putData(imageData, metadata: metadata) { [weak self] (metadata, error) in
            profileImgRef.downloadURL(completion: { (url, error) in
                if let error = error {
                    let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                let changeRequest = currentUser.createProfileChangeRequest()
                changeRequest.photoURL = url
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.present(alertController, animated: true, completion: nil)
                        
                        return
                    }
                    
                    self?.profileButtonView.refresh(forceRefetch: true)
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
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
        let fieldData = user.data[dataField.rawValue] ?? []
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.row < fieldData.count) ? Constants.dataCellReuseIdentifier : Constants.basicCellReuseIdentifier, for: indexPath)
        
        if indexPath.row < fieldData.count {
            // data cell
            let cell = cell as! DataFieldTableViewCell
            
            let dataDict = fieldData[indexPath.row] // ["label": String, "data" : Any]
            
            cell.textField.delegate = self
            
            cell.textField.placeholder = dataField.rawValue
            
            cell.textFieldEditedAction = { [weak self] (textField) in
                self?.user.data[dataField.rawValue]?[indexPath.row]["data"] = textField.text
            }
            
            cell.buttonAction = { [weak self] in
                guard let self = self else { return }
                
                let labelSelectionViewController = LabelSelectionViewController(style: .grouped)
                labelSelectionViewController.delegate = self
                labelSelectionViewController.currentLabel = dataDict["label"] as? String
                labelSelectionViewController.field = dataField.rawValue
                labelSelectionViewController.row = indexPath.row
                
                switch dataField {
                case .socialProfile:
                    labelSelectionViewController.labelsToShow = DataLabel.socialLabels
                default:
                    labelSelectionViewController.labelsToShow = DataLabel.defaultLabels
                }
                
                self.present(UINavigationController(rootViewController: labelSelectionViewController), animated: true, completion: nil)
            }
            
            cell.button.setTitle(dataDict["label"] as? String, for: .normal)
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
        let fieldData = user.data[dataField.rawValue] ?? []
        return (indexPath.row < fieldData.count) ? .delete : .insert
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dataField = DataField.allCases[indexPath.section]
            
            user.data[dataField.rawValue]!.remove(at: indexPath.row)
            
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
        
        let defaultDataDict = ["label" : (dataField == .socialProfile) ? DataLabel.defaultSocial.rawValue : DataLabel.default.rawValue, "data": ""]
        
        if user.data[dataField.rawValue] != nil {
            user.data[dataField.rawValue]!.append(defaultDataDict)
        } else {
            user.data[dataField.rawValue] = [defaultDataDict]
        }
        
        tableView.insertRows(at: [IndexPath(row: user.data[dataField.rawValue]!.count - 1, section: section)], with: .automatic)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
