//
//  ProfileHeaderView.swift
//  ezCard
//
//  Created by Caleb Hamada on 4/24/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

/// Used to create Profile Header View by using a profile button view
class ProfileHeaderView: UIView {
    
    var profileButtonView = ProfileButtonView()
    var nameLabel = UILabel()
    
    convenience init(width:CGFloat, height:CGFloat, yourProfileButtonView: ProfileButtonView, yourNameLabel:UILabel) {
        self.init()
        
        profileButtonView = yourProfileButtonView
        nameLabel = yourNameLabel
        
        self.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        addSubview(nameLabel)
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
}
