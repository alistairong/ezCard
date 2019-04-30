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

/// SettingsViewController controls what is being populated and shown on the settings page, accessible from the profile page.
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
        
        setUpSignOutButton()
        setUpTableView()

        let headerView = setUpHeaderView()
        
        setUpProfileButtonView(withHeaderView: headerView)
        
        setUpFirstNameTextField(withHeaderView: headerView)
        setUpLastNameTextField(withHeaderView: headerView)
        setUpCompanyTextField(withHeaderView: headerView)
        setUpJobTitleTextField(withHeaderView: headerView)
        
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
    
    // MARK: - Set-up Functions
    
    func setUpSignOutButton() {
        let signOutButton = UIBarButtonItem(title: "Sign Out".uppercased(), style: .done, target: self, action: #selector(signOut))
        signOutButton.tintColor = .red
        navigationItem.rightBarButtonItem = signOutButton
    }
    
    /// Sets up table view showing all fields that user can fill in about oneself.
    func setUpTableView() {
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicCellReuseIdentifier)
        tableView.register(UINib(nibName: "DataFieldTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.dataCellReuseIdentifier)
    }
    
    func setUpHeaderView() -> UIView {
        let headerViewHeight = Constants.headerViewPadding * 2 + (CGFloat(Constants.numTextFields) * Constants.textFieldHeight) + (Constants.textFieldSpacing * CGFloat(Constants.numTextFields - 1))
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerViewHeight))
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
    func setUpProfileButtonView(withHeaderView headerView: UIView) {
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
    }
    
    /// Aids in setting up the required textfields in settings view.
    ///
    /// - Parameters:
    ///   - withHeaderView: Specifies the view to place textfield in.
    ///   - selectorFunc: Specifies which function to call when textfield is selected.
    ///   - placeholder: Specifies placeholder text in textfield
    ///   - text: Specifies where to obtain textfield text if field is already filled in previously.
    ///   - topAnchorConstant: Specifies how far from top of profile button view that text field is.
    func setUpTextField(withHeaderView headerView: UIView, selectorFunc: Selector,
                        placeholder: String, text: String?, topAnchorConstant: Int) {
        let textField = UITextField()
        textField.delegate = self
        textField.addTarget(self, action: selectorFunc, for: .editingChanged)
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.text = text
        textField.font = UIFont.systemFont(ofSize: 17)
        headerView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -Constants.headerViewPadding).isActive = true
        textField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight).isActive = true
        textField.topAnchor.constraint(equalTo: profileButtonView.topAnchor, constant: CGFloat(topAnchorConstant)).isActive = true
    }
    
    func setUpFirstNameTextField(withHeaderView headerView: UIView) {
        setUpTextField(withHeaderView: headerView, selectorFunc: #selector(firstNameValueChanged(_:)),
                       placeholder: "First Name", text: user.firstName, topAnchorConstant: 0)
    }
    
    func setUpLastNameTextField(withHeaderView headerView: UIView) {
        setUpTextField(withHeaderView: headerView, selectorFunc: #selector(lastNameValueChanged(_:)),
                       placeholder: "Last Name", text: user.lastName, topAnchorConstant: 40)
    }
    
    func setUpCompanyTextField(withHeaderView headerView: UIView) {
        setUpTextField(withHeaderView: headerView, selectorFunc: #selector(companyValueChanged(_:)),
                       placeholder: "Company", text: user.company, topAnchorConstant: 80)
    }
    
    func setUpJobTitleTextField(withHeaderView headerView: UIView) {
        setUpTextField(withHeaderView: headerView, selectorFunc: #selector(jobTitleValueChanged(_:)),
                       placeholder: "Job Title", text: user.jobTitle, topAnchorConstant: 120)
    }
    
    // MARK: - Selector Functions
    
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
    
    // MARK: -
    
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
    
    func labelSelectionViewController(_ labelSelectionViewController: LabelSelectionViewController, didFinishWithLabel label: String, for field: String?, at row: Int?) {
        guard let field = field, let row = row else {
            return
        }
        
        var fieldData: [[String: Any]] = []
        for (index, data) in user.data.enumerated() {
            if data["field"]! == field {
                var dataWithIndex: [String: Any] = data
                dataWithIndex["index"] = index
                fieldData.append(dataWithIndex)
            }
        }
        
        let dataDict = fieldData[row]
        let globalIndex = dataDict["index"] as! Int
        
        user.data[globalIndex]["label"] = label
        
        tableView.reloadData()
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
        return user.data.filter { $0["field"]! == dataField.rawValue }.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataField = DataField.allCases[indexPath.section]
        
        var fieldData: [[String: Any]] = []
        for (index, data) in user.data.enumerated() {
            if data["field"]! == dataField.rawValue {
                var dataWithIndex: [String: Any] = data
                dataWithIndex["index"] = index
                fieldData.append(dataWithIndex)
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.row < fieldData.count) ? Constants.dataCellReuseIdentifier : Constants.basicCellReuseIdentifier, for: indexPath)
        
        if indexPath.row < fieldData.count {
            // data cell
            let cell = cell as! DataFieldTableViewCell
            
            let dataDict = fieldData[indexPath.row] // ["label": String, "data" : Any]
            
            cell.textField.delegate = self
            
            cell.textField.placeholder = dataField.rawValue
            
            let globalIndex = dataDict["index"] as! Int
            cell.textFieldEditedAction = { [weak self] (textField) in
                self?.user.data[globalIndex]["data"] = textField.text
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
        let fieldData = user.data.filter { $0["field"]! == dataField.rawValue }
        return (indexPath.row < fieldData.count) ? .delete : .insert
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dataField = DataField.allCases[indexPath.section]
            
            var fieldData: [[String: Any]] = []
            for (index, data) in user.data.enumerated() {
                if data["field"]! == dataField.rawValue {
                    var dataWithIndex: [String: Any] = data
                    dataWithIndex["index"] = index
                    fieldData.append(dataWithIndex)
                }
            }
            
            let dataDict = fieldData[indexPath.row]
            let globalIndex = dataDict["index"] as! Int
            user.data.remove(at: globalIndex)
            
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
        
        let row = self.tableView(tableView, numberOfRowsInSection: section) - 1
        
        let defaultDataDict = ["identifier": UUID().uuidString, "field" : dataField.rawValue, "label" : (dataField == .socialProfile) ? DataLabel.defaultSocial.rawValue : DataLabel.default.rawValue, "data": ""]
        user.data.append(defaultDataDict)
        
        tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
