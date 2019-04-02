//
//  IndividualUser.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

class IndividualUser: User {
    
    let firstName: String
    let lastName: String
    
    var cardIds: [String: Bool]?
    var transactionIds: [String: Bool]?
    var contactIds: [String: Bool]?
    
    override var displayName: String {
        return firstName + " " + lastName
    }
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, email: String, firstName: String, lastName: String, cardIds: [String: Bool]? = [:], transactionIds: [String: Bool]? = [:], contactIds: [String: Bool]? = [:]) {
        self.firstName = firstName
        self.lastName = lastName
        
        self.cardIds = cardIds
        self.transactionIds = transactionIds
        self.contactIds = contactIds
        
        super.init(ref: ref, key: key, uid: uid, type: UserType.individual, email: email)
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let uid = value["uid"] as? String,
            let email = value["email"] as? String,
            let firstName = value["firstName"] as? String,
            let lastName = value["lastName"] as? String
        else {
                return nil
        }
        
        let cardIds = value["cards"] as? [String: Bool]
        let transactionIds = value["transactions"] as? [String: Bool]
        let contactIds = value["contacts"] as? [String: Bool]
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, email: email, firstName: firstName, lastName: lastName, cardIds: cardIds, transactionIds: transactionIds, contactIds: contactIds)
    }
    
    override func dictionaryRepresentation() -> [String: Any] {
        var ret = super.dictionaryRepresentation()
        ret["firstName"] = firstName
        ret["lastName"] = lastName
        ret["cards"] = cardIds ?? []
        ret["transactions"] = transactionIds ?? []
        ret["contacts"] = contactIds ?? []
        return ret
    }
    
}
