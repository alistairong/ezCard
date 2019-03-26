//
//  CardTableViewCell.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    var delegate: ProfileViewController!

    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var detailLabel1: UILabel?
    @IBOutlet weak var dataLabel1: UILabel?
    
    @IBOutlet weak var detailLabel2: UILabel?
    @IBOutlet weak var dataLabel2: UILabel?
    
    @IBOutlet weak var detailLabel3: UILabel?
    @IBOutlet weak var dataLabel3: UILabel?
    
    @IBOutlet weak var detailLabel4: UILabel?
    @IBOutlet weak var dataLabel4: UILabel?
    
    @IBAction func editCard(_ sender: Any) {
        var cardData = CardCellDataObject()
        cardData.setTitle(title: (self.titleLabel?.text)!)
        delegate.tapEditCard(cardData: cardData, cardCell: self)
    }
}
