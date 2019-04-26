//
//  ContactViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseDatabase

/// ContactViewController controls what is being populated and shown in the page showing a single contact.
class ContactViewController: UITableViewController, CardRemovalDelegate {
    
    fileprivate struct Constants {
        static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
        static let subtitleTableViewCellReuseIdentifier = "Subtitle"
    }
    
    let activityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    let contactsRef = Database.database().reference(withPath: "contacts")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var contact: Contact!
    
    private var cards: [Card] = []
    private var allSharedFields: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CardTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.cardTableViewCellReuseIdentifier)
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: Constants.subtitleTableViewCellReuseIdentifier)
        
        tableView.separatorColor = .clear
        
        activityIndicatorView.startAnimating()
        tableView.backgroundView = activityIndicatorView
        fetchCards { [weak self] (cards, allSharedFields) in
            guard let self = self else { return }
            
            self.activityIndicatorView.stopAnimating()
            self.tableView.backgroundView = nil
            
            self.cards = cards
            self.allSharedFields = allSharedFields
            
            self.tableView.reloadData()
        }
    }
    
    func fetchCards(completion: @escaping ([Card], [[String: String]]) -> Void) {
        var cards: [Card] = []
        var allSharedFields: [[String: String]] = []
        
        let cardRefs = contact.sharedCardIds.keys.map { (cardId) -> DatabaseReference in
            return cardsRef.child(cardId)
        }
        
        let cardsFetchGroup = DispatchGroup()
        
        for cardRef in cardRefs {
            // lock the group
            cardsFetchGroup.enter()
            
            cardRef.observeSingleEvent(of: .value) { (snapshot) in
                if let card = Card(snapshot: snapshot) {
                    cards.append(card)
                    allSharedFields.append(contentsOf: card.fields)
                }
                
                // after the async work has been completed, unlock the group
                cardsFetchGroup.leave()
            }
        }
        
        // this block will be called after the final cardsFetchGroup.leave() of the looped async functions complete
        cardsFetchGroup.notify(queue: .main) {
            allSharedFields = Array(Set(allSharedFields)) // remove duplicates
            
            allSharedFields.sort { (d1, d2) -> Bool in
                var ret = (d1["field"]!).compare(d2["field"]!)
                if ret == .orderedSame, let l1 = d1["label"], let l2 = d2["label"] {
                    ret = l1.compare(l2)
                }
                return ret == .orderedAscending
            }
            
            completion(cards, allSharedFields)
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return allSharedFields.count
        } else if section == 1 {
            return cards.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier: String!
        if indexPath.section == 0 { // field
            reuseIdentifier = Constants.subtitleTableViewCellReuseIdentifier
        } else if indexPath.section == 1 { // card
            reuseIdentifier = Constants.cardTableViewCellReuseIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 { // field
            let cell = cell as! SubtitleTableViewCell
            
            cell.addSeparatorsIfNecessary()
            cell.needsTopSeparator = (indexPath.row == 0)
            cell.separatorLeftConstraint?.constant = (indexPath.row == allSharedFields.count - 1) ? 0 : cell.layoutMargins.left
            
            let field = allSharedFields[indexPath.row]
            
            cell.detailTextLabel?.textColor = .lightGray
            
            cell.textLabel?.text = field["data"]
            
            var detailText = field["field"]!
            if let label = field["label"] {
                detailText += " (\(label))"
            }
            cell.detailTextLabel?.text = detailText
        } else if indexPath.section == 1 { // card
            let cell = cell as! CardTableViewCell
            
            let card = cards[indexPath.row]
            
            cell.cardView.qrCodeButton.isHidden = true
            
            cell.cardView.configure(with: card)
            
            cell.cardView.moreButtonTappedCallback = { [weak self] in
                guard let self = self else { return }
                
                let expandedCardViewController = ExpandedCardViewController(style: .grouped)
                expandedCardViewController.card = card
                expandedCardViewController.shouldShowRemoveCardButton = true
                expandedCardViewController.removalDelegate = self
                self.present(UINavigationController(rootViewController: expandedCardViewController), animated: true, completion: nil)
            }
        }

        return cell
    }
    
    func removeCard(_ card: Card) {
        // remove card from contact shared card ids
        contact.sharedCardIds.removeValue(forKey: card.key)
        
        if contact.sharedCardIds.count == 0 { // if there are no more shared cards, delete the contact
            contactsRef.child(contact.key).removeValue()
            navigationController?.popViewController(animated: true)
        } else {
            contactsRef.child(contact.key).child("sharedCardIds").child(card.key).removeValue()
        }
        
        // refetch the data
        fetchCards { [weak self] (cards, allSharedFields)  in
            guard let self = self else { return }
            
            self.cards = cards
            self.allSharedFields = allSharedFields
            
            self.tableView.reloadData()
        }
    }
    
}

fileprivate class SubtitleTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let topSeparatorTag = 935828
        static let bottomSeparatorTag = 938582
    }
    private let topSeparator = UIView()
    private let bottomSeparator = UIView()
    
    var needsTopSeparator = false {
        didSet {
            topSeparator.isHidden = !needsTopSeparator
        }
    }
    
    var separatorLeftConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: .subtitle, reuseIdentifier: ContactViewController.Constants.subtitleTableViewCellReuseIdentifier)
    }
    
    func addSeparatorsIfNecessary() {
        if viewWithTag(Constants.topSeparatorTag) == nil {
            topSeparator.tag = Constants.topSeparatorTag
            topSeparator.isHidden = !needsTopSeparator
            topSeparator.translatesAutoresizingMaskIntoConstraints = false
            topSeparator.backgroundColor = UITableView().separatorColor
            addSubview(topSeparator)
            
            NSLayoutConstraint.activate([
                topSeparator.topAnchor.constraint(equalTo: topAnchor),
                topSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                topSeparator.leftAnchor.constraint(equalTo: leftAnchor),
                topSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
            ])
        }
        
        if viewWithTag(Constants.bottomSeparatorTag) == nil {
            bottomSeparator.tag = Constants.bottomSeparatorTag
            bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
            bottomSeparator.backgroundColor = UITableView().separatorColor
            addSubview(bottomSeparator)
            
            separatorLeftConstraint = bottomSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: layoutMargins.left)
            
            NSLayoutConstraint.activate([
                bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomSeparator.rightAnchor.constraint(equalTo: rightAnchor),
                separatorLeftConstraint!,
                bottomSeparator.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
            ])
        }
    }
    
}
