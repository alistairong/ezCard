//
//  CardCellDataObject.swift
//  ezCard
//
//  Created by Alistair Ong on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation

class CardCellDataObject {
    var title = ""
    
    var detailLabel1 = ""
    var dataLabel1 = ""
    
    var detailLabel2 = ""
    var dataLabel2 = ""
    
    var detailLabel3 = ""
    var dataLabel3 = ""
    
    var detailLabel4 = ""
    var dataLabel4 = ""
    
    init() {}
    
    func setTitle(title: String) {
        self.title = title
    }
    
    func getTitle() -> String {
        return self.title
    }
}
