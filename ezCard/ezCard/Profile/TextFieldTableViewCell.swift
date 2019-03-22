//
//  TextFieldTableViewCell.swift
//  ezCard
//
//  Created by Alistair Ong on 3/21/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var cardNameTextView: UITextView!
    var textChanged: ((String) -> Void)?
//    var testTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
//        let view = UIView(frame: someFrame)
//        testTextField = UITextField(frame: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0))
//
        cardNameTextView.delegate = self as! UITextViewDelegate
        self.addSubview(cardNameTextView)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(text: String?, placeholder: String?) {
//        testTextField.text = text
//        testTextField.placeholder = placeholder
//
//        testTextField.accessibilityValue = text
//        testTextField.accessibilityLabel = placeholder
    }
    
    func textChanged(action: @escaping (String) -> Void) {
        self.textChanged = action
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
    }
    
}
