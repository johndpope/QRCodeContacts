//
//  NewContactViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/24/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit

class NewContactViewController: ViewController, UITextFieldDelegate{
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    var currentTextField: UITextField?
    
    var textFields: [UITextField]?
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegates()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDismissTapped))
        view.addGestureRecognizer(tapRecognizer)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNewContactVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveContactTapped))
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil);
        
    }
    
    deinit{
        //remove notifications
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //https://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
    @objc func keyboardWillShow(notification: NSNotification) {
        //self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 20, right: 0.0)
        
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
        //var info = notification.userInfo!
        //let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        //let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        //self.scrollView.contentInset = contentInsets
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        self.view.endEditing(true)
        //self.scrollView.isScrollEnabled = false
    }
    
    @objc func dismissNewContactVC(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardDismissTapped(){
        view.endEditing(true)
        //self.scrollView.isScrollEnabled = true
    }
    
    
    @objc func saveContactTapped() {
        //check for validity of contact info. If valid, pass info to homeVC and dismiss. Else, throw up an alert VC telling the user what went wrong. 
        print("contact info")
        textFields?.forEach{ print("\($0.placeholder ?? "nil") : \($0.text ?? "")") }
    }
    
    
    
    func setTextFieldDelegates(){
        textFields = [firstNameTextField,lastNameTextField,dateOfBirthTextField,emailTextField,addressTextField,phoneTextField]
        textFields?.forEach{ $0.delegate = self }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
    }
    
}
