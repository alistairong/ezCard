//
//  OrganizationMemberSelectionViewController.swift
//  ezCard
//
//  Created by Rajat Menhdiratta on 4/2/19.
//  Copyright © 2019 Rajat Menhdiratta. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol OrganizationMemberSelectionViewControllerDelegate: class {
    func organizationMemberSelectionViewController(_ organizationCardViewController: OrganizationMemberSelectionViewController, didFinishWith uid: String?)
}

class OrganizationMemberSelectionViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    var searchResult = [String]()
    var searchUID = [String]()
    var uidList = [String]()
    var initialEmailList = [String]()
    
    let usersRef = Database.database().reference(withPath: "users")
    
    var searchController: UISearchController!
    
    weak var delegate: OrganizationMemberSelectionViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Member"
        
        searchResult.removeAll()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x.png"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.definesPresentationContext = true
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() { return }
            
            for child in snapshot.children
            {
                let temp = User(snapshot: child as! DataSnapshot)
                let currEmail = temp?.email
                let uid = temp?.uid
                
                self.initialEmailList.append(currEmail!)
                self.uidList.append(uid!)
                
            }
        })
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        
        delegate?.organizationMemberSelectionViewController(self, didFinishWith: searchUID[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.textLabel?.text = searchResult[indexPath.row]
        return cell
    }
    
    // MARK: - Search
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData()
        var found = false
        var index = 0
        for curr in self.initialEmailList
        {
            if curr.lowercased().contains(searchText.lowercased())
            {
                print("in text checking")
                self.searchResult.append(curr)
                self.searchUID.append(uidList[index])
                found = true
                self.tableView.reloadData()
            }
            if !found
            {
                self.searchResult.removeAll()
                self.searchUID.removeAll()
                found = false
            }
            self.tableView.reloadData()
            index = index + 1
            
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResult.removeAll()
        tableView.reloadData()
    }
    
}
