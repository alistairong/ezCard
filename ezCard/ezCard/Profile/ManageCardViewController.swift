//
//  ManageCardViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

protocol ManageCardViewControllerDelegate: class {
    func manageCardViewController(_ manageCardViewController: ManageCardViewController, didFinishWithCard card: Card?)
}

class ManageCardViewController: UITableViewController, UITextFieldDelegate {

    private struct ReuseIdentifiers {
        static let basic = "BasicTableViewCell"
        static let textField = "TextFieldTableViewCell"
    }
    
    weak var delegate: ManageCardViewControllerDelegate?
    
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
        return (section == 0) ? 1 : dataItems.count
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
        
        if indexPath.section == 0 {
            (cell as! TextFieldTableViewCell).becomeFirstResponder()
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
