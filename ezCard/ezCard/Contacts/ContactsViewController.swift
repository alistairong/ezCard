//
//  ContactsViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ContactsViewController: UITableViewController {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var userContactsRef: DatabaseReference? {
        guard let currentUser = User.current else {
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(currentUser.uid).child("contacts")
    }
    let contactsRef = Database.database().reference(withPath: "contacts")
    let usersRef = Database.database().reference(withPath: "users")
    
    var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWillChange(_:)), name: .currentUserWillChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(_:)), name: .currentUserDidChange, object: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicTableViewCellReuseIdentifier)
        
        userContactsRef?.removeAllObservers()
        contactsRef.removeAllObservers()
        observeContacts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func currentUserWillChange(_ notification: Notification) {
        userContactsRef?.removeAllObservers()
        contactsRef.removeAllObservers()
    }
    
    @objc func currentUserDidChange(_ notification: Notification) {
        observeContacts()
    }
    
    func observeContacts() {
        guard let currentUser = User.current else {
            return
        }
        
        userContactsRef?.observe(.value) { [weak self] (snapshot) in
            var newIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let id = snapshot.key as String? {
                    newIds.append(currentUser.uid + "-" + id)
                }
            }
            
            self?.contactsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newContacts: [Contact] = []
                for id in newIds {
                    let child = snapshot.childSnapshot(forPath: id)
                    if let contact = Contact(snapshot: child), contact.holdingUserId == currentUser.uid {
                        newContacts.append(contact)
                    }
                }
                
                self?.contacts = newContacts
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return contacts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = Constants.basicTableViewCellReuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        
        cell.selectionStyle = .none
        
        let contact = contacts[indexPath.row]
        
        let contactId = contact.actualUserId//contactsRef.child(contact)//.value(forKey: "actualUserId") as! String
        print(contactId)
        
        usersRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            let child = snapshot.childSnapshot(forPath: contactId)
            if let user = User(snapshot: child) {
                cell.textLabel?.text = user.displayName
            }
        }
        
        /*print(usersRef.child(contactId).value(forKey: "firstName"))
        let fullName = "\(usersRef.child(contactId).value(forKey: "firstName") as! String) \(usersRef.child(contactId).value(forKey: "lastName") as! String)"
        cell.textLabel?.text = fullName*/

        return cell
    }
 

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
    
    // MARK : - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactViewController = ContactViewController(style: .grouped)
        //contactViewController.contact =  // TODO: set contact on ContactViewController
        let contact = contacts[indexPath.row]
        contactViewController.cardIds = Array(contact.sharedCardIds.keys)
        contactViewController.sharedFields = contact.allSharedFields
        
        navigationController?.pushViewController(contactViewController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
