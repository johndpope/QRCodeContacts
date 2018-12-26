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
    var userProfile: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    //return number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.photo.rawValue, Section.name.rawValue, Section.dob.rawValue: return 1
            case Section.phone.rawValue: return userProfile?.phone?.count ?? 0
            case Section.email.rawValue: return userProfile?.email.count ?? 0
            case Section.address.rawValue: return userProfile?.address.count ?? 0
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
            case Section.name.rawValue: return "Name"
            case Section.dob.rawValue: return "Date of Birth"
            case Section.phone.rawValue: return "Phone"
            case Section.email.rawValue: return "Email"
            case Section.address.rawValue: return "Address"
            default: return nil
        }
    }
    
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == Section.photo.rawValue && indexPath.row == 0 {
//            return self.view.frame.width / 1.5
//        } else {
//            return UITableView.automaticDimension
//        }
//        return UITableView.automaticDimension
//        switch indexPath.section{
//            case Section.photo.rawValue : return self.view.frame.width / 1.5
//        default: return UITableView.automaticDimension
//        }

//    }
    
    //fill a cell with data, and return it
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
        
        switch indexPath.section {
        case Section.photo.rawValue:
            let photoCell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
            photoCell.photoView.image = UIImage(named: "neutralProfile.png")
            //clip photo with circular mask
            let radiusOfCircularMask = photoCell.photoView.frame.width / 2.0
            photoCell.photoView.layer.cornerRadius = radiusOfCircularMask
            photoCell.photoView.layer.masksToBounds = true
            
            return photoCell
        case Section.name.rawValue:
            singleEntryCell.textLabel?.text = "\(userProfile?.firstName ?? "") \(userProfile?.lastName ?? "")"
            return singleEntryCell
        case Section.dob.rawValue:
            singleEntryCell.textLabel?.text = userProfile?.dateOfBirth
            return singleEntryCell
        case Section.phone.rawValue:
            singleEntryCell.textLabel?.text = userProfile?.phone?[indexPath.row]
            return singleEntryCell
        case Section.email.rawValue:
            singleEntryCell.textLabel?.text = userProfile?.email[indexPath.row]
            return singleEntryCell
        case Section.address.rawValue:
            singleEntryCell.textLabel?.text = userProfile?.address[indexPath.row]
            return singleEntryCell
        default:
            singleEntryCell.textLabel?.text = "radishes"
            return singleEntryCell
        }
    }
    
    
    
    
}


