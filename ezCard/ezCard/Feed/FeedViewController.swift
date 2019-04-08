//
//  FeedViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedViewController: UITableViewController {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
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
    var cards: [String: Card] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        
        tableView.separatorColor = .clear
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        
        observeTransactions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserWillChange(_:)), name: .currentUserWillChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidChange(_:)), name: .currentUserDidChange, object: nil)
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
            guard let self = self else { return }
            
            var newIds: [String] = []
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? DataSnapshot {
                newIds.append(child.key)
            }
            
            self.transactionsRef.observeSingleEvent(of: .value) { (snapshot) in
                var newTransactions: [Transaction] = []
                for id in newIds {
                    let transactionSnapshot = snapshot.childSnapshot(forPath: id)
                    if let transaction = Transaction(snapshot: transactionSnapshot), transaction.userId == User.current?.uid {
                        newTransactions.append(transaction)
                    }
                }
                
                self.transactions = newTransactions.sorted(by: { $0.createdAt > $1.createdAt })
                
                self.cardsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    var invalidTransactionKeys: Set<String> = []
                    for transaction in self.transactions {
                        let cardSnapshot = snapshot.childSnapshot(forPath: transaction.cardId)
                        if let card = Card(snapshot: cardSnapshot) {
                            self.cards[transaction.key] = card
                        } else {
                            invalidTransactionKeys.insert(transaction.key)
                        }
                    }
                    
                    self.transactions.removeAll(where: { invalidTransactionKeys.contains($0.key) })
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CardTableViewCell
        
        cell.selectionStyle = .none
        
        let transaction = transactions[indexPath.row]
        let card = cards[transaction.key]!
        
        cell.cardView.configure(with: card)
        
        cell.cardView.qrCodeButton.isHidden = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
