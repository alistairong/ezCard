//
//  User.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class User {
    
    let ref: DatabaseReference?
    let key: String
    
    let uid: String
    
    let firstName: String
    let lastName: String
    
    let email: String

    var cardIds: [String]
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, firstName: String, lastName: String, email: String, cardIds: [String] = []) {
        self.ref = ref
        self.key = key
        
        self.uid = uid
        
        self.firstName = firstName
        self.lastName = lastName
        
        self.email = email
        
        self.cardIds = cardIds
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let firstName = value["firstName"] as? String,
            let lastName = value["lastName"] as? String,
            let email = value["email"] as? String,
            let uid = value["uid"] as? String,
            let cardIds = value["cardIds"] as? [String] else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, firstName: firstName, lastName: lastName, email: email, cardIds: cardIds)
    }
    
    func toAnyObject() -> Any {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "uid": uid,
            "cardIds": cardIds
        ]
    }
    
}
