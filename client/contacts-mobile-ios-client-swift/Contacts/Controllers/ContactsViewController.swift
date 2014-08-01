/*
 * JBoss, Home of Professional Open Source.
 * Copyright Red Hat, Inc., and individual contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import AeroGearPush

class ContactsViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate, ContactDetailsViewControllerDelegate {
    
    var contacts = [String: [Contact]]()
    var filteredContacts = [Contact]()
    
    var contactsSectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup "pull to refresh" control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        // hide the back button, logout button is used instead
        self.navigationItem.hidesBackButton = true;

        refresh()
    }
    
    // MARK: - Remote Notification handler methods
    
    func performFetchWithUserInfo(userInfo: [NSObject : AnyObject],  completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
        // extract the id from the notification
        let recId = userInfo["id"] as NSString
        
        // Note: in case the user created the contact locally, a notification will still be received by the server
        //       Since we have already added, no need to fetch it again so simple return
        if contactWithId(recId.integerValue) {
            return;
        }
        
        ContactsNetworker.shared.GET("/contacts/\(recId)", parameters: nil) {(response, result, error) in
            
            if error {
                var alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                alert.show()
                
            } else { // success
                // add to model
                self.addContact(Contact(fromDictionary: result as [String: AnyObject]))
                
                // refresh tableview
                self.tableView.reloadData()
            }
            
            // IMPORTANT:
            // always let the system know we are done so 'UI snapshot' can be taken
            completionHandler(.NewData)
        }
    }
    
    func displayDetailsForContactWithId(recId: NSString) {
        let contact = contactWithId(recId.integerValue)

        if contact {
            performSegueWithIdentifier("EditContactSegue", sender: contact)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return 1
        } else {
            return contactsSectionTitles.count
        }
    }
    
    override func tableView(tableView: UITableView!, titleForHeaderInSection section: Int) -> String!  {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return nil
        } else {
            return contactsSectionTitles[section]
        }
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return filteredContacts.count
        } else {
            let sectionTitle = contactsSectionTitles[section]
        
            return contacts[sectionTitle]!.count
        }
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView!) -> [AnyObject]! {
        if tableView === self.searchDisplayController.searchResultsTableView {
            return nil
        } else {
            // user-locale alphabet list
            return UILocalizedIndexedCollation.currentCollation().sectionIndexTitles
        }
    }
    
    override func tableView(tableView: UITableView!, sectionForSectionIndexTitle title: String!, atIndex index: Int) -> Int {
        if let index = find(contactsSectionTitles, title) {
            return index
        }
        
        return NSNotFound
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell

        let sectionTitle = contactsSectionTitles[indexPath.section]

        var contact: Contact?
        
        if tableView === self.searchDisplayController.searchResultsTableView {
            contact = filteredContacts[indexPath.row]
        } else {
           contact = contacts[sectionTitle]![indexPath.row]
        }

        cell.textLabel.text = "\(contact!.firstname) \(contact!.lastname)"
        cell.detailTextLabel.text = contact!.email

        return cell
    }

    override func tableView(tableView: UITableView!, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath!) {
        performSegueWithIdentifier("EditContactSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        
        var contact:Contact?
        
        if tableView === self.searchDisplayController.searchResultsTableView {
            contact = filteredContacts[indexPath.row]
        } else {
            let sectionTitle = contactsSectionTitles[indexPath.section]
            contact = contacts[sectionTitle]![indexPath.row]
        }
        
        if editingStyle == .Delete {
            ContactsNetworker.shared.DELETE("/contacts/\(contact!.recId!)", parameters: contact!.asDictionary()) { (response, result, error) in
                
                if error {
                    var alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                    alert.show()
                    
                } else { // success
                    
                    var section:String!
                    var index:Int!
                    
                    // if delete was performed under search mode
                    if tableView === self.searchDisplayController.searchResultsTableView {
                        // remove from the filter list
                        self.filteredContacts.removeAtIndex(indexPath.row)
                        
                        // determine the section/row in the local model using the contact id
                        var (key, row) = self.indexOfContactWithId(contact!.recId)!
                        section = key
                        index = row
                        
                    } else {
                        // determine the section/row in the local model using the indexpath
                        section = self.contactsSectionTitles[indexPath.section]
                        index = indexPath.row
                    }

                    // the contacts in that section
                    var list = self.contacts[section]!
                    // delete it from local model
                    list.removeAtIndex(index)
                    self.contacts[section] = list

                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                    // if it was the last contact in the section, delete the section too
                    if list.count == 0 {
                        self.contacts.removeValueForKey(section)
                        // determine the index of this section
                        self.contactsSectionTitles.removeAtIndex(find(self.contactsSectionTitles, section)!)
                    }
                    
                    tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - ContactDetailsViewControllerDelegate methods
    
    func contactDetailsViewControllerDidCancel(controller: ContactDetailsViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func contactDetailsViewController(controller: ContactDetailsViewController, didSave contact: Contact) {
        // since completionhandler logic is common, define upfront
        let completionHandler = { (response: NSURLResponse!, result: AnyObject!, error: NSError!) -> () in
            self.refreshControl.endRefreshing()
            
            if error {
                var alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                alert.show()
                
            } else { // success
                // dismiss modal dialog
                self.dismissViewControllerAnimated(true, completion:nil);
                    
                // add to our local modal
                if (!contact.recId) {
                    contact.recId = (result as [String: AnyObject])["id"] as? NSNumber;
                    self.addContact(contact)
                }
                
                if self.searchDisplayController.active {
                    self.searchDisplayController.searchResultsTableView.reloadData()
                } else {
                    // ask table to refresh
                    self.tableView.reloadData()
                }
            }
        }
        
        if contact.recId { // update existing
            ContactsNetworker.shared.PUT("/contacts/\(contact.recId!)", parameters: contact.asDictionary(), completionHandler:completionHandler)
        } else {
            ContactsNetworker.shared.POST("/contacts", parameters: contact.asDictionary(), completionHandler:completionHandler)
        }
    }

    // MARK: - Action Methods
    
    func refresh() {
        ContactsNetworker.shared.GET("/contacts", parameters: nil) {(response, result, error) in
            
            self.refreshControl.endRefreshing()
            
            if error {
                var alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                alert.show()
                
            } else { // success
                // clear any existing data
                self.contacts.removeAll(keepCapacity: false)
                self.contactsSectionTitles.removeAll(keepCapacity: false)
                
                for contact in result as [[String: AnyObject]] {
                    self.addContact(Contact(fromDictionary: contact))
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logoutPressed(sender: AnyObject!) {
        ContactsNetworker.shared.logout()  {(response, result, error) in
            if error {
                var alert = UIAlertView(title: "Oops!", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "Bummer")
                alert.show()

            } else {
                self.navigationController.popViewControllerAnimated(true)
            }
        };
    }
    
    // MARK: - UISearchBarDelegate delegate methods
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar!) {
        self.tableView.reloadData()
    }
    
    // MARK: - UISearchDisplayController delegate methods
    
    func filterContentForSearchText(searchText: String) {
        filteredContacts.removeAll(keepCapacity: false)
        
        for list in contacts.values {
            var filteredlist = list.filter { $0.firstname.containsIgnoreCase(searchText) || $0.lastname.containsIgnoreCase(searchText)}
            filteredContacts += filteredlist
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterContentForSearchText(searchString)
        
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        filterContentForSearchText(self.searchDisplayController.searchBar.text)
        
        return true
    }
    
    // MARK: - Seque methods
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "AddContactSegue" || segue.identifier == "EditContactSegue" {
            
            // for both "Add" and "Edit" mode, attach delegate to self
            let navigationController = segue.destinationViewController as UINavigationController
            let contactDetailsViewController = navigationController.viewControllers[0] as ContactDetailsViewController
            contactDetailsViewController.delegate = self
            
            // for "Edit", pass the Contact to the controller
            if segue.identifier == "EditContactSegue" {
                // determine the 'sender'
                var contact: Contact
                
                // if instance is a cell (which means it was clicked) determine AGContact from cell
                if sender is UITableViewCell {
                    contact = activeContactFromCell(sender as UITableViewCell)
                } else {
                    contact = sender as Contact
                }
                
                // assign it
                contactDetailsViewController.contact = contact
            }
        }
    }
    
    // MARK: - Utility methods
    
    func activeContactFromCell(cell: UITableViewCell) -> Contact {
        var contact:Contact!
        
        if self.searchDisplayController.active {
            let indexPath = self.searchDisplayController.searchResultsTableView.indexPathForCell(cell)
            
            contact = filteredContacts[indexPath.row]
            
        } else {
            let indexPath = self.tableView.indexPathForCell(cell)
            let sectionTitle = contactsSectionTitles[indexPath.section]
            
            contact = contacts[sectionTitle]![indexPath.row]
        }

        return contact
    }
    
    func addContact(contact: Contact) {
        // determine section by first letter of "first name"
        let letter = contact.firstname!.substringToIndex(advance(contact.firstname!.startIndex, 1)).uppercaseString

        // if the section exist
        if var contactsInSection = contacts[letter] {
            // add it
            contactsInSection += contact
            contactsInSection.sort({ $0.firstname < $1.firstname })
                
            contacts[letter] = contactsInSection
            
        } else {
            // create it
            contactsSectionTitles += letter
            // sort newly inserted section name
            contactsSectionTitles.sort({ $0 < $1 })
         
            // create arr to hold contacts in section
            var contactsInSection = [Contact]()
            contactsInSection += contact
            
            // assign it
            contacts[letter] = contactsInSection
        }
    }
    
    func contactWithId(recId: NSNumber) -> Contact? {
        for list in contacts.values {
            for contact in list {
                if contact.recId == recId {
                    return contact
                }
            }
        }
        
        return nil
    }
    
    func indexOfContactWithId(recId: NSNumber) -> (section: String, row: Int)? {
        for (section, list) in contacts {
            for (index, contact) in enumerate(list) {
                if contact.recId == recId {
                    return (section, index)
                }
            }
        }
        
        return nil
    }
}
