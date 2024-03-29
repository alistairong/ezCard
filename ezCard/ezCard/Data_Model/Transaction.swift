//
//  Transaction.swift
//  ezCard
//
//  Created by Alistair Ong on 3/28/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

/// Transaction class stores all the data associated with a particular transaction, which encompasses
/// the scanning of cards.
/// Transactions will be shown on the home feed.
class Transaction {
    
    let ref: DatabaseReference?
    let key: String
    
    let userId: String
    
    let identifier: String
    
    let createdAt: Date
    
    var cardId: String
    
    var otherUserDisplayName: String
    
    init(ref: DatabaseReference? = nil, key: String = "", userId: String, identifier: String = UUID().uuidString, createdAt: Date = Date(), cardId: String, otherUserDisplayName: String) {
        self.ref = ref
        self.key = key
        
        self.userId = userId
        
        self.identifier = identifier
        
        self.createdAt = createdAt
        
        self.cardId = cardId
        
        self.otherUserDisplayName = otherUserDisplayName
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let identifier = value["identifier"] as? String,
            let createdAtRaw = value["createdAt"] as? Double,
            let userId = value["userId"] as? String,
            let cardId = value["cardId"] as? String else {
                return nil
        }
        
        let otherUserDisplayName = value["otherUserDisplayName"] as? String ?? "Someone"
        
        self.init(ref: snapshot.ref, key: snapshot.key, userId: userId, identifier: identifier, createdAt: Date(timeIntervalSince1970: createdAtRaw), cardId: cardId, otherUserDisplayName: otherUserDisplayName)
    }
    
    /// For conversion of a Transaction to Firebase dictionary representation for storage in database.
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "identifier" : identifier,
            "createdAt" : createdAt.timeIntervalSince1970,
            "userId": userId,
            "cardId": cardId,
            "otherUserDisplayName": otherUserDisplayName
        ]
    }
    
}
