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
    
    var members: [String]
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, email: String, name: String, members: [String] = []) {
        self.name = name
        
        self.members = members
        
        super.init(ref: ref, key: key, uid: uid, type: UserType.organization, email: email)
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let uid = value["uid"] as? String,
            let email = value["email"] as? String,
            let name = value["organizationName"] as? String,
            let members = value["members"] as? [String] else {
                return nil
        }
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, email: email, name: name, members: members)
    }
    
    override func toAnyObject() -> Any {
        var ret = super.toAnyObject() as! [String: Any]
        ret["organizationName"] = name
        ret["members"] = members
        return ret
    }
    
}
