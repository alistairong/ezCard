//
//  ContactsUtility.swift
//  ezCard
//
//  Created by Alistair Ong on 3/25/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import ContactsUI
import Firebase

class ContactsUtility {
    
    static func getContact() -> CNContact? {
        let vCardRemoteRef = Storage.storage().reference()
            .child("users").child("\(Auth.auth().currentUser!.uid).vcard")
        
        var contact: CNContact?
        
        vCardRemoteRef.getData(maxSize: Int64.max) { (data, error) in
            if let error = error {
                print("Error fetching vCard data:", error)
            }
            
            do {
                contact = try CNContactVCardSerialization.contacts(with: data!).first
            } catch let e {
                print("Error while deserializing vCard data:", e)
            }
        }
        
        return contact
    }
    
}


