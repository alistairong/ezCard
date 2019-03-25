//
//  TextFieldTableViewCell.swift
//  ezCard
//
//  Created by Alistair Ong on 3/21/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    var cardNameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        // update UI
        selectionStyle = .none
    }
    
    func getCardNameTextField() -> UITextField {
        return cardNameTextField
    }
}
