//
//  CoreDataManager.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/26/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import Foundation
import CoreData

enum DataField {
    case Dob,Phone,Email,Address
}

class CoreDataManager {
    var managedContext: NSManagedObjectContext
    var contactsArray: [InterimContact] {
        return self.fetchAllContacts()
    }
    
    init(context: NSManagedObjectContext){
        self.managedContext = context
    }
    
    func saveContext(){
        do {
            try managedContext.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //create user operation
    func createNewContact(from contact: InterimContact) {
        let newContact = Contact(context: managedContext)
        newContact.firstName = contact.firstName
        newContact.lastName = contact.lastName
        
        newContact.dob = contact.dob
        newContact.uniqueID = contact.uniqueID
        
        if let validAddress = contact.address.first{
            let newAddress = Address(context: managedContext)
            newAddress.street = validAddress
            newContact.addToAddresses(newAddress)
        }
        
        if let validEmail = contact.email.first{
            let newEmail = Email(context: managedContext)
            newEmail.address = validEmail
            newContact.addToEmails(newEmail)
        }
        
        if let validPhone = contact.phone.first {
            let newPhone = Phone(context: managedContext)
            newPhone.number = validPhone
            newContact.addToPhones(newPhone)
        }
        
        saveContext()
    }
    
    //read user data operation
    func fetchAllContacts() -> [InterimContact]{
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        //request.returnsObjectsAsFaults = false
        var contacts = [InterimContact]()
        do {
            let fetchResults = try managedContext.fetch(request)
            for contact in fetchResults {
                contacts.append(InterimContact.convertToInterimContact(from: contact))
            }
        } catch {
            print(error.localizedDescription)
        }
        //dump(contacts)
        return contacts
    }
    
    //update user operation
    func updateCurrentContact<T: Equatable>(uniqueID: String, field: DataField, oldValue: T, newValue: T){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        //find all users with the given name, update their age/email to new values
        request.predicate = NSPredicate(format: "uniqueID = %@",uniqueID)
        
        do {
            let contactsInContext = try managedContext.fetch(request)
            if let validContact = contactsInContext.first{
                switch field {
                case .Dob:
                    validContact.dob = newValue as? Date
                case .Phone:
                    let request: NSFetchRequest<Phone> = Phone.fetchRequest()
                    request.predicate = NSPredicate(format: "number = %@", oldValue as! String)
                    do {
                    let oldPhone = try managedContext.fetch(request)
                        if let validOldPhone = oldPhone.first{
                            let newPhone = Phone(context: managedContext)
                            newPhone.number = newValue as? String
                            validContact.removeFromPhones(validOldPhone)
                            validContact.addToPhones(newPhone)
                        }
                    }
                    
                case .Email:
                    let request: NSFetchRequest<Email> = Email.fetchRequest()
                    request.predicate = NSPredicate(format: "address = %@", oldValue as! String)
                    do {
                        let oldEmail = try managedContext.fetch(request)
                        if let validOldEmail = oldEmail.first{
                            let newEmail = Email(context: managedContext)
                            newEmail.address = newValue as? String
                            validContact.removeFromEmails(validOldEmail)
                            validContact.addToEmails(newEmail)
                        }
                    }
                case .Address:
                    let request: NSFetchRequest<Address> = Address.fetchRequest()
                    request.predicate = NSPredicate(format: "street = %@", oldValue as! String)
                    do {
                        let oldAddress = try managedContext.fetch(request)
                        if let validOldAddress = oldAddress.first{
                            let newAddress = Address(context: managedContext)
                            newAddress.street = newValue as? String
                            validContact.removeFromAddresses(validOldAddress)
                            validContact.addToAddresses(newAddress)
                        }
                    }
                }

                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func add(value: String, from uniqueID: String, with field: DataField){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "uniqueID = %@",uniqueID)
        do {
            let storedContact = try managedContext.fetch(request)
            if let validContact = storedContact.first{
                switch field{
                case .Phone:
                    let newPhone = Phone(context: managedContext)
                    newPhone.number = value
                    validContact.addToPhones(newPhone)
                case .Email:
                    let newEmail = Email(context: managedContext)
                    newEmail.address = value
                    validContact.addToEmails(newEmail)
                case .Address:
                    let newAddress = Address(context: managedContext)
                    newAddress.street = value
                    validContact.addToAddresses(newAddress)
                default: break
                }
            }
            saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func delete(value: String, from uniqueID: String, with field: DataField){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        request.predicate = NSPredicate(format: "uniqueID = %@",uniqueID)
        do {
            let storedContact = try managedContext.fetch(request)
            if let validContact = storedContact.first{
                switch field{
                    case .Phone:
                        do {
                            let request: NSFetchRequest<Phone> = Phone.fetchRequest()
                            request.predicate = NSPredicate(format: "number = %@",value)
                            let storedPhone = try  managedContext.fetch(request)
                            if let validPhone = storedPhone.first{
                            validContact.removeFromPhones(validPhone)
                            }
                            
                        }
                    case .Email:
                        do {
                            let request: NSFetchRequest<Email> = Email.fetchRequest()
                            request.predicate = NSPredicate(format: "address = %@",value)
                            let storedEmail = try  managedContext.fetch(request)
                            if let validEmail = storedEmail.first{
                                validContact.removeFromEmails(validEmail)
                            }
                            
                    }
                    case .Address:
                        do {
                            let request: NSFetchRequest<Address> = Address.fetchRequest()
                            request.predicate = NSPredicate(format: "street = %@",value)
                            let storedAddress = try  managedContext.fetch(request)
                            if let validAddress = storedAddress.first{
                                validContact.removeFromAddresses(validAddress)
                            }
                            
                    }
                    default: break
                }
            }
            saveContext()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    //delete user operation
    func delete(contact: InterimContact){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        //ugh...have to fix unique id 
        request.predicate = NSPredicate(format: "uniqueID = %@", contact.uniqueID)
        //find the first user with name and delete from managed context
        do {
            let contactsInContext = try managedContext.fetch(request)
            if let validContact = contactsInContext.first{
                managedContext.delete(validContact)
                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
}
