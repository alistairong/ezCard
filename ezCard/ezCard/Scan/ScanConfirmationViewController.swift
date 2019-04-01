//
//  ScanConfirmationViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class ScanConfirmationViewController: UITableViewController {
    
    private struct ReuseIdentifiers {
        static let card = "CardTableViewCell"
        static let centeredText = "CenteredTextTableViewCell"
    }
    
    private struct Constants {
        static let topSeparatorTag = 983743
        static let bottomSeparatorTag = 983742
        static let labelPadding = CGFloat(20)
        static let footerBottomPadding = CGFloat(75)
    }
    
    var separatorColor: UIColor?
    
    var card: Card!
    var sharingUserName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        separatorColor = tableView.separatorColor
        tableView.separatorColor = .clear
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.card)
        tableView.register(UINib(nibName: "CenteredTextTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.centeredText)
    }
    
    func acceptTransaction() {
        // TODO: accept the transaction (add contact to current user's contact list)
        
        dismiss(animated: true, completion: nil)
    }
    
    func declineTransaction() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.section == 0) ? ReuseIdentifiers.card : ReuseIdentifiers.centeredText, for: indexPath)

        if indexPath.section != 0 && cell.viewWithTag(Constants.bottomSeparatorTag) == nil && cell.viewWithTag(Constants.topSeparatorTag) == nil {
            let topSeparator = UIView()
            topSeparator.tag = Constants.topSeparatorTag
            topSeparator.translatesAutoresizingMaskIntoConstraints = false
            topSeparator.backgroundColor = separatorColor
            cell.addSubview(topSeparator)
            
            topSeparator.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            topSeparator.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            topSeparator.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            topSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
            
            let bottomSeparator = UIView()
            bottomSeparator.tag = Constants.bottomSeparatorTag
            bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
            bottomSeparator.backgroundColor = separatorColor
            cell.addSubview(bottomSeparator)
            
            bottomSeparator.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
            bottomSeparator.rightAnchor.constraint(equalTo: cell.rightAnchor).isActive = true
            bottomSeparator.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale).isActive = true
        }
        
        if indexPath.section == 0 { // card
            let topSeparator = cell.viewWithTag(Constants.topSeparatorTag)
            topSeparator?.removeFromSuperview()
            let bottomSeparator = cell.viewWithTag(Constants.bottomSeparatorTag)
            bottomSeparator?.removeFromSuperview()
            
            let cell = cell as! CardTableViewCell
            
            cell.cardView.configure(with: card)
            
            cell.cardView.qrCodeButton.isHidden = true
            
            // TODO: implement more button callback
        } else if indexPath.section == 1 { // accept
            let cell = cell as! CenteredTextTableViewCell
            
            cell.titleLabel.text = "Confirm".uppercased()
            cell.titleLabel.textColor = .green
        } else if indexPath.section == 2 { // decline
            let cell = cell as! CenteredTextTableViewCell
            
            cell.titleLabel.text = "Decline".uppercased()
            cell.titleLabel.textColor = .red
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sharingUserName = self.sharingUserName, let card = self.card, section == 0 else {
            return nil
        }
        
        return "\(sharingUserName) would like to share \(card.name == nil ? "a card" : "their \"\(card.name!)\" card") with you."
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 0 else {
            return nil
        }
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - Constants.labelPadding * 2, height: CGFloat.greatestFiniteMagnitude))
        containerView.clipsToBounds = true
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = self.tableView(tableView, titleForFooterInSection: section)
        label.sizeToFit()
        label.frame.origin = CGPoint(x: Constants.labelPadding, y: Constants.labelPadding / 2)
        
        containerView.frame.size = CGSize(width: label.bounds.width, height: label.bounds.height + Constants.labelPadding / 2 + Constants.footerBottomPadding)
        containerView.addSubview(label)
        
        return containerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == 0 else {
            return 0
        }
        
        let view = self.tableView(tableView, viewForFooterInSection: section)!
        return view.bounds.height
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 { // accept
            acceptTransaction()
        } else if indexPath.section == 2 { // decline
            declineTransaction()
        }
    }
    
}
