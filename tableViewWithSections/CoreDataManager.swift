//
//  CoreDataManager.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/26/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import Foundation
import CoreData


class CoreDataManager {
    var managedContext: NSManagedObjectContext
    var contactsArray: [String] {
        return self.fetchAllContacts()
    }
    
    init(context: NSManagedObjectContext){
        self.managedContext = context
        //self.fetchAllContacts()
    }
    
    func saveContext(){
        do {
            try managedContext.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //create user operation
    func createNewContact(delegateContact: DelegateContact) {
        print(
        delegateContact.firstName ?? "nil first name",
        delegateContact.lastName ?? "nil last name",
        delegateContact.dob?.description ?? "nil dob",
        delegateContact.address?.first ?? "nil address",
        delegateContact.email?.first ?? "nil email",
        delegateContact.phone?.first ?? "nil phone"
        )
        
        let newContact = Contact(context: managedContext)
//        let newAddress = Address(context: managedContext)
//        let newEmail = Email(context: managedContext)
//        let newPhone = Phone(context: managedContext)
//        newAddress.street =  address
//        newPhone.number = phoneNumber
        newContact.firstName = delegateContact.firstName
        newContact.lastName = delegateContact.lastName
        
        newContact.uniqueID = delegateContact.uniqueID
        

        saveContext()
    }
    
    //read user data operation
    func fetchAllContacts() -> [String]{
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        //request.returnsObjectsAsFaults = false
        
        var contacts = [String]()
        do {
            let fetchResults = try managedContext.fetch(request)
            for result in fetchResults {
                //                let data = result.value(forKey: field) as! String
                contacts.append(result.firstName!+" "+result.lastName!)
                //print(result.name ?? "no name!")
                //let data = result.uniqueID
                //let data = result.addresses as! Set<Address>
                //print(data.first?.street ?? "no address!")
                //print(data ?? "no ID!")
            }
        } catch {
            print(error.localizedDescription)
        }
        return contacts
    }
    
    //update user operation
    func updateContact(oldContact: DelegateContact,newContact: DelegateContact){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        //find all users with the given name, update their age/email to new values
        request.predicate = NSPredicate(format:"name = %@",oldContact.uniqueID)
        
        do {
            let contactsInContext = try managedContext.fetch(request)
            if let validContact = contactsInContext.first{
                validContact.setValue(newContact.firstName, forKey: "firstName")
                validContact.setValue(newContact.lastName, forKey: "lastName")
                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    //delete user operation
    func deleteContact(uniqueID: String){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        //ugh...have to fix unique id 
        request.predicate = NSPredicate(format: "uniqueID = %@", uniqueID)
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
