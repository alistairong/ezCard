//
//  ProfileButtonView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class ProfileButtonView: UIView {
    
    private struct Constants {
        static let defaultProfileButtonSize = CGFloat(40.0)
        static let shadowOffset = CGFloat(2.0)
    }
    
    var tappedCallback: (() -> Void)?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.defaultProfileButtonSize, height: Constants.defaultProfileButtonSize))
        
        commonInit()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        let profileButton = UIButton(frame: CGRect(x: 0, y: -Constants.shadowOffset, width: frame.width, height: frame.height))
        profileButton.backgroundColor = .lightGray
        profileButton.layer.cornerRadius = profileButton.frame.width / 2
        profileButton.layer.borderWidth = 3.0
        profileButton.layer.borderColor = UIColor.white.cgColor
        profileButton.layer.masksToBounds = false
        profileButton.layer.shadowOffset = CGSize(width: 0, height: Constants.shadowOffset)
        profileButton.layer.shadowRadius = 2.0
        profileButton.layer.shadowOpacity = 0.5
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        addSubview(profileButton)
        
        let profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: profileButton.frame.width, height: profileButton.frame.height))
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.tintColor = .darkGray
        profileImageView.image = #imageLiteral(resourceName: "person") // TODO: load profile image
        profileImageView.contentMode = .bottom // TODO: .aspectFill if profile image != nil
        
        profileButton.addSubview(profileImageView)
    }
    
    @objc private func profileButtonTapped(_ sender: Any?) {
        tappedCallback?()
    }

}
