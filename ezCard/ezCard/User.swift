//
//  User.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum UserType: String, CaseIterable {
    case individual
    case organization
    case unknown
    
    static let allQuantifiableCases: [UserType] = [.individual, .organization]
}

class User {
    
    let ref: DatabaseReference?
    let key: String
    
    let type: UserType
    
    let uid: String
    
    let email: String
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, type: UserType, email: String) {
        self.ref = ref
        self.key = key
        
        self.type = type
        
        self.uid = uid
        
        self.email = email
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let type = value["type"] as? String,
            let email = value["email"] as? String,
            let uid = value["uid"] as? String else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, type: UserType(rawValue: type) ?? .unknown, email: email)
    }
    
    func toAnyObject() -> Any {
        return [
            "type": type.rawValue,
            "email": email,
            "uid": uid
        ]
    }
    
}
