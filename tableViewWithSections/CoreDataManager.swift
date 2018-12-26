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
    func createNewContact(firstName: String, lastName: String) {
        
        
        let newContact = Contact(context: managedContext)
//        let newAddress = Address(context: managedContext)
//        let newEmail = Email(context: managedContext)
//        let newPhone = Phone(context: managedContext)
//        newAddress.street =  address
//        newPhone.number = phoneNumber
        newContact.firstName = firstName
        newContact.lastName = lastName
        //I chose to hash the Contact instance to provide a unique ID, rather than using a UUID, because UUID is not supported below iOS 11.0. Basically, I'd like more users and I also think hashing will disallow two contacts with the exact same properties from being saved to persistent store.
        //newContact.uniqueID = Int32(newContact.hash)
//        if address != nil {
//            newUser.addToAddresses(newAddress)
//        }
//        newUser.addToEmail(newEmail)
//        newUser.birthDate = dateOfBirth
//        newUser.addToPhones(newPhone)
//        newUser.uniqueID = UUID.init()
        //contactsArray.append(newContact)
        
        
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
    func updateContact(name: String, newFirst: Int, newLast: String){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        //find all users with the given name, update their age/email to new values
        request.predicate = NSPredicate(format:"name = %@",name)
        
        do {
            let test = try managedContext.fetch(request)
            if let validContact = test.first{
                validContact.setValue(newFirst, forKey: "firstName")
                validContact.setValue(newLast, forKey: "lastName")
                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    //delete user operation
    func deleteContact(uniqueID: Int32){
        let request: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        //ugh...have to fix unique id 
        //request.predicate = NSPredicate(format: "uniqueID = %@", uniqueID as CVarArg)
        //find the first user with name and delete from managed context
        do {
            let test = try managedContext.fetch(request)
            if let validContact = test.first{
                managedContext.delete(validContact)
                saveContext()
            }
        }catch {
            print(error.localizedDescription)
        }
    }
    
}
