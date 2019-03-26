//
//  ScanConfirmationViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

class ScanConfirmationViewController: UIViewController {
    @IBOutlet weak var qrLabel: UILabel!
    var qrMetadata:String = String()
    var delegate:ScanViewController?
    @IBOutlet weak var qrTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrLabel.text = qrMetadata
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    /*
    /// callback for ... button on ID card
    @objc func showContact(_ contact: Contact) {
        let contactViewController = ContactViewController(style: .grouped)
        //contactViewController.contact =  // TODO: set contact on ContactViewController
        navigationController?.pushViewController(contactViewController, animated: true)
    }
    */
    @IBAction func declineTransactionTapped(_ sender: Any) {
        delegate!.startCamera()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func acceptTransactionTapped(_ sender: Any) {
        delegate!.startCamera()
        dismiss(animated: true, completion: nil)
    }
    
    func acceptTransactionTapped() {
        // TODO: accept the transaction (add contact to current user's contact list)
        
        dismiss(animated: true, completion: nil)
    }
    
    func declineTransactionTapped() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}

protocol QRScanner {
    func startCamera()
}
