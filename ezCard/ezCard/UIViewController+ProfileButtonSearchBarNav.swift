//
//  UIViewController+NavigationBarConfig.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import FirebaseAuth

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
        profileButtonView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonView.tappedCallback = { [weak self] in
            let profileViewController = ProfileViewController(style: .grouped)
            profileViewController.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        let profileButtonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: profileButtonView.bounds.width + Constants.profileButtonViewPadding, height: profileButtonView.frame.height)) // add padding because navigation bar doesn't automatically center the bar button item between the edge of the screen and the search bar
        profileButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        profileButtonContainerView.addSubview(profileButtonView)
        
        profileButtonContainerView.widthAnchor.constraint(equalToConstant: ProfileButtonView.defaultSize + Constants.profileButtonViewPadding).isActive = true
        profileButtonContainerView.heightAnchor.constraint(equalToConstant: ProfileButtonView.defaultSize + Constants.profileButtonViewPadding).isActive = true
        
        profileButtonView.widthAnchor.constraint(equalToConstant: ProfileButtonView.defaultSize).isActive = true
        profileButtonView.heightAnchor.constraint(equalToConstant: ProfileButtonView.defaultSize).isActive = true
        
        let profileBarButton = UIBarButtonItem(customView: profileButtonContainerView)
        navigationItem.leftBarButtonItem = profileBarButton
        
        let logoutButton = UIBarButtonItem(title: "Sign Out".uppercased(), style: .done, target: self, action: #selector(signOut))
        logoutButton.tintColor = .red
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            
            let loginViewController = LoginViewController()
            present(UINavigationController(rootViewController: loginViewController), animated: false, completion: nil)
        } catch {
            let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
}
