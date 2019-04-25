//
//  SearchUtil.swift
//  ezCard
//
//  Created by Alistair Ong on 4/19/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

/// SearchUtil is a class of functions to help in the search bar set up and tool.
class SearchUtil {
    
    static func setUpSearchBar(viewController: UIViewController, searchResultsUpdater: UISearchResultsUpdating,
                               searchController: UISearchController, placeholder: String) {
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = placeholder
        
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    static func searchBarIsEmpty(searchController: UISearchController) -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /// Returns whether the search bar is both active and is not empty.
    static func isFiltering(searchController: UISearchController) -> Bool {
        return searchController.isActive && !searchBarIsEmpty(searchController: searchController)
    }
    
    /// Returns whether there is such a name associated with the card.
    static func containsCardName(card: Card, name: String) -> Bool {
        return card.name!.lowercased().contains(name.lowercased())
    }
    
    /// Returns whether there is such a value stored in the card
    static func containsCardValue(card: Card, fieldValue: String) -> Bool {
        for data in card.fields {
            let value = data["data"]
            return value?.lowercased().contains(fieldValue.lowercased()) ?? false
        }

        return false
    }
    
    /// Returns whether user associated with the contact in mind contains the given name.
    ///
    /// - Parameters:
    ///   - user: The user associated with the contact in query.
    ///   - name: The given name to search within user.
    /// - Returns: A boolean of whether name is found in user.
    static func containsContactName(user: User, name: String) -> Bool {
        return user.displayName.lowercased().contains(name.lowercased())
    }
    
//    /// Returns whether contact contains given value.
//    static func containsContactValue(contact: Contact, fieldValue: String, completion: @escaping (Bool) -> Void) {
//        let cardsFetchGroup = DispatchGroup()
//
//        var allSharedFieldValues: [String] = []
//
//        let cardsRef = Database.database().reference(withPath: "cards")
//        let cardRefs = contact.sharedCardIds.keys.map { (cardId) -> DatabaseReference in
//            return cardsRef.child(cardId)
//        }
//
//        for cardRef in cardRefs {
//            // lock the group
//            cardsFetchGroup.enter()
//
//            cardRef.observeSingleEvent(of: .value) { (snapshot) in
//                if let card = Card(snapshot: snapshot) {
//                    allSharedFieldValues.append(contentsOf: card.fields.map { $0.value })
//                }
//
//                // after the async work has been completed, unlock the group
//                cardsFetchGroup.leave()
//            }
//        }
//
//        // this block will be called after the final cardsFetchGroup.leave() of the looped async functions complete
//        cardsFetchGroup.notify(queue: .main) {
//            let matches = allSharedFieldValues.contains(where: { $0 == fieldValue.lowercased() })
//            completion(matches)
//        }
//    }
    
}
