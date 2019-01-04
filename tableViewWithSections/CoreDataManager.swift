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
    case FirstName,LastName,Dob,Phone,Email,Address
}

class CoreDataManager {
    var managedContext: NSManagedObjectContext
    var contactsArray: [Contact] {
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
    
    
    //read user data operation
    func fetchAllContacts() -> [Contact]{
        //request.returnsObjectsAsFaults = false
        do {
            let request: NSFetchRequest<Contact> = Contact.fetchRequest()
            let fetchResults = try managedContext.fetch(request)
            return fetchResults
        } catch {
            print(error.localizedDescription)
        }
        return [Contact]()
    }
    
    //update user operation
    func updateCurrentContact<T: Equatable>(uniqueID: String, field: DataField, oldValue: T, newValue: T) -> Bool{
        var didUpdateSuccessfully = false
        let contactRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        contactRequest.predicate = NSPredicate(format: "uniqueID = %@",uniqueID)
        
        do {
            let contactsInContext = try managedContext.fetch(contactRequest)
            if let validContact = contactsInContext.first{
                switch field {
                case .FirstName:
                    validContact.firstName = newValue as? String
                    didUpdateSuccessfully = true
                case .LastName:
                    validContact.lastName = newValue as? String
                    didUpdateSuccessfully = true
                case .Dob:
                    validContact.dob = newValue as? Date
                    didUpdateSuccessfully = true
                case .Phone:
                    let oldPhoneRequest: NSFetchRequest<Phone> = Phone.fetchRequest()
                    oldPhoneRequest.predicate = NSPredicate(format: "number = %@", oldValue as! String)
                    let predicate1 = NSPredicate(format: "number = %@", oldValue as! String)
                    let predicate2 = NSPredicate(format: "contact.uniqueID = %@", validContact.uniqueID!)
                    oldPhoneRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                    do {
                        let newPhone = Phone(context: managedContext)
                        newPhone.number = newValue as? String
                        validContact.addToPhones(newPhone)
                        
                        let oldPhone = try managedContext.fetch(oldPhoneRequest)
                        if let validOldPhone = oldPhone.first{
                            print("#phones before ", validContact.phones?.count as Any)
                            managedContext.delete(validOldPhone)
                            validOldPhone.contact = nil
                            validContact.removeFromPhones(validOldPhone)
                            print("#phones after ", validContact.phones?.count as Any)
                        }
                        didUpdateSuccessfully = true
                    }
                    
                case .Email:
                    let oldEmailRequest: NSFetchRequest<Email> = Email.fetchRequest()
                    oldEmailRequest.predicate = NSPredicate(format: "address = %@", oldValue as! String)
                    let predicate1 = NSPredicate(format: "address = %@", oldValue as! String)
                    let predicate2 = NSPredicate(format: "contact.uniqueID = %@", validContact.uniqueID!)
                    oldEmailRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                    do {
                        
                        let newEmail = Email(context: managedContext)
                        newEmail.address = newValue as? String
                        validContact.addToEmails(newEmail)
                        
                        
                        let oldEmail = try managedContext.fetch(oldEmailRequest)
                        if let validOldEmail = oldEmail.first{
                            print("#emails before ", validContact.emails?.count as Any)
                            managedContext.delete(validOldEmail)
                            validOldEmail.contact = nil
                            validContact.removeFromEmails(validOldEmail)
                            print("#emails after ", validContact.emails?.count as Any)
                        }
                        didUpdateSuccessfully = true
                        
                    }
                case .Address:
                    let oldAddressRequest: NSFetchRequest<Address> = Address.fetchRequest()
                    let predicate1 = NSPredicate(format: "street = %@", oldValue as! String)
                    let predicate2 = NSPredicate(format: "contact.uniqueID = %@", validContact.uniqueID!)
                    oldAddressRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                    
                    do {
                        
                        let newAddress = Address(context: managedContext)
                        newAddress.street = newValue as? String
                        validContact.addToAddresses(newAddress)
                        
                        
                        let oldAddress = try managedContext.fetch(oldAddressRequest)
                        if let validOldAddress = oldAddress.first{
                            print("#addresses before ", validContact.addresses?.count as Any)
                            managedContext.delete(validOldAddress)
                            validOldAddress.contact = nil
                            validContact.removeFromAddresses(validOldAddress)
                            print("#addresses after " ,validContact.addresses?.count as Any)
                        }
                        didUpdateSuccessfully = true
                    }
                }
                
                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
       
        return didUpdateSuccessfully
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
                            let predicate1 = NSPredicate(format: "number = %@",value)
                            let predicate2 = NSPredicate(format: "contact.uniqueID = %@",uniqueID)
                            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                            let storedPhone = try  managedContext.fetch(request)
                            if let validPhone = storedPhone.first{
                                managedContext.delete(validPhone)
                                validPhone.contact = nil
                                validContact.removeFromPhones(validPhone)
                            }
                            
                        }
                    case .Email:
                        do {
                            let request: NSFetchRequest<Email> = Email.fetchRequest()
                            let predicate1 = NSPredicate(format: "address = %@",value)
                            let predicate2 = NSPredicate(format: "contact.uniqueID = %@",uniqueID)
                            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                            let storedEmail = try  managedContext.fetch(request)
                            if let validEmail = storedEmail.first{
                                managedContext.delete(validEmail)
                                validEmail.contact = nil
                                validContact.removeFromEmails(validEmail)
                            }
                            
                    }
                    case .Address:
                        do {
                            let request: NSFetchRequest<Address> = Address.fetchRequest()
                            let predicate1 = NSPredicate(format: "street = %@",value)
                            let predicate2 = NSPredicate(format: "contact.uniqueID = %@",uniqueID)
                            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1,predicate2])
                            let storedAddress = try  managedContext.fetch(request)
                            if let validAddress = storedAddress.first{
                                managedContext.delete(validAddress)
                                validAddress.contact = nil
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
    func delete(contact: Contact){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()

        //ugh...have to fix unique id
        request.predicate = NSPredicate(format: "uniqueID = %@", contact.uniqueID!)
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

extension Contact {
    var fullName: String {
        return self.firstName! + " " + (self.lastName ?? "")
    }
}
