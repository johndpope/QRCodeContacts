//
//  profileViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/21/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit

enum Section: Int{
    case photo = 0, name, dob, phone, email, address, total
}

class ProfileViewController: UITableViewController {
    var contactProfile: DelegateContact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 40
        self.title = contactProfile?.fullName
        navigationItem.rightBarButtonItem = editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    deinit {
        contactProfile = nil 
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
        if editing {
            contactProfile?.address?.append("add new address")
            contactProfile?.email?.append("add new email")
            contactProfile?.phone?.append("add new phone")
            
//            let phonePath = IndexPath(row: (contactProfile?.phone?.count ?? 0) - 1, section: Section.phone.rawValue)
//            let emailPath = IndexPath(row: (contactProfile?.email?.count ?? 0) - 1, section: Section.email.rawValue)
//            let addressPath = IndexPath(row: (contactProfile?.address?.count ?? 0) - 1, section: Section.address.rawValue)
            
            self.tableView.insertRows(at: [IndexPath(row: 1, section: 3),IndexPath(row: 1, section: 4),IndexPath(row: 1, section: 5)], with: .left)
            
        } else {
            contactProfile?.address?.removeLast()
            contactProfile?.email?.removeLast()
            contactProfile?.phone?.removeLast()
            self.tableView.deleteRows(at: [IndexPath(row: 1, section: 3),IndexPath(row: 1, section: 4),IndexPath(row: 1, section: 5)], with: .right)
        }
    }
    
    //return number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.photo.rawValue,Section.dob.rawValue: return 1
            case Section.name.rawValue: return 0
            case Section.phone.rawValue: return (contactProfile?.phone?.count ?? 0)
            case Section.email.rawValue: return (contactProfile?.email?.count ?? 0)
            case Section.address.rawValue: return (contactProfile?.address?.count ?? 0)
            default: return 0
        }
    }
    //define number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.total.rawValue
    }
    
    //define title for each section in table view
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            //case 0: return "Profile Picture"
            //case Section.name.rawValue: return "Name"
            case Section.dob.rawValue: return "Date of Birth"
            case Section.phone.rawValue: return "Phone"
            case Section.email.rawValue: return "Email"
            case Section.address.rawValue: return "Address"
            default: return nil
        }
    }
    
    //define estimated height for any row (useful for optimizing scroll rendering)
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case Section.photo.rawValue: return 200
            default: return 40
        }
    }
    
    //define the edit action for a cell 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete row from data source and from table view
            print("deleting row...")
        } else if editingStyle == .insert {
            print("inserting row...")
        }
    }
    
    //define which rows are editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
            case Section.photo.rawValue: return false
            default: return true
        }
    }
    
    //define editing style (+/-) for any cell when edit mode is active
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .delete
        } else { return .none }
    }
    
    //define actions when a row is selected, especially during editing mode
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            print("editing ",indexPath.section, indexPath.row)
        }
    }
    
    
    //photo section should have a calculated height, the other sections should have automatic height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.photo.rawValue && indexPath.row == 0 {
            //print("setting image cell width: ",self.view.frame.width / 1.5)
            return self.view.frame.width / 1.5
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    
    //fill a cell with data, and return it
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case Section.photo.rawValue:
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            photoCell.imageView?.image = UIImage(named: "neutralProfile.png")
            
            return photoCell
        case Section.name.rawValue:
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            singleEntryCell.textLabel?.text = "\(contactProfile?.firstName ?? "") \(contactProfile?.lastName ?? "")"
            return singleEntryCell
        case Section.dob.rawValue:
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            singleEntryCell.textLabel?.text = contactProfile?.dob?.description
            return singleEntryCell
        case Section.phone.rawValue:
            
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            let phoneNumbers = Array((contactProfile?.phone)!)
            singleEntryCell.textLabel?.text = phoneNumbers[indexPath.row].description
            return singleEntryCell
            
        case Section.email.rawValue:
            
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            let emails = Array((contactProfile?.email)!)
            singleEntryCell.textLabel?.text = emails[indexPath.row]
            return singleEntryCell
            
        case Section.address.rawValue:
            
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            let addresses = Array((contactProfile?.address)!)
            singleEntryCell.textLabel?.text = addresses[indexPath.row]
            return singleEntryCell
            
            
        default:
            let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
            singleEntryCell.textLabel?.text = "radishes"
            return singleEntryCell
        }
    }
    
    
    
    
}


