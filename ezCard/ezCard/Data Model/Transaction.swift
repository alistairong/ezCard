//
//  Transaction.swift
//  ezCard
//
//  Created by Alistair Ong on 3/28/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Transaction {
    
    let ref: DatabaseReference?
    let key: String
    
    let userId: String
    
    let identifier: String
    
    let createdAt: Date
    
    var description: String?
    var cardId: String?
    
    var isValid: Bool {
        return ((description?.count ?? 0) > 0 && cardId != nil)
    }
    
    init(ref: DatabaseReference? = nil, key: String = "", userId: String, identifier: String = UUID().uuidString, createdAt: Date = Date(), description: String? = nil, cardId: String? = nil) {
        self.ref = ref
        self.key = key
        
        self.userId = userId
        
        self.identifier = identifier
        
        self.createdAt = createdAt
        
        self.description = description
        self.cardId = cardId
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let identifier = value["identifier"] as? String,
            let createdAtRaw = value["createdAt"] as? Double,
            let userId = value["userId"] as? String,
            let description = value["description"] as? String,
            let cardId = value["cardId"] as? String else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, userId: userId, identifier: identifier, createdAt: Date(timeIntervalSince1970: createdAtRaw), description: description, cardId: cardId)
    }
    
    func toAnyObject() -> Any {
        return [
            "identifier" : identifier,
            "createdAt" : createdAt.timeIntervalSince1970,
            "userId": userId,
            "description": description ?? "",
            "cardId": cardId ?? ""
        ]
    }
    
}
