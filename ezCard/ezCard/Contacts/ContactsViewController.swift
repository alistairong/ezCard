//
//  ContactsViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

/// Makes 'ContactsViewController' compatible with UISearchResultsUpdating to use itself to update search results
extension ContactsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

/// ContactsViewController controls what is being populated and shown in the page listing all contacts.
class ContactsViewController: UITableViewController, ContactDeletionDelegate {
    
    private struct Constants {
        static let contactTableViewCellReuseIdentifier = "ContactTableViewCell"
    }
    
    let profileImgsRef = Storage.storage().reference().child("profile_images")
    
    var userContactsRef: DatabaseReference? {
        guard let currentUser = User.current else {
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(currentUser.uid).child("contacts")
    }
    
    let contactsRef = Database.database().reference(withPath: "contacts")
    
    var contacts: [Contact] = []
    var filteredContacts: [Contact] = []
    
    let contactSearchController = UISearchController(searchResultsController: nil)
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var users: [String: User] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
        
        tableView.separatorInset = .zero
        // Hide extra separators
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.contactTableViewCellReuseIdentifier)
        
        setUpContactSearchBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWillChange(_:)), name: .currentUserWillChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(_:)), name: .currentUserDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    /// Looks for changes in the contacts in the database
    func observeContacts() {
        userContactsRef?.removeAllObservers()
        
        guard let currentUser = User.current else {
            return
        }
        
        userContactsRef?.observe(.value) { [weak self] (snapshot) in
            guard let self = self else { return }
            
            var newIds: [String] = []
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? DataSnapshot {
                newIds.append(currentUser.uid + "-" + child.key)
            }
            
            self.contactsRef.observeSingleEvent(of: .value) { (snapshot) in
                var newContacts: [Contact] = []
                for id in newIds {
                    let child = snapshot.childSnapshot(forPath: id)
                    
                    if let contact = Contact(snapshot: child), contact.holdingUserId == currentUser.uid {
                        newContacts.append(contact)
                    }
                }
                
                self.contacts = newContacts
                
                self.usersRef.observeSingleEvent(of: .value) { (snapshot) in
                    var invalidContactKeys: Set<String> = []
                    for contact in self.contacts {
                        let userSnapshot = snapshot.childSnapshot(forPath: contact.actualUserId)
                        if let user = User(snapshot: userSnapshot) {
                            self.users[contact.actualUserId] = user
                        } else {
                            invalidContactKeys.insert(contact.key)
                        }
                    }
                    
                    self.contacts.removeAll(where: { invalidContactKeys.contains($0.key) })
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /// Deletes a contact from the user
    private func deleteContact(_ contact: Contact) {
        usersRef.child(contact.holdingUserId).child("contacts").child(contact.actualUserId).removeValue()
        contactsRef.child(contact.key).removeValue()
    }
    
    // MARK: - ContactDeletionDelegate
    
    func contactViewController(_ contactViewController: ContactViewController, didDeleteContact contact: Contact) {
        deleteContact(contact)
    }
    
    // MARK: - Search Bar Functions
    
    func setUpContactSearchBar() {
        SearchUtil.setUpSearchBar(viewController: self, searchResultsUpdater: self,
                                  searchController: contactSearchController, placeholder: "Search Contacts")
    }
    
    /// Filters contacts by whether contact has any field value searched.
    /// If no such contact, returns false.
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredContacts = contacts.filter({ (contact : Contact) -> Bool in
            guard let user = users[contact.actualUserId] else {
                return false
            }
            return SearchUtil.containsContactName(user: user, name: searchText)
        })
        
        tableView.reloadData()
    }
    
    /// Says whether or not we are filtering with the search bar
    func isFiltering() -> Bool {
        return SearchUtil.isFiltering(searchController: contactSearchController)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFiltering()) {
            return filteredContacts.count
        } else {
            return contacts.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.contactTableViewCellReuseIdentifier, for: indexPath) as! ContactTableViewCell
        
        cell.accessoryType = .disclosureIndicator
        
        let contact = (isFiltering() ? filteredContacts[indexPath.row] : contacts[indexPath.row])
        let user = users[contact.actualUserId]!
        
        cell.nameLabel.text = user.displayName
        
        cell.profileButtonView.userId = contact.actualUserId
        
        // "Pass through" the tap on the profile button
        cell.profileButtonView.tappedCallback = { [weak self] in
            guard let self = self else { return }
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContact(contacts[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK : - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contactViewController = ContactViewController(style: .grouped)
        
        let contact = contacts[indexPath.row]
        contactViewController.contactDeletionDelegate = self
        contactViewController.contact = contact
        contactViewController.contactName = users[contact.actualUserId]!.displayName
        
        navigationController?.pushViewController(contactViewController, animated: true)
    }
    
}
