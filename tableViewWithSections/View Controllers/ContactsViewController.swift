//
//  ViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/20/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import CoreData

protocol UpdateHomeScreenDelegate: AnyObject {
    func addContactToDataSource(contact: Contact)
}

class ContactsViewController: UITableViewController {
    
    var sectionHeaderHeight = CGFloat(25)
    
    var firstCharToContactsDict: [Character:[Contact]]?
    
    private var coreDataManager: CoreDataManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactTapped))
        self.title = "Contacts"
        //get our managed object context, the 'scratchpad' to jot down our CRUD operations on data before committing to persistent store
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        coreDataManager = CoreDataManager(context: context)
        
        //get the existing contacts
        if let currentInterimContacts = coreDataManager?.contactsArray{
        //group the names by their first letter, to make table view loading much easier
            //dump(currentInterimContacts)"
            
            firstCharToContactsDict = Dictionary(grouping: currentInterimContacts, by: { ($0.firstName?.first!)! })
        }
        
    }
    
    @objc func addContactTapped(){
        if let newContactVC = storyboard?.instantiateViewController(withIdentifier: "newContact") as? NewContactViewController{
            newContactVC.managedContext = coreDataManager?.managedContext
            newContactVC.delegate = self
            navigationController?.pushViewController(newContactVC, animated: true)
        }
    }

    //return total number of sections in the tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return firstCharToContactsDict?.keys.count ?? 0
    }
    
    //return height for section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //return title for the section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionKeys = firstCharToContactsDict?.keys.sorted(){
            return String(sectionKeys[section])
        } else { return nil }
    }
    //return number of rows for every section (i.e number of names per prefix)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupByPrefixDictionary = firstCharToContactsDict{
            let key = groupByPrefixDictionary.keys.sorted()[section]
            return (groupByPrefixDictionary[key]?.count ?? 0)
        }
        return 0
    }
    
    //define what data appears in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        if let groupByPrefixDictionary = firstCharToContactsDict {
            let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
            if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                
                cell.textLabel?.text =  sortedContacts[indexPath.row].fullName
            }
            cell.imageView?.image = UIImage(named: "neutralProfile.png")
        }
        return cell
    }
    //when a row is selected, instantiate the profile view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController{
            if let groupByPrefixDictionary = firstCharToContactsDict {
                let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
                if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                    profileVC.contactProfile = sortedContacts[indexPath.row]
                    profileVC.coreDataManager = coreDataManager
                }
            }
            
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}


extension ContactsViewController: UpdateHomeScreenDelegate {
    func addContactToDataSource(contact: Contact) {
        if let firstChar = contact.firstName?.first {
            var contacts = self.firstCharToContactsDict?[firstChar] ?? []
            contacts.append(contact)
            firstCharToContactsDict?[firstChar] = contacts
            
            self.tableView.reloadData()
        } else {
            print("contact does not have a first name?!")
        }        
    }
}
