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
    
    var filteredContactsDict = [Character: [Contact]]()
    
    private var coreDataManager: CoreDataManager?
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //use the same view controller to display results, no need for a custom search results controller
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takeQRPhotoTapped))
        self.title = "Contacts"
        //get our managed object context, the 'scratchpad' to jot down our CRUD operations on data before committing to persistent store
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        coreDataManager = CoreDataManager(context: context)
        coreDataManager?.delegate = self
        searchController = UISearchController(searchResultsController: nil)
        // Setup the Search Controller
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = "Search Contacts"
        // Setup the Scope Bar
        searchController?.searchBar.scopeButtonTitles = ["Name","Email", "Address"]
        searchController?.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    //group the names by their first letter, to make table view loading much easier
    func groupContactsByFirstChar(){
        if let currentInterimContacts = coreDataManager?.contactsArray{
            firstCharToContactsDict = Dictionary(grouping: currentInterimContacts, by: { ($0.firstName?.first!)! })
        }
    }
    
    //refresh the tableview after returning from either the profile or new contact view. 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupContactsByFirstChar()
        self.tableView.reloadData()
    }
    
    //'+' button behavior
    @objc func addContactTapped(){
        if let newContactVC = storyboard?.instantiateViewController(withIdentifier: "newContact") as? NewContactViewController{
            newContactVC.coreDataManager = coreDataManager
            navigationController?.pushViewController(newContactVC, animated: true)
        }
    }
    
    @objc func takeQRPhotoTapped(){
        if let QRScannerVC = storyboard?.instantiateViewController(withIdentifier: "QRScannerVC") as? QRScannerViewController{
            print("yay!")
            QRScannerVC.delegate = self
            navigationController?.pushViewController(QRScannerVC, animated: true)
        }
    }

    //return total number of sections in the tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering(){
            return filteredContactsDict.keys.count
        }else{
            return firstCharToContactsDict?.keys.count ?? 0
        }
        
    }
    
    //return height for section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderHeight
    }
    
    //return title for the section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering(){
            let key = filteredContactsDict.keys.sorted()[section]
            return String(key)
        } else {
            if let sectionKeys = firstCharToContactsDict?.keys.sorted(){
                return String(sectionKeys[section])
            } else { return nil }
        }
    }
    //return number of rows for every section (i.e number of names per prefix)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            let key = filteredContactsDict.keys.sorted()[section]
            return filteredContactsDict[key]?.count ?? 0
        } else {
            if let groupByPrefixDictionary = firstCharToContactsDict{
                let key = groupByPrefixDictionary.keys.sorted()[section]
                return (groupByPrefixDictionary[key]?.count ?? 0)
            }
            return 0
        }
    }
    //can edit all rows
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isFiltering()
    }
    
    //define deletion behavior when user swipes right on a cell to delete a contact
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete && !isFiltering(){
            
            if let groupByPrefixDictionary = firstCharToContactsDict {
                let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
                var sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } )

                coreDataManager?.delete(contact: (sortedContacts?[indexPath.row])!)
                sortedContacts?.remove(at: indexPath.row)
                if (sortedContacts?.count)! > 0 {
                    firstCharToContactsDict?[key] = sortedContacts
                } else {
                    firstCharToContactsDict?[key] = nil
                }
                tableView.reloadData()
            }
            
        }
    }
    //define what data appears in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nameCell", for: indexPath)
        if isFiltering(){
            let key = filteredContactsDict.keys.sorted()[indexPath.section]
            let sortedContacts = filteredContactsDict[key]?.sorted(by: { $0.fullName < $1.fullName } )
            
            cell.textLabel?.text = sortedContacts?[indexPath.row].fullName
            if let validPicture = sortedContacts?[indexPath.row].profilePicture {
                cell.imageView?.image = UIImage(data: validPicture)
            } else {
                cell.imageView?.image = UIImage(named: "neutralProfile.png")
            }
        
        } else {
            if let groupByPrefixDictionary = firstCharToContactsDict {
                let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
                if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                    
                    cell.textLabel?.text =  sortedContacts[indexPath.row].fullName
                    if let validPicture = sortedContacts[indexPath.row].profilePicture {
                        cell.imageView?.image = UIImage(data: validPicture)
                    }else{
                        cell.imageView?.image = UIImage(named: "neutralProfile.png")
                    }
                }
            }
        }
        return cell
    }
    //when a row is selected, instantiate the profile view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "profileView") as? ProfileViewController{
            if isFiltering(){
                let key = filteredContactsDict.keys.sorted()[indexPath.section]
                let sortedContacts = filteredContactsDict[key]?.sorted(by: { $0.fullName < $1.fullName } )
                profileVC.contactProfile = sortedContacts?[indexPath.row]
                profileVC.coreDataManager = coreDataManager
            } else {
                if let groupByPrefixDictionary = firstCharToContactsDict {
                    let key = groupByPrefixDictionary.keys.sorted()[indexPath.section]
                    if let sortedContacts = groupByPrefixDictionary[key]?.sorted(by: { $0.fullName < $1.fullName } ) {
                        profileVC.contactProfile = sortedContacts[indexPath.row]
                        profileVC.coreDataManager = coreDataManager
                    }
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

extension ContactsViewController: UISearchResultsUpdating{
    func isFiltering() -> Bool {
//        let searchBarScopeIsFiltering = searchController?.searchBar.selectedScopeButtonIndex != 0
//        return (searchController?.isActive)! && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
        return (searchController?.isActive)!
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController?.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredContactsDict = (firstCharToContactsDict?.filter{
            $0.value.filter{ $0.fullName.lowercased().contains(searchText.lowercased()) }.count > 0
            })!
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //let searchBar = searchController.searchBar
        //let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!)
    }
}


extension ContactsViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension ContactsViewController: ScannerDelegate{
    func createContactFrom(decoded contact: CodableContact) {
        let newContact = NewContact(firstName: contact.firstName, lastName: contact.lastName, uniqueID: UUID.init().uuidString, dob: contact.dob, phone: contact.phone, email: contact.email, address: contact.address, profilePicture: nil)
        coreDataManager?.createNew(contact: newContact)
    }
}
