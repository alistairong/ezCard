//
//  ProfileViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import ContactsUI
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UITableViewController, ManageCardViewControllerDelegate, OrganizationMemberSelectionViewControllerDelegate {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var user: User? {
        willSet {
            userRelevantDataRef?.removeAllObservers()
            relevantDataRef?.removeAllObservers()
        }
        didSet {
            tableView.separatorColor = (user?.type == .individual) ? .clear : nil
            
            tableView.tableHeaderView = headerView(name: user?.displayName)
            observeData()
            
            if user?.uid == User.current?.uid {
                let signOutButton = UIBarButtonItem(title: "Sign Out".uppercased(), style: .done, target: self, action: #selector(signOut))
                signOutButton.tintColor = .red
                navigationItem.leftBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(settingsTapped(_:))), signOutButton]
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
            } else {
                navigationItem.leftBarButtonItem = nil
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    var userRelevantDataRef: DatabaseReference? {
        guard let user = self.user else {
            return nil
        }
        
        var relevantDataPath: String!
        switch user.type {
        case .individual:
            relevantDataPath = "cards"
        case .organization:
            relevantDataPath = "members"
        case .unknown:
            return nil // this shouldn't happen and we should probably investigate if it does, but just return nil so we don't crash for now
        }
        
        return Database.database().reference(withPath: "users").child(user.uid).child(relevantDataPath)
    }
    
    var relevantDataRef: DatabaseReference? {
        guard let user = self.user else {
            return nil
        }
        
        var relevantDataPath: String!
        switch user.type {
        case .individual:
            relevantDataPath = "cards"
        case .organization:
            relevantDataPath = "users"
        case .unknown:
            return nil // this shouldn't happen and we should probably investigate if it does, but just return nil so we don't crash for now
        }
        
        return Database.database().reference(withPath: relevantDataPath)
    }
    
    var dataArr: [Any] = []
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = (user?.type == .individual) ? .clear : nil
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicTableViewCellReuseIdentifier)
    }
    
    func observeData() {
        userRelevantDataRef?.observe(.value) { [weak self] (snapshot) in
            var newIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let id = snapshot.key as String? {
                    newIds.append(id)
                }
            }
            
            self?.relevantDataRef?.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newData: [Any] = []
                for id in newIds {
                    let child = snapshot.childSnapshot(forPath: id)
                    
                    if self?.user?.type == .individual {
                        if let card = Card(snapshot: child), card.userId == self?.user?.uid {
                            newData.append(card)
                        }
                    } else if self?.user?.type == .organization {
                        if let user = User(snapshot: child) {
                            newData.append(user)
                        }
                    }
                }
                
                self?.dataArr = newData
                self?.tableView.reloadData()
            }
        }
    }
    
    func headerView(name: String?) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.backgroundColor = .clear
        
        let profileButtonView = ProfileButtonView()
        headerView.addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        headerView.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            
            tabBarController?.selectedIndex = 0
            
            let loginViewController = LoginViewController()
            present(UINavigationController(rootViewController: loginViewController), animated: false, completion: nil)
        } catch {
            let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func settingsTapped(_ sender: Any?) {
        // TODO: show settings screen
    }
    
    @objc func addTapped(_ sender: Any?) {
        if user?.type == .individual {
            let manageCardViewController = ManageCardViewController(style: .grouped)
            manageCardViewController.delegate = self
            present(UINavigationController(rootViewController: manageCardViewController), animated: true, completion: nil)
        } else if user?.type == .organization {
            let organizationMemberSelectionViewController = OrganizationMemberSelectionViewController()
            organizationMemberSelectionViewController.delegate = self
            present(UINavigationController(rootViewController: organizationMemberSelectionViewController), animated: true, completion: nil)
        }
    }
    
    // MARK: - OrganizationMemberSelectionViewControllerDelegate
    
    //can point the orgData to array of emails coming in? when merging. might be an issue
    func organizationMemberSelectionViewController(_ organizationCardViewController: OrganizationMemberSelectionViewController, didFinishWith uid: String?) {
        guard let uid = uid else {
            // user cancelled
            return
        }
        
        userRelevantDataRef?.child(uid).setValue(true)
    }
    
    // MARK: - ManageCardViewControllerDelegate
    
    func manageCardViewController(_ manageCardViewController: ManageCardViewController, didFinishWithCard card: Card?) {
        guard let card = card else {
            // user cancelled
            return
        }
        
        let cardRef = relevantDataRef?.child(card.identifier)
        cardRef?.setValue(card.dictionaryRepresentation())
        
        userRelevantDataRef?.child(card.identifier).setValue(true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        if user?.type == .organization {
            reuseIdentifier = Constants.basicTableViewCellReuseIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        cell.selectionStyle = .none
        
        if user?.type == .individual {
            let cell = cell as! CardTableViewCell
            
            let card = dataArr[indexPath.row] as! Card
            
            cell.cardView.configure(with: card)
            
            cell.cardView.qrCodeButtonTappedCallback = { [weak self] in
                let qrCodeViewController = QRCodeViewController()
                qrCodeViewController.card =  card
                self?.navigationController?.pushViewController(qrCodeViewController, animated: true)
            }
            
            //can test expanded view here/ inital commit
            cell.cardView.moreButtonTappedCallback = { [weak self] in
                let manageCardViewController = ManageCardViewController(style: .grouped)
                manageCardViewController.delegate = self
                manageCardViewController.card = card
                self?.present(UINavigationController(rootViewController: manageCardViewController), animated: true, completion: nil)
            }
        } else if user?.type == .organization {
            let member = dataArr[indexPath.row] as! User
            
            cell.textLabel?.text = member.displayName
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
 
}
