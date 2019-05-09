//
//  ExpandedCardViewController.swift
//  ezCard
//
//  Created by Rajat Menhdiratta on 4/5/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

protocol CardRemovalDelegate: class {
    func removeCard(_ card: Card)
}

class ExpandedCardViewController: UITableViewController {
    
    fileprivate struct Constants {
        static let centeredTextTableViewCellReuseIdentifier = "CenteredTextTableViewCell"
        static let subtitleTableViewCellReuseIdentifier = "Subtitle"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    weak var removalDelegate: CardRemovalDelegate?
    
    var shouldShowRemoveCardButton = false
    
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: Constants.subtitleTableViewCellReuseIdentifier)
        tableView.register(UINib(nibName: "CenteredTextTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.centeredTextTableViewCellReuseIdentifier)
        
        let profileButtonView = ProfileButtonView(userId: card.userId)
        
        let nameLabel = UILabel()
        nameLabel.text = card?.name
        
        tableView.tableHeaderView = ProfileHeaderView(width: tableView.bounds.width, height: Constants.tableViewHeaderHeight, yourProfileButtonView: profileButtonView, yourNameLabel: nameLabel)
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return shouldShowRemoveCardButton ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? card.fields.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.section == 1 ? Constants.centeredTextTableViewCellReuseIdentifier : Constants.subtitleTableViewCellReuseIdentifier, for: indexPath)
        
        if indexPath.section == 0 {
            cell.selectionStyle = .none
            
            let field = card.fields[indexPath.row]
            
            cell.detailTextLabel?.textColor = .lightGray
            
            cell.textLabel?.text = field["data"]
            
            var detailText = field["field"]!
            if let label = field["label"] {
                detailText += " (\(label))"
            }
            cell.detailTextLabel?.text = detailText
        } else if indexPath.section == 1 {
            let cell = cell as! CenteredTextTableViewCell
            
            cell.selectionStyle = .default
            
            cell.titleLabel.textColor = .red
            cell.titleLabel.text = "Remove Card"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            removeCard()
        }
    }
    
    /// Removes the card from the contact
    private func removeCard() {
        removalDelegate?.removeCard(card)
        dismiss(animated: true, completion: nil)
    }
  
}

private class SubtitleTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: .subtitle, reuseIdentifier: ExpandedCardViewController.Constants.subtitleTableViewCellReuseIdentifier)
    }
    
}
