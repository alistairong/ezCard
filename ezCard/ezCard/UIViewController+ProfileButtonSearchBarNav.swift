//
//  UIViewController+NavigationBarConfig.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let profileButtonViewPadding = CGFloat(6.0)
}

extension UIViewController {
    
    func addProfileButtonAndSearchBarToNavigationBar() {
        navigationItem.title = "" // remove back button text
        
        let searchBar = UISearchBar(frame: CGRect.zero)
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        navigationItem.titleView = searchBar

        let profileButtonView = ProfileButtonView()
        profileButtonView.tappedCallback = { [weak self] in
            let profileViewController = ProfileViewController(style: .grouped)
            profileViewController.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        let profileButtonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: profileButtonView.frame.width + Constants.profileButtonViewPadding, height: profileButtonView.frame.height)) // add padding because navigation bar doesn't automatically center the bar button item between the edge of the screen and the search bar
        profileButtonContainerView.addSubview(profileButtonView)
        let profileBarButton = UIBarButtonItem(customView: profileButtonContainerView)
        navigationItem.leftBarButtonItem = profileBarButton
    }
    
}
