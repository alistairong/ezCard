//
//  CardViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class CardViewController: UITableViewController {
    
    private let cardItems: [String] = [
    "Phone", "Email", "Address", "Company", "Facebook",
    "LinkedIn", "GitHub", "Resume"
    ]
    
    private let numberOfRowsAtSection: [Int] = [1, 8]
    private let firstSection = 0
    private let defaultCellIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Card" // TODO: change to "Add Card" or "Edit Card" depending on which is happening

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
//        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "textInputCell")
    }
    
    @objc func saveTapped(_ sender: Any?) {
        // TODO: save the changes to the card
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table View Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        var rows: Int = 0
        
        // if first section, instantiate only 1 row for name of card
        if section < numberOfRowsAtSection.count {
            rows = numberOfRowsAtSection[section]
        }
        
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if first section, instantiate textfield for name of card
        if (indexPath.section == firstSection) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "textInputCell") as! TextFieldTableViewCell
//
//            cell.textChanged {[weak tableView] (_) in
//                tableView?.beginUpdates()
//                tableView?.endUpdates()
//            }
//
//            return cell
            return createTableRow(tableView)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier, for: indexPath)
            
            let cardItem = cardItems[indexPath.row]
            cell.textLabel?.text = cardItem
            
            return cell
        }
    }
    
    func createTableRow(_ tableView: UITableView) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier) as! UITableViewCell
        
        let tf = UITextField(frame: CGRect(x: 20, y: 12, width: 300, height: 20))
        tf.placeholder = "Enter card name"
        tf.font = UIFont.systemFont(ofSize: 17)
        
        cell.addSubview(tf)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCardItems = indexPath.section != firstSection
        
        if (isCardItems) {
            let hasCheckmark = (tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCell.AccessoryType.checkmark)
            
            if (hasCheckmark) {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.none
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        
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

}
