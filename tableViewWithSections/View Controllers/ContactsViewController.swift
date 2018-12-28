//
//  ViewController.swift
//  tableViewWithSections
//
//  Created by Jerry Wang on 12/20/18.
//  Copyright © 2018 Jerry Wang. All rights reserved.
//

import UIKit
import CoreData

struct User {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let email: [String]
    let phone: [String]?
    let address: [String]
}

class ContactsViewController: UITableViewController {
    //var headers = CharacterSet.letters
        
    var headers = ["A","B","C","D","E","F","G","H","I","J", "K","L","M", "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    
    var sectionHeaderHeight = CGFloat(25)
    
    var firstCharToNameDict: [Character:[DelegateContact]]?
    
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
        if let currentDelegateContacts = coreDataManager?.contactsArray{
        //group the names by their first letter, to make table view loading much easier
            firstCharToNameDict = Dictionary(grouping: currentDelegateContacts, by: { $0.firstName!.first! })
        }
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let contacts = coreDataManager?.contactsArray {
//            for contact in contacts {
//                print(contact)
//            }
//        }
//
//    }
    
    @objc func addContactTapped(){
        if let newContactVC = storyboard?.instantiateViewController(withIdentifier: "newContact") as? NewContactViewController{
            newContactVC.delegate = self
            navigationController?.pushViewController(newContactVC, animated: true)
        }
    }

    //return total number of sections in the tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return firstCharToNameDict?.keys.count ?? 0
    }
    
    //return height for section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //return title for the section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionKeys = firstCharToNameDict?.keys.sorted(){
            return String(sectionKeys[section])
        } else { return nil }
    }
    //return number of rows for every section (i.e number of names per prefix)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let groupByPrefixDictionary = firstCharToNameDict{
            let key = groupByPrefixDictionary.keys.sorted()[section]
            return (groupByPrefixDictionary[key]?.count ?? 0)
        }
        return 0
    }
    
    //define what data appears in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        if let groupByPrefixDictionary = firstCharToNameDict {
            let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
            if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                cell.textLabel?.text = sortedContacts[indexPath.row].fullName
            }
            cell.imageView?.image = UIImage(named: "neutralProfile.png")
        }
        return cell
    }
    //when a row is selected, instantiate the profile view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section, indexPath.row)
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController{
            if let groupByPrefixDictionary = firstCharToNameDict {
                let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
                if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                    profileVC.contactProfile = sortedContacts[indexPath.row]
                }
            }
            
            
            //profileVC.contactProfile = User(firstName: "Jerry", lastName: "Wang", dateOfBirth: "8-17-1991", email: ["jerry.wang.ct@gmail.com"], phone: ["7814720251","2032312615","2033874366"], address: ["19 Cedar Acres Rd"])
            navigationController?.pushViewController(profileVC, animated: true)
        }
    }
}

extension ContactsViewController: NewContactDelegate {
    func createNew(contact: DelegateContact) {
        coreDataManager?.createNewContact(delegateContact: contact)
        
        if firstCharToNameDict != nil, let firstChar = contact.firstName?.first {
            var names = firstCharToNameDict?[firstChar] ?? []
            names.append(contact)
            firstCharToNameDict?[firstChar] = names
        }
        self.tableView.reloadData()
    }
}
