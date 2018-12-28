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
    }
    
    deinit {
        contactProfile = nil 
    }
    
    //return number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.photo.rawValue,Section.dob.rawValue: return 1
            case Section.name.rawValue: return 0
            case Section.phone.rawValue: return contactProfile?.phone?.count ?? 0
            case Section.email.rawValue: return contactProfile?.email?.count ?? 0
            case Section.address.rawValue: return contactProfile?.address?.count ?? 0
            default: return 0
        }
    }
    //return number of sections in table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.total.rawValue
    }
    
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
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case Section.photo.rawValue: return 200
            default: return 40
        }
    }
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


