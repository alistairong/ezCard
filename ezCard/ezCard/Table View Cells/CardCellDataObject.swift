//
//  CardCellDataObject.swift
//  ezCard
//
//  Created by Alistair Ong on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation

class CardCellDataObject {
    var title = Constants.blank
    
    var detailLabel1 = Constants.blank
    var dataLabel1 = Constants.blank
    
    var detailLabel2 = Constants.blank
    var dataLabel2 = Constants.blank
    
    var detailLabel3 = Constants.blank
    var dataLabel3 = Constants.blank
    
    var detailLabel4 = Constants.blank
    var dataLabel4 = Constants.blank
    
    init() {}
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func getTitle() -> String {
        return self.title
    }
}
