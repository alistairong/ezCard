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

class ProfileViewController: UITableViewController, ManageCardViewControllerDelegate {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var user: User? {
        willSet {
            userCardsRef?.removeAllObservers()
            cardsRef.removeAllObservers()
        }
        didSet {
            tableView.tableHeaderView = headerView(name: user?.displayName)
            observeCards()
            
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
    
    var userCardsRef: DatabaseReference? {
        guard let user = self.user else {
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(user.uid).child("cards")
    }
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var cards: [Card] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
    }
    
    func observeCards() {
        userCardsRef?.observe(.value) { [weak self] (snapshot) in
            var newCardIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let cardId = snapshot.key as String? {
                    newCardIds.append(cardId)
                }
            }

            self?.cardsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newCards: [Card] = []
                for cardId in newCardIds {
                    let child = snapshot.childSnapshot(forPath: cardId)
                    if let card = Card(snapshot: child), card.userId == self?.user?.uid {
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
        cardRef.setValue(card.dictionaryRepresentation())
        
        userCardsRef?.child(card.identifier).setValue(true)
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
        
        cell.cardView.qrCodeButtonTappedCallback = { [weak self] in
            let qrCodeViewController = QRCodeViewController()
            qrCodeViewController.card =  card
            self?.navigationController?.pushViewController(qrCodeViewController, animated: true)
        }
        
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
