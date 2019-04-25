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

/// User class stores all information that is input by the current logged in User from the settings page.
class User {
    
    static var current: User? {
        willSet {
            NotificationCenter.default.post(name: .currentUserWillChange, object: nil)
        }
        didSet {
            NotificationCenter.default.post(name: .currentUserDidChange, object: nil)
        }
    }
    
    var displayName: String {
        switch type {
        case .individual:
            return firstName! + " " + lastName!
        case .organization:
            return organizationName!
        case .unknown:
            return email
        }
    }
    
    let ref: DatabaseReference?
    let key: String
    
    let type: UserType
    
    let uid: String
    
    let email: String
    
    var data: [[String : String]] // [["data": "555-555-5555", "label": "personal", "field": "phone"], ["data": "222-222-2222", "label": "business", "field": "phone"]]
    
    var transactionIds: [String: Bool]?
    
    // MARK: - Individual
    
    var firstName: String?
    var lastName: String?
    
    var company: String?
    var jobTitle: String?
    
    var cardIds: [String: Bool]?
    var contactIds: [String: Bool]?
    
    // MARK: - Organization
    
    var organizationName: String?
    
    var members: [String]?
    
    // MARK: - Init
    
    init(ref: DatabaseReference? = nil, key: String = "", uid: String, type: UserType, email: String, data: [[String : String]] = [], transactionIds: [String: Bool]? = nil, firstName: String? = nil, lastName: String? = nil, company: String? = nil, jobTitle: String? = nil, cardIds: [String: Bool]? = nil, contactIds: [String: Bool]? = nil, organizationName: String? = nil, members: [String]? = nil) {
        self.ref = ref
        self.key = key
        
        self.type = type
        
        self.uid = uid
        
        self.email = email
        
        self.data = data
        
        self.transactionIds = transactionIds
        
        // individual
        
        self.firstName = firstName
        self.lastName = lastName
        
        self.company = company
        self.jobTitle = jobTitle
        
        self.cardIds = cardIds
        self.contactIds = contactIds
        
        // organization
        
        self.organizationName = organizationName
        
        self.members = members
    }
    
    convenience init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let type = value["type"] as? String,
            let email = value["email"] as? String,
            let uid = value["uid"] as? String else {
                return nil
        }
        
        let data = value["data"] as? [[String : String]]
        
        let transactionIds = value["transactions"] as? [String: Bool]
        
        // individual
        
        let firstName = value["firstName"] as? String
        let lastName = value["lastName"] as? String
        
        let company = value["company"] as? String
        let jobTitle = value["jobTitle"] as? String
        
        let cardIds = value["cards"] as? [String: Bool]
        let contactIds = value["contacts"] as? [String: Bool]
        
        // organization
        
        let organizationName = value["organizationName"] as? String
        
        let members = value["members"] as? [String]
        
        self.init(ref: snapshot.ref, key: snapshot.key, uid: uid, type: UserType(rawValue: type) ?? .unknown, email: email, data: data ?? [], transactionIds: transactionIds, firstName: firstName, lastName: lastName, company: company, jobTitle: jobTitle, cardIds: cardIds, contactIds: contactIds, organizationName: organizationName, members: members)
    }
    
    static func fetchUser(with uid: String, completion: ((User?) -> Void)?) {
        let usersRef = Database.database().reference(withPath: "users")
        usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                completion?(nil)
                return
            }
            
            completion?(user)
        })
    }
    
    /// For conversion of a User to Firebase dictionary representation for storage in database.
    func dictionaryRepresentation() -> [String: Any] {
        var dict: [String: Any] = [
            "type": type.rawValue,
            "email": email,
            "uid": uid,
        ]
        
        dict["data"] = data
        
        if let transactionIds = self.transactionIds {
            dict["transactions"] = transactionIds
        }
        
        // individual
        
        if let firstName = self.firstName {
            dict["firstName"] = firstName
        }
        
        if let lastName = self.lastName {
            dict["lastName"] = lastName
        }
        
        if let company = self.company {
            dict["company"] = company
        }
        
        if let jobTitle = self.jobTitle {
            dict["jobTitle"] = jobTitle
        }
        
        if let cardIds = self.cardIds {
            dict["cards"] = cardIds
        }
        
        if let contactIds = self.contactIds {
            dict["contacts"] = contactIds
        }
        
        // organization
        
        if let organizationName = self.organizationName {
            dict["organizationName"] = organizationName
        }
        
        if let members = self.members {
            dict["members"] = members
        }
        
        return dict
    }
    
}
