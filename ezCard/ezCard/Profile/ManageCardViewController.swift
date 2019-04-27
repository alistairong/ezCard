//
//  ManageCardViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol ManageCardViewControllerDelegate: class {
    func manageCardViewController(_ manageCardViewController: ManageCardViewController, didFinishWithCard card: Card?)
}

class ManageCardViewController: UITableViewController, UITextFieldDelegate {

    private struct ReuseIdentifiers {
        static let basic = "BasicTableViewCell"
        static let textField = "TextFieldTableViewCell"
        static let centeredText = "CenteredTextTableViewCell"
    }
    
    weak var delegate: ManageCardViewControllerDelegate?
    
    let usersRef = Database.database().reference(withPath: "users")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var user: User!
    var dataItems: [[String: String]] = []
    
    var card: Card? // IMPORTANT: this is only used in viewDidLoad to create a copy in scratchPadCard
    private var scratchPadCard: Card!

    var isEditingCard: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let company = user.company {
            dataItems.append(["field" : "company", "data": company])
        }
        
        if let jobTitle = user.jobTitle {
            dataItems.append(["field" : "job title", "data": jobTitle])
        }
        
        dataItems.append(contentsOf: user.data)
        
        dataItems.sort { (d1, d2) -> Bool in
            var ret = (d1["field"]!).compare(d2["field"]!)
            if ret == .orderedSame, let l1 = d1["label"], let l2 = d2["label"] {
                ret = l1.compare(l2)
            }
            return ret == .orderedAscending
        }
        
        isEditingCard = (card != nil)
        
        if let card = self.card {
            scratchPadCard = Card(ref: card.ref, key: card.key, userId: card.userId, identifier: card.identifier, createdAt: card.createdAt, name: card.name, fields: card.fields)
        } else {
            scratchPadCard = Card(userId: user.uid)
        }
        
        title = (isEditingCard ? "Edit " : "Add ") + "Card"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = scratchPadCard.isValid
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: ReuseIdentifiers.basic)
        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.textField)
        tableView.register(UINib(nibName: "CenteredTextTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.centeredText)
    }
    
    @objc func saveTapped(_ sender: Any?) {
        delegate?.manageCardViewController(self, didFinishWithCard: scratchPadCard)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        delegate?.manageCardViewController(self, didFinishWithCard: nil)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numSections = 2 // one for card name, one for data fields
        if isEditingCard {
            numSections += 1 // if we're editing, a delete row
        }
        return numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return dataItems.count
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier: String!
        if indexPath.section == 0 {
            reuseIdentifier = ReuseIdentifiers.textField
        } else if indexPath.section == 1 {
            reuseIdentifier = ReuseIdentifiers.basic
        } else if indexPath.section == 2 {
            reuseIdentifier = ReuseIdentifiers.centeredText
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 { // card name
            let cell = cell as! TextFieldTableViewCell
            
            cell.textField.placeholder = "Card Name"
            
            cell.textField.text = scratchPadCard.name
            
            cell.textField.delegate = self
            cell.textFieldEditedAction = { [weak self] (textField) in
                guard let strongSelf = self, let name = textField.text else {
                    return
                }
                
                strongSelf.scratchPadCard.name = name
                
                strongSelf.navigationItem.rightBarButtonItem?.isEnabled = strongSelf.scratchPadCard.isValid
            }
        } else if indexPath.section == 1 { // data fields
            let dataItem = dataItems[indexPath.row]
            
            cell.accessoryType = scratchPadCard.fields.contains(dataItem) ? .checkmark : .none
            
            let field = dataItem["field"]!
            
            if let label = dataItem["label"] {
                cell.textLabel?.text = field.capitalized + " (\(label))"
            } else {
                cell.textLabel?.text = field.capitalized
            }
            
            cell.detailTextLabel?.text = dataItem["data"]
            cell.detailTextLabel?.textColor = .lightGray
        } else if indexPath.section == 2 { // remove button
            let cell = cell as! CenteredTextTableViewCell
            
            cell.selectionStyle = .default
            
            cell.titleLabel.textColor = .red
            cell.titleLabel.text = "Delete Card"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldTableViewCell else {
                return
            }
            
            cell.textField.becomeFirstResponder()
        } else if indexPath.section == 1 {
            guard let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            
            let dataItem = dataItems[indexPath.row]
            
            var fields = scratchPadCard.fields
            if let index = fields.firstIndex(of: dataItem) {
                fields.remove(at: index)
            } else {
                fields.append(dataItem)
            }
            
            cell.accessoryType = fields.contains(dataItem) ? .checkmark : .none
            
            scratchPadCard.fields = fields
            
            tableView.reloadData()
            
            navigationItem.rightBarButtonItem?.isEnabled = scratchPadCard.isValid
        } else if indexPath.section == 2 {
            deleteCard()
        }
    }
    
    private func deleteCard() {
        // delete card from user card ids
        usersRef.child(user.key).child("cards").child(card!.key).removeValue()
        
        // delete card from cards top level
        cardsRef.child(card!.key).removeValue()
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}

private class SubtitleTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
