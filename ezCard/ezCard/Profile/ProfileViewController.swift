//
//  ProfileViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Firebase


class ProfileViewController: UITableViewController, CNContactViewControllerDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addProfileButtonAndSearchBarToNavigationBar()
        navigationItem.leftBarButtonItem = nil // remove the profile button since we're already at the profile screen
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:))),
                                              UIBarButtonItem(image: #imageLiteral(resourceName: "gear"), style: .plain, target: self, action: #selector(settingsTapped(_:)))]
    }
    
    @objc func shareTapped(_ sender: Any?) {
        let qrCodeViewController = QRCodeViewController()
        //qrCodeViewController.card =  // TODO: pass the card we're sharing to the view controller
        navigationController?.pushViewController(qrCodeViewController, animated: true)
    }
    
    @objc func settingsTapped(_ sender: Any?) {
        // TODO: present CNContactViewController
        
        let newContact = CNMutableContact()
        let cnContactVC = CNContactViewController(forNewContact: newContact)
        cnContactVC.delegate = self
        navigationController?.pushViewController(cnContactVC, animated: true)
        
        
        
        
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        
        
        if contact != nil
        {
            
            let uuid = UUID().uuidString
            let data = try! CNContactVCardSerialization.data(with: [contact!])
            
        
            let storageRef = Storage.storage().reference()
            var location = "contacts/" + uuid
            let vcapRef = storageRef.child(location)
            
            let uploadTask = vcapRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    print("error has occured uploading vcap file")
                    return
                }
            }
        }
        
        viewController.dismiss(animated: true, completion: nil)
            
        
    }
    
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        print("in should perform default action for property")
        return true
    }
    
    @objc func addTapped(_ sender: Any?) {
        let cardViewController = CardViewController(style: .grouped)
        present(UINavigationController(rootViewController: cardViewController), animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

