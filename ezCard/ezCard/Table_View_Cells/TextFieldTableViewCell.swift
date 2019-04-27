//
//  TextFieldTableViewCell.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    var textFieldEditedAction: ((UITextField) -> Void)?
    
    @IBAction func textFieldEdited(_ sender: UITextField) {
        textFieldEditedAction?(textField)
    }
    
}
