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
    
    private var selectedCardItems: [Bool] = [
        false, false, false, false, false, false,
        false, false
    ]
    
    private var cardNameTextField: UITextField!
    
    private let numberOfRowsAtSection: [Int] = [1, 8]
    private let firstSection = 0
    private let defaultCellIdentifier = "reuseIdentifier"
    private let textInputCellIdentifier = "textInputCell"
    private let placeholder = "Enter card name"
    private let cardName = "Card Name"
    private let cardInfoToAdd = "Add Info to Card"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Card" // TODO: change to "Add Card" or "Edit Card" depending on which is happening

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: textInputCellIdentifier)
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TextFieldTableViewCell {
        // if first section, instantiate textfield for name of card
        if (indexPath.section == firstSection) {
            return createFirstTableRow(tableView)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: textInputCellIdentifier, for: indexPath)
            
            let cardItem = cardItems[indexPath.row]
            cell.textLabel?.text = cardItem
            
            return cell as! TextFieldTableViewCell
        }
    }
    
    func createFirstTableRow(_ tableView: UITableView) -> TextFieldTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textInputCellIdentifier) as! TextFieldTableViewCell
        
        let tf = UITextField(frame: CGRect(x: 20, y: 12, width: 300, height: 20))
        tf.placeholder = placeholder
        tf.font = UIFont.systemFont(ofSize: 17)
        
        cell.cardNameTextField = tf
        self.cardNameTextField = tf
        
        cell.addSubview(tf)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCardItems = indexPath.section != firstSection
        
        if (isCardItems) {
            //resign responder of card name input cell
            self.cardNameTextField.resignFirstResponder()
            
            let cell = tableView.cellForRow(at: indexPath)
            let currentRow = indexPath.row
            
            let hasCheckmark = (cell?.accessoryType == UITableViewCell.AccessoryType.checkmark)

            if (hasCheckmark) {
                cell?.accessoryType = UITableViewCell.AccessoryType.none
                setCardItem(row: currentRow, selected: false)
            } else {
                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                setCardItem(row: currentRow, selected: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == firstSection) {
            return cardName
        } else {
            return cardInfoToAdd
        }
    }
    
    // MARK: - Utility Functions
    func setCardItem(row: Int, selected: Bool) {
        selectedCardItems[row] = selected
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
