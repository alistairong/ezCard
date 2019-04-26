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
        
        tableView.tableHeaderView = headerView()
    }

    func headerView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.backgroundColor = .clear
        
        let profileButtonView = ProfileButtonView()
        profileButtonView.userId = card.userId
        headerView.addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = card.name
        nameLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        headerView.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        headerView.addSubview(nameLabel)
    
        return headerView
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
