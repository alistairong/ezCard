//
//  OrganizationUser.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

class OrganizationUser: User {
    
    let name: String
    
    var members: [String]?
    var cardIds: [String]?
    var transactionIds: [String]?
    var contactIds: [String]?
    
    override var displayName: String {
        return name
    }
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, email: String, name: String, members: [String]? = [], cardIds: [String]? = [], transactionIds: [String]? = [], contactIds: [String]? = []) {
        self.name = name
        
        self.members = members
        self.cardIds = cardIds
        self.transactionIds = transactionIds
        self.contactIds = contactIds
        
        super.init(ref: ref, key: key, uid: uid, type: UserType.organization, email: email)
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let uid = value["uid"] as? String,
            let email = value["email"] as? String,
            let name = value["organizationName"] as? String
        else {
                return nil
        }
        
        let members = value["members"] as? [String]
        let cardIds = value["cardIds"] as? [String]
        let transactionIds = value["transactionIds"] as? [String]
        let contactIds = value["contactIds"] as? [String]
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, email: email, name: name, members: members, cardIds: cardIds, transactionIds: transactionIds, contactIds: contactIds)
    }
    
    override func dictionaryRepresentation() -> [String: Any] {
        var ret = super.dictionaryRepresentation()
        ret["organizationName"] = name
        ret["members"] = members ?? []
        ret["cardIds"] = cardIds ?? []
        ret["transactionIds"] = transactionIds ?? []
        ret["contactIds"] = contactIds ?? []
        return ret
    }
    
}
