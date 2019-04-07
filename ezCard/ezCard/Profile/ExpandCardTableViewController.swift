//
//  ExpandCardTableViewController.swift
//  ezCard
//
//  Created by Rajat Menhdiratta on 4/5/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

protocol ExpandCardViewControllerDelegate: class {
    func expandCardViewController(_ expandCardViewController: ExpandCardViewController, didFinishWithCard card: Card?)
}

class ExpandCardViewController: UITableViewController, UITextFieldDelegate{

    private struct ReuseIdentifiers {
        static let basic = "BasicTableViewCell"
        static let textField = "TextFieldTableViewCell"
    }
    private struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let basicTableViewCellReuseIdentifier = "Basic"
        static let tableViewHeaderHeight = CGFloat(117.0)
    }
    
    weak var delegate: ExpandCardViewControllerDelegate?
    var availableFields = ["phone", "email", "github", "facebook", "snapchat"]
    var availableData = ["555-555-5555" , "name@gmail.com", "github.com", "facebook.com", "snapchat.com"]
    var card: Card? // IMPORTANT: this is only used in viewDidLoad to create a copy in scratchPadCard
    private var scratchPadCard: Card!
    
    var isEditingCard: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        addHeader()
        
        isEditingCard = (card != nil)
        
        if let card = self.card {
            scratchPadCard = Card(ref: card.ref, key: card.key, userId: card.userId, identifier: card.identifier, createdAt: card.createdAt, name: card.name, fields: card.fields)
        } else {
            scratchPadCard = Card(userId: User.current!.uid)
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIdentifiers.basic)
        tableView.register(UINib(nibName: "TextFieldTableViewCell", bundle: nil), forCellReuseIdentifier: ReuseIdentifiers.textField)
        
        let footerView = UIView(frame: CGRect(x: 0,y: 10,width: 415,height: 45))
        let button = UIButton(frame: CGRect(x: 0, y: 10, width: 415, height: 45))
        button.setTitle("Remove Contact", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(removeContact(_:)), for: .touchUpInside)
        
        footerView.addSubview(button)
        tableView.tableFooterView = footerView
        
        
      
    }


    func addHeader()
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: Constants.tableViewHeaderHeight))
        headerView.backgroundColor = .clear
        
        let profileButtonView = ProfileButtonView()
        headerView.addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16).isActive = true
        
        
        
        let nameLabel = UILabel()
        nameLabel.text = card?.name
        nameLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        headerView.addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        headerView.addSubview(nameLabel)
        
        self.view.addSubview(headerView)
    }
    
    @objc func removeContact(_ sender: Any?)
    {
        print("removing contact")
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        delegate?.expandCardViewController(self, didFinishWithCard: nil)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // one for card name, one for data fields
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? 1 : availableFields.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: (indexPath.section == 0) ? ReuseIdentifiers.textField : ReuseIdentifiers.basic, for: indexPath)
        
        cell.selectionStyle = .none
        if indexPath.section != 0
        {
            let field = availableFields[indexPath.row]
            let data = availableData[indexPath.row]
            
            cell.textLabel?.text = field
            cell.detailTextLabel?.text = data
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:200,height:20))
            label.text = data
            cell.accessoryView = label
        }
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - UITextFieldDelegate
    
    
  
}
