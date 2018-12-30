//
//  NewContactViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/24/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit

protocol NewContactDelegate: AnyObject {
    func createNew(contact: DelegateContact)
}

struct DelegateContact: Hashable {
    var firstName: String?
    var lastName: String?
    var fullName: String {
        return self.firstName! + " " + (self.lastName ?? "")
    }
    var dob: Date?
    var phone: Array<String>?
    var email: Array<String>?
    var address: Array<String>?
    var uniqueID: String
    
    static func convertToDelegateContact(from contact: Contact) -> DelegateContact {
        let newDelegateContact = DelegateContact(firstName: contact.firstName,
            lastName: contact.lastName,
            dob: contact.dob,
            phone: [contact.phone ?? "no phone value"],
            email: [contact.email ?? "no email value"],
            address: [contact.address ?? "no address value"],
            uniqueID: contact.uniqueID!)
        return newDelegateContact
    }
}

class NewContactViewController: UIViewController{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    var currentTextField: UITextField?
    
    var textFields: [UITextField]?
    
    var delegate: NewContactDelegate?
    
    var newContact: DelegateContact?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegates()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDismissTapped))
        view.addGestureRecognizer(tapRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNewContactVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveContactTapped))
        self.title = "New Contact"
        
        //add notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil);
        
        newContact = DelegateContact(firstName: nil, lastName: nil, dob: nil, phone: nil, email: nil, address: nil, uniqueID: UUID.init().uuidString)
    }
    
    deinit{
        //remove notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        newContact = nil
        delegate = nil
    }
    
    //move the scrollview up when the keyboard blocks the current text field
    //https://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
    @objc func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 50, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var viewRect : CGRect = self.view.frame
        viewRect.size.height -= keyboardSize!.height
        if let activeField = self.currentTextField {
            if (!viewRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.view.endEditing(true)
    }
    
    @objc func dismissNewContactVC(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardDismissTapped(){
        view.endEditing(true)
    }
    
    //check for validity of contact info. If valid, pass info to homeVC and dismiss. Else, throw up an alert VC telling the user what went wrong.
    @objc func saveContactTapped() {
        
        newContact?.firstName = firstNameTextField.text
        newContact?.lastName = lastNameTextField.text
        
        newContact?.phone = [phoneTextField.text ?? "no phone text"]
        
        newContact?.email = [emailTextField.text ?? "no email text"]
        newContact?.address = [addressTextField.text ?? "no address text"]
        
        //only create a new contact if there is a first name and phone number
        if let newContact = newContact,let _ = newContact.firstName, let _ = newContact.phone  {
            delegate?.createNew(contact: newContact)
        } else {
            print("contact invalid!")
        }
        dismissNewContactVC()
        
    }
}

extension NewContactViewController: UITextFieldDelegate{
    
    
    func setTextFieldDelegates(){
        textFields = [firstNameTextField,lastNameTextField,dateOfBirthTextField,emailTextField,addressTextField,phoneTextField]
        textFields?.forEach{ $0.delegate = self }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    ////if d.o.b field is selected, present a datepicker instead.
    //courtesy Natalia Terlecka, https://stackoverflow.com/questions/11197855/iphone-display-date-picker-on-uitextfield-touch/11198489#11198489
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTextField = textField
        if textField.placeholder == "date of birth"{
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.addTarget(self, action: #selector(updateTextFieldWithDate(sender:)), for: .valueChanged)
            textField.inputView = datePicker
            textField.text = formatForView(date: datePicker.date)
        }
    }
    //update the d.o.b text field with the date picked by the datepicker
    @objc func updateTextFieldWithDate(sender: UIDatePicker){
        dateOfBirthTextField.text = formatForView(date: sender.date)
    }
    
    //given a Date object, return its string representation as MMM dd, yyyy
    func formatForView(date: Date) -> String{
        newContact?.dob = date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy"
        return formatter.string(from:date)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
    }
    
}
