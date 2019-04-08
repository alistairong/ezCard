//
//  User.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/26/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension Notification.Name {
    static let currentUserWillChange = Notification.Name("currentUserWillChange")
    static let currentUserDidChange = Notification.Name("currentUserDidChange")
}

enum UserType: String, CaseIterable {
    case individual
    case organization
    case unknown
    
    static let allQuantifiableCases: [UserType] = [.individual, .organization]
}

class User {
    
    static var current: User? {
        willSet {
            NotificationCenter.default.post(name: .currentUserWillChange, object: nil)
        }
        didSet {
            NotificationCenter.default.post(name: .currentUserDidChange, object: nil)
        }
    }
    
    let ref: DatabaseReference?
    let key: String
    
    let type: UserType
    
    let uid: String
    
    let email: String
    
    var displayName: String {
        return email
    }
    
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
    
    static func fetchUser(with uid: String, completion: ((User?) -> Void)?) {
        let usersRef = Database.database().reference(withPath: "users")
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let baseUser = User(snapshot: snapshot) else {
                completion?(nil)
                return
            }
            
            switch baseUser.type {
            case .individual:
                let user = IndividualUser(snapshot: snapshot)
                completion?(user)
            case .organization:
                let user = OrganizationUser(snapshot: snapshot)
                completion?(user)
            case .unknown:
                completion?(baseUser)
            }
        })
    }
    
    func dictionaryRepresentation() -> [String: Any] {
        return [
            "type": type.rawValue,
            "email": email,
            "uid": uid
        ]
    }
    
}
