//
//  CardView.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class CardView: UIView {
    
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
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var detailLabel1: UILabel!
    @IBOutlet weak var dataLabel1: UILabel!
    
    @IBOutlet weak var detailLabel2: UILabel!
    @IBOutlet weak var dataLabel2: UILabel!
    
    @IBOutlet weak var detailLabel3: UILabel!
    @IBOutlet weak var dataLabel3: UILabel!
    
    @IBOutlet weak var detailLabel4: UILabel!
    @IBOutlet weak var dataLabel4: UILabel!
    
    @IBOutlet weak var qrCodeButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    var qrCodeButtonTappedCallback: (() -> Void)?
    var moreButtonTappedCallback: (() -> Void)?
    
    
    @IBOutlet var contentView: UIView!
    
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
        
        Bundle.main.loadNibNamed(String(describing: CardView.self), owner: self, options: nil)
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    @IBAction func qrCodeButtonTapped(_ sender: UIButton) {
        qrCodeButtonTappedCallback?()
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        moreButtonTappedCallback?()
    }
    
}
