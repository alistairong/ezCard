//
//  Constants.swift
//  ezCard
//
//  Created by Alistair Ong on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    // MARK: - Profile View Controller
    static let cardTableViewCellReuseIdentifier = "CardTableViewCell"
    static let tableViewHeaderHeight = CGFloat(117.0)
    static let cardTitle = "cardTitle"
    
    // MARK: - Profile Button Search Bar Nav
    static let profileButtonViewPadding = CGFloat(6.0)
    
    // MARK: - Card View Controller
    static let numberOfRowsAtSection: [Int] = [1, 8]
    static let firstSection = 0
    static let identifierDefaultCell = "reuseIdentifier"
    static let identifierTextInputCell = "textInputCell"
    static let placeholder = "Enter card name"
    static let cardName = "Card Name"
    static let cardInfoToAdd = "Add Info to Card"
    static let typeAddCard = "typeAddCard"
    static let typeEditCard = "typeEditCard"
    
    static let cardItems: [String] = [
        "Phone", "Email", "Address", "Company", "Facebook",
        "LinkedIn", "GitHub", "Resume"
    ]
    
    // MARK: - General
    static let blank = ""
    
}
