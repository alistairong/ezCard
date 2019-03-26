//
//  CardViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import Firebase
import ContactsUI

class CardViewController: UITableViewController {
    private var selectedCardItems: [Bool] = [
        false, false, false, false, false, false,
        false, false
    ]
    
    private var cardNameTextField: UITextField!
    private var cardType: String!
    
    var cardDataSource: CardCellDataObject!
    var cardDelegate: CardTableViewCell!
    var profileDelegate: ProfileViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (cardDataSource != nil && cardDelegate != nil) {
            cardType = Constants.typeEditCard
            selectedCardItems = cardDelegate.selectedCardItems
        } else {
            cardType = Constants.typeAddCard
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.identifierDefaultCell)
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: Constants.identifierTextInputCell)
    }
    
    @objc func saveTapped(_ sender: Any?) {
        // TODO: save the changes to the card
        cardDelegate?.titleLabel?.text = cardNameTextField.text
        cardDelegate?.selectedCardItems = selectedCardItems
        
        if (cardType == Constants.typeAddCard) {
            profileDelegate.addProfileCard(cardTitle: cardNameTextField.text!, selectedCardItems: selectedCardItems)
//            profileDelegate.addProfileCard(cardDelegate: cardDelegate)
        } else {
            profileDelegate.editProfileCard(cellIndex: cardDelegate.cellIndex, cardTitle: cardNameTextField.text!, selectedCardItems: selectedCardItems)
//            profileDelegate.editProfileCard(cardDelegate: cardDelegate)
        }
        
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
        if section < Constants.numberOfRowsAtSection.count {
            rows = Constants.numberOfRowsAtSection[section]
        }
        
        return rows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TextFieldTableViewCell {
        // if first section, instantiate textfield for name of card
        var cell: TextFieldTableViewCell!
        let isFirstSection = (indexPath.section == Constants.firstSection)
        let currentRow = indexPath.row
        
        if (isFirstSection) {
            cell = createFirstTableRow(tableView)
        } else {
            cell = (tableView.dequeueReusableCell(withIdentifier: Constants.identifierTextInputCell, for: indexPath) as! TextFieldTableViewCell)
            
            let cardItem = Constants.cardItems[currentRow]
            cell.textLabel?.text = cardItem
        }
        
        if (cardType == Constants.typeEditCard) {
            if (isFirstSection) {
                cell.cardNameTextField?.text = cardDataSource.getTitle()
            } else {
                setCheckmark(cell: cell, row: currentRow)
            }
        }
        
        return cell
    }
    
    func createFirstTableRow(_ tableView: UITableView) -> TextFieldTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.identifierTextInputCell) as! TextFieldTableViewCell
        
        let tf = UITextField(frame: CGRect(x: 20, y: 12, width: 300, height: 20))
        tf.text = cardDataSource?.getTitle()
        tf.placeholder = Constants.placeholder
        tf.font = UIFont.systemFont(ofSize: 17)
        
        cell.cardNameTextField = tf
        self.cardNameTextField = tf
        
        cell.addSubview(tf)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isCardItems = indexPath.section != Constants.firstSection
        
        if (isCardItems) {
            //resign responder of card name input cell
            self.cardNameTextField.resignFirstResponder()
            
            let cell = tableView.cellForRow(at: indexPath)
            let currentRow = indexPath.row
            
            toggleCheckmark(cell: cell, row: currentRow)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == Constants.firstSection) {
            return Constants.cardName
        } else {
            return Constants.cardInfoToAdd
        }
    }
    
    // MARK: - Utility Functions
    func setCardItem(row: Int, selected: Bool) {
        selectedCardItems[row] = selected
    }
    
    func setCheckmark(cell: UITableViewCell?, row: Int) {
        let hasCheckmark = (selectedCardItems[row] == true)
        
        if (hasCheckmark) {
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            setCardItem(row: row, selected: true)
        } else {
            cell?.accessoryType = UITableViewCell.AccessoryType.none
            setCardItem(row: row, selected: false)
        }
    }
    
    func toggleCheckmark(cell: UITableViewCell?, row: Int) {
        let hasCheckmark = (cell?.accessoryType == UITableViewCell.AccessoryType.checkmark)
        
        if (hasCheckmark) {
            cell?.accessoryType = UITableViewCell.AccessoryType.none
            setCardItem(row: row, selected: false)
        } else {
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            setCardItem(row: row, selected: true)
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
