//
//  ContactViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ContactViewController: UITableViewController {
    
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    var cardIds:[String]?
    var sharedFields:Dictionary<String, String>?
    let usersRef = Database.database().reference(withPath: "users")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.basicTableViewCellReuseIdentifier)
        
        let deleteButton = UIBarButtonItem(title: "Delete Contact".uppercased(), style: .done, target: self, action: #selector(deleteContact))
        deleteButton.tintColor = .red
        navigationItem.rightBarButtonItem = deleteButton
        /*navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: deleteButton, target: self, action: #selector(addTapped(_:)))*/
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
        // #warning Incomplete implementation, return the number of rows
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
        
        let contact = cardIds?[indexPath.row]
        
        if indexPath.section == 1 {
            let cell = cell as!CardTableViewCell
            cardsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
                let child = snapshot.childSnapshot(forPath: contact!)
                if let card = Card(snapshot: child) {
                    cell.cardView.configure(with: card)
                }
            }
        }
        else {
            let keys = Array(sharedFields!.keys)
            let values = Array(sharedFields!.values)
            var label = String(keys[indexPath.row]).padding(toLength: 10, withPad: " ", startingAt: 0)
            label += values[indexPath.row]
            cell.textLabel?.text = label//"\(keys[indexPath.row])  \(values[indexPath.row])"
        }

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
