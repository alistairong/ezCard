//
//  ProfilePictureAndNameView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class ProfilePictureAndNameView: UIView {

    private var profileButtonView: ProfileButtonView!
    var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        
        profileButtonView = ProfileButtonView()
        profileButtonView.isUserInteractionEnabled = false
        addSubview(profileButtonView)
        
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        profileButtonView.widthAnchor.constraint(equalTo: profileButtonView.heightAnchor).isActive = true
        profileButtonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        profileButtonView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        profileButtonView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        addSubview(nameLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.leadingAnchor.constraint(equalTo: profileButtonView.trailingAnchor, constant: 20).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        profileButtonView?.layoutSubviews()
    }
    
}
