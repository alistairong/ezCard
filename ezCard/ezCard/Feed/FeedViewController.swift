//
//  FeedViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FeedViewController: UITableViewController {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var userTransactionsRef: DatabaseReference? {
        guard let currentUser = User.current else {
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(currentUser.uid).child("transactions")
    }
    let transactionsRef = Database.database().reference(withPath: "transactions")
    
    var transactions: [Transaction] = []
    
    let cardsRef = Database.database().reference(withPath: "cards")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWillChange(_:)), name: .currentUserWillChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(_:)), name: .currentUserDidChange, object: nil)
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        
        userTransactionsRef?.removeAllObservers()
        transactionsRef.removeAllObservers()
        observeTransactions()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func currentUserWillChange(_ notification: Notification) {
        userTransactionsRef?.removeAllObservers()
        transactionsRef.removeAllObservers()
    }
    
    @objc func currentUserDidChange(_ notification: Notification) {
        observeTransactions()
    }
    
    func observeTransactions() {
        userTransactionsRef?.observe(.value) { [weak self] (snapshot) in
            var newIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let id = snapshot.key as String? {
                    newIds.append(id)
                }
            }
            
            self?.transactionsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newTransactions: [Transaction] = []
                for id in newIds {
                    let child = snapshot.childSnapshot(forPath: id)
                    if let transaction = Transaction(snapshot: child), transaction.userId == User.current?.uid {
                        newTransactions.append(transaction)
                    }
                }
                
                self?.transactions = newTransactions.sorted(by: { $0.createdAt > $1.createdAt })
                self?.tableView.reloadData()
            }
        }
    }
    
    /*
     /// callback for ... button on ID card
     @objc func showContact(_ contact: Contact) {
     let contactViewController = ContactViewController(style: .grouped)
     //contactViewController.contact =  // TODO: set contact on ContactViewController
     navigationController?.pushViewController(contactViewController, animated: true)
     }
     */
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!CardTableViewCell
        
        cell.selectionStyle = .none
        
        let transaction = transactions[indexPath.row]
        cardsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            let child = snapshot.childSnapshot(forPath: transaction.cardId)
            if let card = Card(snapshot: child) {
                cell.cardView.configure(with: card)
            }
        }
        
        return cell
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     // Configure the cell...
     return cell
     }
     */
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
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
