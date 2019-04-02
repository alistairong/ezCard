//
//  Contact.swift
//  ezCard
//
//  Created by Alistair Ong on 3/28/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Contact {
    
    let ref: DatabaseReference?
    let key: String
    
    let userId: String
    
    let identifier: String
    
    let createdAt: Date
    
    var name: String?
    var cardIds: [String]
    var fields: [String: String]
    
    var isValid: Bool {
        return ((name?.count ?? 0) > 0 && cardIds.count > 0 && fields.count > 0)
    }
    
    init(ref: DatabaseReference? = nil, key: String = "", userId: String, identifier: String = UUID().uuidString, createdAt: Date = Date(), name: String? = nil, cardIds: [String] = [], fields: [String: String] = [:]) {
        self.ref = ref
        self.key = key
        
        self.userId = userId
        
        self.identifier = identifier
        
        self.createdAt = createdAt
        
        self.name = name
        self.cardIds = cardIds
        self.fields = fields
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let identifier = value["identifier"] as? String,
            let createdAtRaw = value["createdAt"] as? Double,
            let name = value["name"] as? String,
            let userId = value["userId"] as? String,
            let cardIds = value["cardIds"] as? [String],
            let fields = value["fields"] as? [String: String] else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, userId: userId, identifier: identifier, createdAt: Date(timeIntervalSince1970: createdAtRaw), name: name, cardIds: cardIds, fields: fields)
    }
    
    func toAnyObject() -> Any {
        return [
            "identifier" : identifier,
            "createdAt" : createdAt.timeIntervalSince1970,
            "name": name ?? "",
            "userId": userId,
            "cardIds": cardIds,
            "fields": fields
        ]
    }
    
}
