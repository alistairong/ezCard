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
import FirebaseDatabase

class ProfileViewController: UITableViewController, CNContactViewControllerDelegate, ManageCardViewControllerDelegate {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    let currentUser = Auth.auth().currentUser!
    
    let userCardsRef = Database.database().reference(withPath: "users").child(Auth.auth().currentUser!.uid).child("cards")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var dataManager: UserDataManager!
    
    var cards: [Card] = []
    var cardIds: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerView = ProfilePictureAndNameView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.nameLabel.text = currentUser.displayName
        tableView.tableHeaderView = headerView
        
        dataManager = UserDataManager(user: currentUser)
        
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        
//        cardsRef.queryOrdered(byChild: "createdAt").observe(.value) { [weak self] (snapshot) in
//            var newCards: [Card] = []
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot, let card = Card(snapshot: snapshot), card.userId == self?.currentUser.uid {
//                    newCards.append(card)
//                }
//            }
//
//            self?.cards = newCards.reversed()
//            self?.tableView.reloadData()
//        }
        
        userCardsRef.observe(.value) { [weak self] (snapshot) in
            var newCardIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let cardId = snapshot.key as String? {
                    newCardIds.append(cardId)
                }
            }

            self?.cardIds = newCardIds
            
            self!.cardsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newCards: [Card] = []
                for cardId in (self?.cardIds)! {
                    if let child = snapshot.childSnapshot(forPath: cardId) as DataSnapshot?, let card = Card(snapshot: child), card.userId == self?.currentUser.uid {
                        newCards.append(card)
                    }
                }
                
                self?.cards = newCards.sorted(by: { (c1: Card, c2: Card) -> Bool in
                    return c1.createdAt.compare(c2.createdAt) == ComparisonResult.orderedAscending
                })
                self?.tableView.reloadData()
            }
        }
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
        let manageCardViewController = ManageCardViewController(style: .grouped)
        manageCardViewController.delegate = self
        present(UINavigationController(rootViewController: manageCardViewController), animated: true, completion: nil)
    }
    
    // MARK: - ManageCardViewControllerDelegate
    
    func manageCardViewController(_ manageCardViewController: ManageCardViewController, didFinishWithCard card: Card?) {
        guard let card = card else {
            // user cancelled
            return
        }
        
        let cardRef = cardsRef.child(card.identifier)
        cardRef.setValue(card.toAnyObject())
        
        userCardsRef.child(card.identifier).setValue(true)
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
        return cards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cardTableViewCellReuseIdentifier, for: indexPath) as! CardTableViewCell

        let card = cards[indexPath.row]

        cell.cardView.configure(with: card)
        
        cell.cardView.moreButtonTappedCallback = { [weak self] in
            let manageCardViewController = ManageCardViewController(style: .grouped)
            manageCardViewController.delegate = self
            manageCardViewController.card = card
            self?.present(UINavigationController(rootViewController: manageCardViewController), animated: true, completion: nil)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
