//
//  profileViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/21/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import CoreData
import CoreImage


struct CodableContact: Codable{
    let firstName: String
    let lastName: String?
    let dob: Date?
    let phone: String?
    let email: String?
    let address: String?
}

enum Section: Int{
    case photo = 0, name, dob, phone, email, address, QRCode,total
}


class ProfileViewController: UITableViewController {
    var contactProfile: Contact?
    var contactPhones = [String]()
    var contactEmails = [String]()
    var contactAddresses = [String]()
    
    var currentProfilePictureView: UIImageView?
    
    var currentTextField: UITextField?
    var currentText: String?
    var datePickerValue: Date?
    var coreDataManager: CoreDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.title = contactProfile?.fullName
        navigationItem.rightBarButtonItem = editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
        contactPhones = ((contactProfile?.phones?.map { ($0 as! Phone).number! })?.sorted())!
        contactEmails = ((contactProfile?.emails?.map{ ($0 as! Email).address! })?.sorted())!
        contactAddresses = ((contactProfile?.addresses?.map { ($0 as! Address).street! })?.sorted())!
        //force tableview to call heightForRowAt to calculate height of each cell manually.
        //Otherwise, the tableview 'jumps' every time we try to insert or delete cell rows.
        tableView.estimatedRowHeight = 0
    }
    
    deinit {
        contactProfile = nil 
    }
    

    //insert "add phone/email/address" cell when editing, remove when done editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
        if editing {
            currentProfilePictureView?.isUserInteractionEnabled = true
            contactAddresses.insert("add new address", at: 0)
            contactEmails.insert("add new email", at: 0)
            contactPhones.insert("add new phone", at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .left)
        } else {
            currentProfilePictureView?.isUserInteractionEnabled = false
            contactAddresses.removeFirst()
            contactEmails.removeFirst()
            contactPhones.removeFirst()
            self.tableView.deleteRows(at: [IndexPath(row: 0, section: Section.phone.rawValue),IndexPath(row: 0, section: Section.email.rawValue),IndexPath(row: 0, section: Section.address.rawValue)], with: .right)
        }
    }
    
    //return number of rows in a section. Very important to maintain data source's integrity!
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
            case Section.photo.rawValue,Section.dob.rawValue: return 1
            case Section.name.rawValue: return 2
            case Section.phone.rawValue: return (contactPhones.count)
            case Section.email.rawValue: return (contactEmails.count)
            case Section.address.rawValue: return (contactAddresses.count)
            case Section.QRCode.rawValue: return 1
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
            case Section.dob.rawValue: return "Date of Birth"
            case Section.phone.rawValue: return "Phone"
            case Section.email.rawValue: return "Email"
            case Section.address.rawValue: return "Address"
            case Section.QRCode.rawValue: return "QR Code"
            default: return nil
        }
    }
    

    
    //define the edit action for a cell 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let coreDataManager = coreDataManager, let id = contactProfile?.uniqueID{
                switch indexPath.section{
                
                case Section.phone.rawValue:
                    coreDataManager.delete(value: contactPhones[indexPath.row], from: id, with: DataField.Phone)
                    
                    contactPhones.remove(at: indexPath.row)

                case Section.email.rawValue:
                    coreDataManager.delete(value: contactEmails[indexPath.row], from: id, with: DataField.Email)
                    
                    contactEmails.remove(at: indexPath.row)

                case Section.address.rawValue:
                    coreDataManager.delete(value: contactAddresses[indexPath.row], from: id, with: DataField.Address)
                    
                    contactAddresses.remove(at: indexPath.row)

                default: break
                }
            tableView.deleteRows(at: [indexPath], with: .bottom)
            }
        }
    }
    
    //define which rows are editable
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case Section.photo.rawValue:
            return indexPath.row == 0 ? true : false
        case Section.name.rawValue: return true
        case Section.dob.rawValue: return true
        case Section.phone.rawValue,Section.email.rawValue,Section.address.rawValue:
            return indexPath.row == 0 && tableView.isEditing ? false : true
        default: return false
        }
    }
    
    //define editing style (+/-) for any cell when edit mode is active
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return indexPath.row > 0 && [Section.phone.rawValue, Section.email.rawValue, Section.address.rawValue].contains(indexPath.section) ? .delete : .none
    }
    
    
    
    //define actions when a row is selected, especially during editing mode
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == true {
             if indexPath.section >= Section.phone.rawValue && indexPath.row == 0 {
                var count = 0
                let emptyString = ""
                switch indexPath.section{

                case Section.phone.rawValue:
                    contactPhones.append(emptyString)
                    count = contactPhones.count - 1
                case Section.email.rawValue:
                    contactEmails.append(emptyString)
                    count = contactEmails.count - 1
                case Section.address.rawValue:
                    contactAddresses.append(emptyString)
                    count = contactAddresses.count - 1
                default:
                    
                    return
                }
                tableView.insertRows(at: [IndexPath(row: count, section: indexPath.section)], with: .bottom)
            }
        } else {
            if indexPath.section == Section.QRCode.rawValue{
                
                if let QRCodeDisplayVC = storyboard?.instantiateViewController(withIdentifier: "QRCodeDisplay") as? QRDisplayViewController, let validQRCode = generateQRCode(){
                    QRCodeDisplayVC.qrCode = validQRCode
                    navigationController?.pushViewController(QRCodeDisplayVC, animated: true)
                } else {
                    
                }
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
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(setProfilePicture))
            
            photoCell.imageView?.isUserInteractionEnabled = false
            photoCell.imageView?.addGestureRecognizer(imageTapRecognizer)
            //photoCell.imageView?.contentMode = .scaleAspectFill
            currentProfilePictureView = photoCell.imageView
            
            if let validPicture = contactProfile?.profilePicture{
                photoCell.imageView?.image = UIImage(data: validPicture)
            } else {
                photoCell.imageView?.image = UIImage(named: "neutralProfile.png")
            }
            return photoCell
        case Section.name.rawValue:
            let fullName = [contactProfile?.firstName,contactProfile?.lastName]
            return createSingleEntryCell(with: fullName[indexPath.row] ?? "", in: indexPath)
        case Section.dob.rawValue:
            
            if let validDate = contactProfile?.dob{
                let text = formatForView(date: validDate)
                return createSingleEntryCell(with: text, in: indexPath)
            } else {
                return createSingleEntryCell(with: "", in: indexPath)
            }
            
        case Section.phone.rawValue:
            let phone = contactPhones[indexPath.row]
            return createSingleEntryCell(with: phone, in: indexPath)
        case Section.email.rawValue:
            let email = contactEmails[indexPath.row]
            return createSingleEntryCell(with: email, in: indexPath)
        case Section.address.rawValue:
            let address = contactAddresses[indexPath.row]
            return createSingleEntryCell(with: address, in: indexPath)
        case Section.QRCode.rawValue:
            let qrDescription = "Share QR Code"
            return createSingleEntryCell(with: qrDescription, in: indexPath)
        default:
            return createSingleEntryCell(with: "radishes", in: indexPath)
        }
        
    }

    func createSingleEntryCell(with text: String, in indexPath: IndexPath)-> SingleEntryCell{
        let singleEntryCell = tableView.dequeueReusableCell(withIdentifier: "singleEntryCell", for: indexPath) as! SingleEntryCell
        switch indexPath.section{
        case Section.name.rawValue:
            singleEntryCell.textField.textAlignment = .center
        default: break
        }
        
        singleEntryCell.textField.text = text
        singleEntryCell.textField.autocorrectionType = .no
        singleEntryCell.textField.delegate = self
        return singleEntryCell
    }

}


extension ProfileViewController: UITextFieldDelegate{
    //when text field begins to edit, present the right keyboard for the field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //convert the textfield to an indexpath
        let textFieldOrigin = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexPathOfTextField = tableView.indexPathForRow(at: textFieldOrigin)
        currentTextField = textField
        currentText = textField.text
        
        switch indexPathOfTextField?.section{
        case Section.name.rawValue:
            textField.autocapitalizationType = .words
        case Section.dob.rawValue:
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(updateTextFieldWithDate(sender:)), for: .valueChanged)
            textField.inputView = datePicker
            textField.text = formatForView(date: datePicker.date)
        case Section.phone.rawValue:
            textField.keyboardType = .asciiCapableNumberPad
        case Section.email.rawValue:
            textField.keyboardType = .emailAddress
        default: break
        }
        
    }
    
    //update the d.o.b text field with the date picked by the datepicker
    @objc func updateTextFieldWithDate(sender: UIDatePicker){
        currentTextField?.text = formatForView(date: sender.date)
    }
    
    //given a Date object, return its string representation as MMM dd, yyyy
    func formatForView(date: Date) -> String{
        datePickerValue = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from:date)
    }
    
    //after the textfield returns with input, check that it's valid and update the value in core data
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
        let textFieldOrigin = textField.convert(textField.bounds.origin, to: self.tableView)
        let indexPathOfTextField = tableView.indexPathForRow(at: textFieldOrigin)
        if let indexPath = indexPathOfTextField, let newEntry = textField.text, let contact = contactProfile,let coreDataManager = coreDataManager {
            
            switch indexPathOfTextField?.section {
            case Section.name.rawValue:
                if indexPathOfTextField?.row == 0{
                    _ = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.FirstName, oldValue: contact.firstName, newValue: newEntry)
                    contactProfile?.firstName = newEntry
                } else {
                    _ = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.LastName, oldValue: contact.lastName, newValue: newEntry)
                    contactProfile?.lastName = newEntry
                }
            case Section.dob.rawValue:
                _ = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.Dob, oldValue: contact.dob, newValue: datePickerValue)
                contactProfile?.dob = datePickerValue
            case Section.phone.rawValue:
                if contactPhones.contains(newEntry){
                    presentAC(message: "Phone number already exists.")
                } else if !inputIsValid(input: newEntry, field: DataField.Phone){
                    presentAC(message: "Invalid Phone number.")
                } else {
                    let coreUpdated = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.Phone, oldValue: contactPhones[indexPath.row], newValue: newEntry)
                    if coreUpdated { contactPhones[indexPath.row] = newEntry }
                }
            case Section.email.rawValue:
                
                if contactEmails.contains(newEntry){
                    presentAC(message: "Email address already exists.")
                } else if !inputIsValid(input: newEntry, field: DataField.Email){
                    presentAC(message: "Invalid Email Address.")
                } else {
                    let coreUpdated = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.Email, oldValue: contactEmails[indexPath.row], newValue: newEntry)
                    if coreUpdated { contactEmails[indexPath.row] = newEntry }
                }
                
            case Section.address.rawValue:
                if contactAddresses.contains(newEntry){
                    presentAC(message: "Address already exists.")
                } else if !inputIsValid(input: newEntry, field: DataField.Address){
                    presentAC(message: "Invalid Address.")
                } else {
                    let coreUpdated = coreDataManager.updateCurrentContact(uniqueID: contact.uniqueID!, field: DataField.Address, oldValue: contactAddresses[indexPath.row], newValue: newEntry)
                    if coreUpdated { contactAddresses[indexPath.row] = newEntry }
                }
                
            default:
                break
            }
        }
    }
    
    func presentAC(message: String){
        let ac = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func inputIsValid(input: String, field: DataField) -> Bool {
        
        let validChars = (input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0)
        switch field{
        case .Phone:
            return  validChars && input.count <= 11 && input.range(of: "[^0-9]", options: .regularExpression) == nil ? true : false
        case .Email:
            //email validation regex courtesy of https://stackoverflow.com/questions/27998409/email-phone-validation-in-swift
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let range = input.range(of: emailRegEx, options: .regularExpression)
            return validChars && range != nil ? true : false
        default:
            return validChars
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//image picker delegate functions
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        let imageData = UIImage.pngData(image)()
        contactProfile?.profilePicture = imageData
        coreDataManager?.saveContext()
        tableView.reloadSections(IndexSet([Section.photo.rawValue]), with: .automatic)
    }
    
    @objc func setProfilePicture(){
        let alertVC = UIAlertController(title: nil, message: "Pick a profile picture", preferredStyle: .alert)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: takePhoto)
        let photoLibraryAction = UIAlertAction(title: "Photos Library", style: .default, handler: pickPhoto)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoLibraryAction)
        alertVC.addAction(cancelAction)
        
        //popover presentation is used on iPads to specify origin of alertVC popup.
        alertVC.popoverPresentationController?.sourceView = self.view
        alertVC.popoverPresentationController?.sourceRect = self.tableView.frame
        
        present(alertVC, animated: true)
    }
    
    func takePhoto(action: UIAlertAction){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    func pickPhoto(action: UIAlertAction){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc,animated: true)
    }
}


//generate a QR code for the current profile
extension ProfileViewController {
    
    func generateQRCode() -> UIImage? {
        let input = CodableContact(firstName: (contactProfile?.firstName)!, lastName: contactProfile?.lastName,dob: contactProfile?.dob, phone: contactPhones.first, email: contactEmails.first, address: contactAddresses.first)
        do {
            let data = try JSONEncoder().encode(input)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator"){
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                if let output = filter.outputImage?.transformed(by: transform){
                    return UIImage(ciImage: output)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
