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
    var contactProfile: InterimContact!
    var delegate: NewContactDelegate!
    var currentTextField: UITextField?
    var datePickerValue: Date?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = contactProfile?.fullName
        navigationItem.rightBarButtonItem = editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    deinit {
        contactProfile = nil 
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        if self.isMovingFromParent{
//            delegate.updateCurrent(contact: contactProfile)
//            //print("moving out of profile view, should save delegate object")
//           
//        }
//    }
    
    
    //insert "add phone/email/address" cell when editing, remove when done editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
        if editing {
            contactProfile?.address.insert("add new address", at: 0)
            contactProfile?.email.insert("add new email", at: 0)
            contactProfile?.phone.insert("add new phone", at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .left)
            //tableView.reloadSections([3,4,5], with: .left)
            
            //tableView.reloadRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .left)
        } else {
            contactProfile?.address.removeFirst()
            contactProfile?.email.removeFirst()
            contactProfile?.phone.removeFirst()
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .right)
            //tableView.reloadSections([3,4,5], with: .right)
            //tableView.reloadRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .right)
        }
        //tableView.reloadRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .right)
        //tableView.reloadData()
        
        
        //UIView.transition(with: tableView,duration: 0.3,options: .transitionCurlUp,animations: {self.tableView.reloadData()})
        
    }
    
    //return number of rows in a section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Section.photo.rawValue,Section.dob.rawValue: return 1
            case Section.name.rawValue: return 0
            case Section.phone.rawValue: return (contactProfile?.phone.count ?? 0)
            case Section.email.rawValue: return (contactProfile?.email.count ?? 0)
            case Section.address.rawValue: return (contactProfile?.address.count ?? 0)
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
            let id = contactProfile.uniqueID
            
            switch indexPath.section{
            
            case Section.phone.rawValue:
                delegate.delete(value: contactProfile.phone[indexPath.row], from: id, with: DataField.Phone)
                print("deleting phone ",contactProfile.phone[indexPath.row])
                contactProfile.phone.remove(at: indexPath.row)
                
            case Section.email.rawValue:
                delegate.delete(value: contactProfile.email[indexPath.row], from: id, with: DataField.Email)
                print("deleting email ",contactProfile.email[indexPath.row])
                contactProfile.email.remove(at: indexPath.row)
                
            case Section.address.rawValue:
                delegate.delete(value: contactProfile.address[indexPath.row], from: id, with: DataField.Address)
                print("deleting address",contactProfile.address[indexPath.row])
                contactProfile.address.remove(at: indexPath.row)
                
            default: break
            }
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
    //define which rows are editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
            case Section.photo.rawValue: return false
        case Section.phone.rawValue,Section.email.rawValue,Section.address.rawValue:
            if indexPath.row == 0 && tableView.isEditing {
                return false
            } else {
                return true
            }
            default: return true
        }
    }
    
    //define editing style (+/-) for any cell when edit mode is active
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if indexPath.row > 0 && indexPath.section != Section.dob.rawValue {
            return .delete
        } else {
            return .none
        }
    }
    
    
    
    //define actions when a row is selected, especially during editing mode
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
            if indexPath.row == 0 && indexPath.section >= Section.phone.rawValue{
                
                var count = 0
                let id = contactProfile.uniqueID
                let emptyString = "&&&"
                switch indexPath.section{
                case Section.phone.rawValue:
                    
                    delegate.add(value: emptyString, from: id, with: DataField.Phone)
                    contactProfile.phone.append(emptyString)
                    count = contactProfile.phone.count - 1
                case Section.email.rawValue:
                    
                    delegate.add(value: emptyString, from: id, with: DataField.Email)
                    contactProfile.email.append(emptyString)
                    count = contactProfile.email.count - 1
                case Section.address.rawValue:
                    
                    delegate.add(value: emptyString, from: id, with: DataField.Address)
                    contactProfile.address.append(emptyString)
                    count = contactProfile.address.count - 1
                default: print("default action")
                }
                tableView.insertRows(at: [IndexPath(row: count, section: indexPath.section)], with: .bottom)
            }
        }
    }
    
    
    //photo section should have a calculated height, the other sections should have automatic height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == Section.photo.rawValue && indexPath.row == 0 {
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
            let text = "\(contactProfile?.firstName ?? "") \(contactProfile?.lastName ?? "")"
            return createSingleEntryCell(with: text, in: indexPath)
        case Section.dob.rawValue:
            let text = contactProfile?.dob?.description ?? ""
            return createSingleEntryCell(with: text, in: indexPath)
        case Section.phone.rawValue:
            let phone = contactProfile?.phone[indexPath.row]
            return createSingleEntryCell(with: phone!, in: indexPath)
        case Section.email.rawValue:
            let email = contactProfile?.email[indexPath.row]
            return createSingleEntryCell(with: email!, in: indexPath)
        case Section.address.rawValue:
            let address = contactProfile?.address[indexPath.row]
            return createSingleEntryCell(with: address!, in: indexPath)
        default:
            return createSingleEntryCell(with: "radishes", in: indexPath)
        }
    }

    func createSingleEntryCell(with text: String, in indexPath: IndexPath)-> SingleEntryCell{
        let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
        singleEntryCell.textField.text = text
        singleEntryCell.textField.delegate = self
        return singleEntryCell
    }

}


extension ProfileViewController: UITextFieldDelegate{

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //convert the textfield to an indexpath
        let textFieldOrigin = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexPathOfTextField = tableView.indexPathForRow(at: textFieldOrigin)
        if indexPathOfTextField?.section == Section.dob.rawValue {
            currentTextField = textField
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(updateTextFieldWithDate(sender:)), for: .valueChanged)
            textField.inputView = datePicker
            textField.text = formatForView(date: datePicker.date)
        }
    }
    
//    //update the d.o.b text field with the date picked by the datepicker
    @objc func updateTextFieldWithDate(sender: UIDatePicker){
        currentTextField?.text = formatForView(date: sender.date)
    }
    
    //given a Date object, return its string representation as MMM dd, yyyy
    func formatForView(date: Date) -> String{
        datePickerValue = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter.string(from:date)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
        let textFieldOrigin = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexPathOfTextField = tableView.indexPathForRow(at: textFieldOrigin)
        if let row = indexPathOfTextField?.row, let newEntry = textField.text{
           
            switch indexPathOfTextField?.section {
            case Section.dob.rawValue:
                //print("new dob: ",datePickerValue?.description)
                delegate.updateCurrentContact(uniqueID: contactProfile.uniqueID, field: DataField.Dob, oldValue: contactProfile?.dob, newValue: datePickerValue)
                contactProfile?.dob = datePickerValue
            case Section.phone.rawValue:
                delegate.updateCurrentContact(uniqueID: contactProfile.uniqueID, field: DataField.Phone, oldValue: contactProfile.phone[row], newValue: newEntry)
                contactProfile?.phone[row] = newEntry 
            case Section.email.rawValue:
                delegate.updateCurrentContact(uniqueID: contactProfile.uniqueID, field: DataField.Email, oldValue: contactProfile.email[row], newValue: newEntry)
                contactProfile?.email[row] = newEntry
            case Section.address.rawValue:
                delegate.updateCurrentContact(uniqueID: contactProfile.uniqueID, field: DataField.Address, oldValue: contactProfile.address[row], newValue: newEntry)
                contactProfile?.address[row] = newEntry
            default:
                break
            }
        }
        //print("received input", textField.text ?? "no input")
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

