//
//  Contact.swift
//  ezCard
//
//  Created by Alistair Ong on 3/28/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

/// Contact class stores all information of a Contact, which is an aggregation of all contact Cards
/// scanned and saved from a specific User.
class Contact {
    
    let ref: DatabaseReference?
    let key: String
    
    let actualUserId: String
    let holdingUserId: String
    
    var sharedCardIds: [String: Bool]
    
    init(ref: DatabaseReference? = nil, key: String = "", holdingUserId: String, actualUserId: String, sharedCardIds: [String: Bool] = [:]) {
        self.ref = ref
        self.key = key
        
        self.holdingUserId = holdingUserId
        self.actualUserId = actualUserId

        self.sharedCardIds = sharedCardIds
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let holdingUserId = value["holdingUserId"] as? String,
            let actualUserId = value["actualUserId"] as? String,
            let sharedCardIds = value["sharedCardIds"] as? [String: Bool]
        else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, holdingUserId: holdingUserId, actualUserId: actualUserId, sharedCardIds: sharedCardIds)
    }
    
    /// For conversion of a Contact to Firebase dictionary representation for storage in database.
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "actualUserId": actualUserId,
            "holdingUserId": holdingUserId,
            "sharedCardIds": sharedCardIds
        ]
    }
    
}
