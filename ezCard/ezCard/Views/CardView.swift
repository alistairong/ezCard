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
        static let numFieldsShown = 4
    }
    
    
    // outlets for all variables in card view
    @IBOutlet weak var profileButtonView: ProfileButtonView!
    
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
    
    // Used to configure cards in card view by passing in a card
    func configure(with card: Card) {
        titleLabel.text = card.name
        
        profileButtonView.userId = card.userId
        
        detailLabel1.text = nil
        dataLabel1.text = nil
        detailLabel2.text = nil
        dataLabel2.text = nil
        detailLabel3.text = nil
        dataLabel3.text = nil
        detailLabel4.text = nil
        dataLabel4.text = nil
        
        var counter = 1
        for data in card.fields {
            if counter > Constants.numFieldsShown {
                break
            }
            
            let field = data["field"]!
            let value = data["data"]
            
            if counter == 1 {
                detailLabel1.text = field
                dataLabel1.text = value
            } else if counter == 2 {
                detailLabel2.text = field
                dataLabel2.text = value
            } else if counter == 3 {
                detailLabel3.text = field
                dataLabel3.text = value
            } else if counter == 4 {
                detailLabel4.text = field
                dataLabel4.text = value
            }
            
            counter += 1
        }
    }
    
}
