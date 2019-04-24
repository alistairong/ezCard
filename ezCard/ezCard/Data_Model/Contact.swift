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
    
    let actualUserId: String
    let holdingUserId: String
    
    var sharedCardIds: [String: Bool]
    var allSharedFields: [String: String]

    init(ref: DatabaseReference? = nil, key: String = "", holdingUserId: String, actualUserId: String, sharedCardIds: [String: Bool] = [:], allSharedFields: [String: String] = [:]) {
        self.ref = ref
        self.key = key
        
        self.holdingUserId = holdingUserId
        self.actualUserId = actualUserId

        self.sharedCardIds = sharedCardIds
        self.allSharedFields = allSharedFields
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let holdingUserId = value["holdingUserId"] as? String,
            let actualUserId = value["actualUserId"] as? String,
            let sharedCardIds = value["sharedCardIds"] as? [String: Bool],
            let allSharedFields = value["allSharedFields"] as? [String: String] else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, holdingUserId: holdingUserId, actualUserId: actualUserId, sharedCardIds: sharedCardIds, allSharedFields: allSharedFields)
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "actualUserId": actualUserId,
            "holdingUserId": holdingUserId,
            "sharedCardIds": sharedCardIds,
            "allSharedFields": allSharedFields
        ]
    }
    
}
