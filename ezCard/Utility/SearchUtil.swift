//
//  SearchUtil.swift
//  ezCard
//
//  Created by Alistair Ong on 4/19/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import Foundation
import UIKit

class SearchUtil {
    
    static func setUpSearchBar(viewController: UIViewController, searchResultsUpdater: UISearchResultsUpdating,
                               searchController: UISearchController, placeholder: String) {
        searchController.searchResultsUpdater = searchResultsUpdater
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = placeholder
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true
        viewController.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    static func searchBarIsEmpty(searchController: UISearchController) -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    static func isFiltering(searchController: UISearchController) -> Bool {
        return searchController.isActive && !searchBarIsEmpty(searchController: searchController)
    }
    
}
