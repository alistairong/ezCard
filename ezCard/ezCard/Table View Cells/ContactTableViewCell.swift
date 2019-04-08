//
//  ContactTableViewCell.swift
//  ezCard
//
//  Created by Andrew Whitehead on 4/7/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    private struct Constants {
        static let shadowOffset = CGFloat(2.0)
    }
    
    @IBOutlet weak var profileImageContainerView: UIView! {
        didSet {
            profileImageContainerView.layer.borderWidth = 3.0
            profileImageContainerView.layer.borderColor = UIColor.white.cgColor
            profileImageContainerView.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffset)
            profileImageContainerView.layer.shadowRadius = 2.0
            profileImageContainerView.layer.shadowOpacity = 0.5
        }
    }
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.image = profileImageView.image?.withRenderingMode(.alwaysTemplate)
            profileImageView.tintColor = .darkGray
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        profileImageContainerView.backgroundColor = .lightGray
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        profileImageContainerView.backgroundColor = .lightGray
    }
    
}
