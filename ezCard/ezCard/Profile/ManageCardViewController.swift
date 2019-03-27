//
//  ManageCardViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ManageCardViewControllerDelegate: class {
    func manageCardViewController(_ manageCardViewController: ManageCardViewController, didFinishWithCard card: Card?)
}

class ManageCardViewController: UITableViewController, UITextFieldDelegate {

    private struct ReuseIdentifiers {
        static let basic = "BasicTableViewCell"
        static let textField = "TextFieldTableViewCell"
    }
    
    weak var delegate: ManageCardViewControllerDelegate?
    
    var availableFields = ["phone", "email", "github"]
    
    var card: Card? // IMPORTANT: this is only used in viewDidLoad to create a copy in scratchPadCard
    private var scratchPadCard: Card!

    var isEditingCard: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEditingCard = (card != nil)
        
        if let card = self.card {
            scratchPadCard = Card(ref: card.ref, key: card.key, userId: card.userId, identifier: card.identifier, createdAt: card.createdAt, name: card.name, fields: card.fields)
        } else {
            scratchPadCard = Card(userId: Auth.auth().currentUser!.uid)
        }
        
        title = (isEditingCard ? "Edit " : "Add ") + "Card"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark"), style: .plain, target: self, action: #selector(saveTapped(_:)))
        navigationItem.rightBarButtonItem?.isEnabled = scratchPadCard.isValid
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifiers.basic)
        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.textField)
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
        return 2 // one for card name, one for data fields
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : availableFields.count // TODO: replace 0 with number of data fields present on user profile
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.section == 0) ? ReuseIdentifiers.textField : ReuseIdentifiers.basic, for: indexPath)

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
            let field = availableFields[indexPath.row]
            
            cell.accessoryType = scratchPadCard.fields.keys.contains(field) ? .checkmark : .none
            cell.textLabel?.text = field
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let field = availableFields[indexPath.row]
        
        var fields = scratchPadCard.fields
        if fields.keys.contains(field) {
            fields.removeValue(forKey: field)
        } else {
            fields[field] = "..." // TODO: set card field to user data
        }
        
        cell.accessoryType = fields.keys.contains(field) ? .checkmark : .none
        
        scratchPadCard.fields = fields
        
        navigationItem.rightBarButtonItem?.isEnabled = scratchPadCard.isValid
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }

}
