//
//  LabelSelectionViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 4/15/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit

enum DataLabel: String, CaseIterable {
    case personal
    case business
    
    case facebook
    case twitter
    case instagram
    case snapchat
    case linkedIn
    
    static let defaultLabels: [DataLabel] = [.personal, .business]
    static let socialLabels: [DataLabel] = [.facebook, .twitter, .instagram, .snapchat, .linkedIn]
    
    static let `default`: DataLabel = .personal
    static let defaultSocial: DataLabel = .twitter
}

protocol LabelSelectionViewControllerDelegate: class {
    func labelSelectionViewController(_ labelSelectionViewController: LabelSelectionViewController, didFinishWithLabel label: String, for field: String?, at row: Int?)
}

class LabelSelectionViewController: UITableViewController {

    private struct Constants {
        static let reuseIdentifier = "basic"
    }
    
    let userDefaults = UserDefaults.standard
    
    weak var delegate: LabelSelectionViewControllerDelegate?
    
    var labelsToShow = DataLabel.allCases
    
    var currentLabel: String?
    
    var field: String?
    var row: Int?
    
    var customLabels: [String] {
        get {
            return userDefaults.array(forKey: GlobalConstants.customLabelsUserDefaultsKey) as? [String] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: GlobalConstants.customLabelsUserDefaultsKey)
            userDefaults.synchronize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Label"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "x"), style: .plain, target: self, action: #selector(cancelTapped(_:)))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
    }
    
    @objc func cancelTapped(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // TODO: set to 2 after implementing ability to add custom labels
        return 1 // one for defaults, one for custom
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0) ? labelsToShow.count : (customLabels.count + 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)

        var cellText: String?
        if indexPath.section == 0 {
            cellText = labelsToShow[indexPath.row].rawValue
        } else if indexPath.section == 1 && indexPath.row == 0 {
            cellText = "Add Custom Label"
        } else if indexPath.section == 1 {
            cellText = customLabels[indexPath.row]
        }
        
        cell.accessoryType = (cellText == currentLabel && !(indexPath.section == 1 && indexPath.row == 0)) ? .checkmark : .none
        
        cell.textLabel?.text = cellText

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dataLabel: String?
        if indexPath.section == 0 {
            dataLabel = labelsToShow[indexPath.row].rawValue
        } else if indexPath.section == 1 && indexPath.row == 0 {
            // TODO: add custom label
        } else if indexPath.section == 1 {
            dataLabel = customLabels[indexPath.row]
        }
        
        if let dataLabel = dataLabel {
            delegate?.labelSelectionViewController(self, didFinishWithLabel: dataLabel, for: field, at: row)
            dismiss(animated: true, completion: nil)
        }
    }

}
