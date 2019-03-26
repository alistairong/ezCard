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
    }
    
    var separatorColor: UIColor?
    
    var qrMetadata: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Showing scan confirmation VC for metadata:", qrMetadata)
        
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
