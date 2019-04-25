//
//  Card.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

/// Card class stores all information that is found in a single contact Card made by a User.
class Card {
    
    let ref: DatabaseReference?
    let key: String
    
    let userId: String
    
    let identifier: String
    
    let createdAt: Date
    
    var name: String?
    var fields: [String: String]
    
    var isValid: Bool {
        return ((name?.count ?? 0) > 0 && fields.count > 0)
    }
    
    init(ref: DatabaseReference? = nil, key: String = "", userId: String, identifier: String = UUID().uuidString, createdAt: Date = Date(), name: String? = nil, fields: [String: String] = [:]) {
        self.ref = ref
        self.key = key
        
        self.userId = userId
        
        self.identifier = identifier
        
        self.createdAt = createdAt
        
        self.name = name
        self.fields = fields
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let identifier = value["identifier"] as? String,
            let createdAtRaw = value["createdAt"] as? Double,
            let name = value["name"] as? String,
            let userId = value["userId"] as? String,
            let fields = value["fields"] as? [String: String] else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, userId: userId, identifier: identifier, createdAt: Date(timeIntervalSince1970: createdAtRaw), name: name, fields: fields)
    }
    
    /// For conversion of a Card to Firebase dictionary representation for storage in database.
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "identifier" : identifier,
            "createdAt" : createdAt.timeIntervalSince1970,
            "name": name ?? "",
            "userId": userId,
            "fields": fields
        ]
    }
    
}
