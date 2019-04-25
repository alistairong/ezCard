//
//  DataFieldTableViewCell.swift
//  ezCard
//
//  Created by Andrew Whitehead on 4/15/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class DataFieldTableViewCell: TextFieldTableViewCell {

    @IBOutlet weak var button: UIButton!
    
    var buttonAction: (() -> Void)?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonAction?()
    }
    
}
