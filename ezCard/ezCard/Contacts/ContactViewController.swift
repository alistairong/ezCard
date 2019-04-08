//
//  ContactViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ContactViewController: UITableViewController {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
    }
    
    var cardIds:[String]?
    var sharedFields:Dictionary<String, String>?
    let usersRef = Database.database().reference(withPath: "users")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicTableViewCellReuseIdentifier)
        
        let deleteButton = UIBarButtonItem(title: "Delete Contact".uppercased(), style: .done, target: self, action: #selector(deleteContact))
        deleteButton.tintColor = .red
        navigationItem.rightBarButtonItem = deleteButton
    }
    
    @objc func deleteContact() {
        let controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        controller.addAction(UIAlertAction(
            title: "Delete",
            style: .destructive,
            handler: {(alert: UIAlertAction!) in
                self.navigationController?.popViewController(animated: true)
                print("Delete")}))
        present(controller, animated: true, completion: nil)
    }
    
    /*
    func removeContact() {
        // TODO: remove shown contact from current user's contact list
     
        navigationController?.popViewController(animated: true)
    }
    */

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sharedFields!.count
        }
        return cardIds!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        if indexPath.section == 0 {
            reuseIdentifier = Constants.basicTableViewCellReuseIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.section == 1 {
            let contact = cardIds?[indexPath.row]
            
            let cell = cell as! CardTableViewCell
            
            cell.cardView.qrCodeButton.isHidden = true
            
            cardsRef.observeSingleEvent(of: .value) { (snapshot) in
                let child = snapshot.childSnapshot(forPath: contact!)
                if let card = Card(snapshot: child) {
                    cell.cardView.configure(with: card)
                    
                    cell.cardView.moreButtonTappedCallback = { [weak self] in
                        guard let self = self else { return }
                        
                        let expandedCardViewController = ExpandedCardViewController(style: .grouped)
                        expandedCardViewController.card = card
                        self.present(UINavigationController(rootViewController: expandedCardViewController), animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            let keys = Array(sharedFields!.keys)
            let values = Array(sharedFields!.values)
            var label = String(keys[indexPath.row]).padding(toLength: 10, withPad: " ", startingAt: 0)
            label += values[indexPath.row]
            cell.textLabel?.text = label
        }

        return cell
    }
    
}
