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
    
    /*var userTransactionsRef: DatabaseReference? {
        guard let currentUser = User.current else {
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(currentUser.uid).child("transactions")
    }
    let transactionsRef = Database.database().reference(withPath: "transactions")*/
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var user: User? {
        willSet {
            //userRelevantDataRef?.removeAllObservers()
            //relevantDataRef?.removeAllObservers()
            userTransactionsRef?.removeAllObservers()
            transactionsRef.removeAllObservers()
            print("in user will")
        }
        didSet {
            print("in user did")
            tableView.separatorColor = (user?.type == .individual) ? .clear : nil
            observeData()
        }
    }
    
    var dataArr: [Any] = []
    
    func observeData() {
        print("I am in observe")
        userTransactionsRef?.observe(.value) { [weak self] (snapshot) in
            var newIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let id = snapshot.value(forKey: "cardId") as! String? {
                    newIds.append(id)
                }
            }
            print("asidfhlksafzj \(newIds)")
            
            self?.cardsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                var newData: [Any] = []
                for id in newIds {
                    //let child = snapshot.childSnapshot(forPath: id).value(forKey: "cardId")
                    //let id = snapshot.childSnapshot(forPath: id).value(forKey: "userId")
                    
                    let child = snapshot.childSnapshot(forPath: id)
                    
                    if let card = Card(snapshot: child)/*, card.userId == self?.user?.uid*/ {
                        newData.append(card)
                    }
                }
                
                self?.dataArr = newData
                self?.tableView.reloadData()
            }
        }
    }
    
    var transactions: [/*Transaction*/String] = []
    
    let transactionsRef = Database.database().reference(withPath: "transactions")
    
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var currentUser = User.current {
        didSet {
            userTransactionsRef?.observeSingleEvent(of: .value, with: {(snapshot) in
                let snapshot = snapshot.value as? NSDictionary
                for transaction in snapshot! {
                    /*if let snapshot = transaction as? Transaction, let cardId = snapshot.key as String? {
                        self.transactions.append(cardId as String)
                    }*/
                    self.transactions.append(transaction.key as! String)
                }
                print("Transactions:  \(self.transactions)")
            })
        }
    }
    
    var userTransactionsRef: DatabaseReference? {
        guard let currentUser = self.currentUser else {
            print("hi")
            return nil
        }
        
        return Database.database().reference(withPath: "users").child(currentUser.uid).child("transactions")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Feed"
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let user = user else {
                return
            }
            
            User.fetchUser(with: user.uid) { (user) in
                self?.currentUser = user
            }
        }
        
        print(dataArr)
        
        tableView.separatorColor = (user?.type == .individual) ? .clear : nil
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicTableViewCellReuseIdentifier)
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
        return dataArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as!CardTableViewCell
        
        cell.selectionStyle = .none
        
        
            //let cell1 = cell as! CardTableViewCell
            
            let card = dataArr[indexPath.row] as! Card
            
            cell.cardView.configure(with: card)
            
            /*cell.cardView.qrCodeButtonTappedCallback = { [weak self] in
                let qrCodeViewController = QRCodeViewController()
                qrCodeViewController.card =  card
                self?.navigationController?.pushViewController(qrCodeViewController, animated: true)
            }*/
            
            /*cell.cardView.moreButtonTappedCallback = { [weak self] in
                let manageCardViewController = ManageCardViewController(style: .grouped)
                manageCardViewController.delegate = self
                manageCardViewController.card = card
                self?.present(UINavigationController(rootViewController: manageCardViewController), animated: true, completion: nil)
            }*/
        
        
        return cell
    }
    
    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transactions.count
    }*/
    
    /*func observeCards() {
        userTransactionsRef?.observe(.value) { [weak self] (snapshot) in
            var newCardIds: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let cardId = snapshot.key as String? {
                    newCardIds.append(cardId)
                }
            }
            
            self?.transactionsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
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
    }*/
    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cardTableViewCellReuseIdentifier, for: indexPath) as! CardTableViewCell
        
        let card = transactions[indexPath.row]
        
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
        
        // Configure the cell...

        return cell
    }*/

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
