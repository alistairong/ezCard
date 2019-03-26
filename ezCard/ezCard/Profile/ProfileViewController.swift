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
import FirebaseStorage

class ProfileViewController: UITableViewController, CNContactViewControllerDelegate {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    let currentUser = Auth.auth().currentUser!
    var dataManager: UserDataManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = ProfilePictureAndNameView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.nameLabel.text = currentUser.displayName
        tableView.tableHeaderView = headerView
        
        dataManager = UserDataManager(user: currentUser)
        
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addProfileButtonAndSearchBarToNavigationBar()
        navigationItem.leftBarButtonItem = nil // remove the profile button since we're already at the profile screen
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:))),
                                              UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(settingsTapped(_:)))]
    }
    
    @objc func shareTapped(_ sender: Any?) {
        let qrCodeViewController = QRCodeViewController()
        //qrCodeViewController.card =  // TODO: pass the card we're sharing to the view controller
        navigationController?.pushViewController(qrCodeViewController, animated: true)
    }
    
    @objc func settingsTapped(_ sender: Any?) {
        var contact: CNContact?
        if let currentUserData = currentUserData {
            do {
                contact = try CNContactVCardSerialization.contacts(with: currentUserData).first
            } catch let error {
                print("error while deserializing local currentUserData:", error)
            }
        }
        
        let contactVC = CNContactViewController(forNewContact: contact)
        contactVC.delegate = self
        contactVC.allowsActions = false
        present(UINavigationController(rootViewController: contactVC), animated: true, completion: nil)
    }
    
    @objc func addTapped(_ sender: Any?) {
        let cardViewController = CardViewController(style: .grouped)
        present(UINavigationController(rootViewController: cardViewController), animated: true, completion: nil)
    }
    
    // MARK: - CNContactViewControllerDelegate
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
        
        guard let contact = contact else {
            return
        }
        
        let headerView = ProfilePictureAndNameView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        tableView.tableHeaderView = headerView
        
        let oldUserData = currentUserData
        
        dataManager.upload(contact) { [weak self] (error) in
            if let error = error {
                let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alertController, animated: true, completion: nil)
                
                currentUserData = oldUserData
                
                return
            }
            
            do {
                currentUserData = try CNContactVCardSerialization.data(with: [contact])
            } catch let e {
                print("error caching currentUserData:", e)
            }
            
            self?.currentUser.reload(completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cardTableViewCellReuseIdentifier, for: indexPath) as! CardTableViewCell

        // TODO: configure the cell

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
