//
//  MasterViewController.swift
//
// Copyright (C) 2015 Orange
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Marc Capdevielle on 28/04/2015.
//  Copyright (c) 2015 Orange. All rights reserved.
//

import UIKit

let prototypesSection = 0
let templatesSection = 1
let datasourcesSection = 2
let sectionsCount = 3

class RootViewController: UITableViewController {

    var client: DVClient? = nil
    
    var swipeEdit = false // allows to have diffrent actions on swipe or edit
    var insertedNewCell = false // track if we inserted the new prototype/template cell
    
    var prototypes = [DVPrototype]()
    var templates = [DVTemplate]()
    var datasources = [DVDatasource]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
        
        // Register for changes on the default settings
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsChanged", name: NSUserDefaultsDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsButton = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "displaySettings")
        self.navigationItem.leftBarButtonItem = settingsButton
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        loadClient()
        reloadAllData()
    }
    
    func defaultsChanged() {
        loadClient()
        resetData()
        reloadAllData()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func loadClient() {
        let settings = NSUserDefaults.standardUserDefaults()
        settings.synchronize()
        
        // Initialize the client with a client ID and a key
        client = DVClient(clientID: settings.stringForKey("clientID")!, key:settings.stringForKey("masterKey")!)
        // Force baseURL of the service to a specific one (default is Datavenue production backend)
        client!.baseURL = NSURL(string:settings.stringForKey("baseURL")!)
    }
    
    func resetData() {
        self.prototypes = [DVPrototype]()
        self.templates = [DVTemplate]()
        self.datasources = [DVDatasource]()
        self.tableView.reloadData()
    }
    
    func reloadAllData() {
        // Retrieve all prototypes for this account
        client!.prototypesWithParams(nil) { (prototypes, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.prototypes = prototypes as! [DVPrototype]
                    self.tableView.reloadSections(NSIndexSet(index: prototypesSection), withRowAnimation: .Automatic)
                }
            }
        }
        
        // Retrive all templates for this account
        client!.templatesWithParams(nil) { (templates, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.templates = templates as! [DVTemplate]
                    self.tableView.reloadSections(NSIndexSet(index: templatesSection), withRowAnimation: .Automatic)
                }
            }
        }
        
        // Retrieve all datasources for this account
        client!.datasourcesWithParams(nil) { (datasources, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.datasources = datasources as! [DVDatasource]
                    self.tableView.reloadSections(NSIndexSet(index: datasourcesSection), withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    func displaySettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !swipeEdit {
            let indexPaths = [NSIndexPath(forRow:prototypes.count, inSection:prototypesSection), NSIndexPath(forRow: datasources.count, inSection: datasourcesSection)]
            if editing {
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                insertedNewCell = true
            } else if insertedNewCell {
                insertedNewCell = false
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        }
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDatasource" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let datasource = indexPath.section == 0 ? prototypes[indexPath.row] : datasources[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DatasourceViewController
                controller.datasource = datasource
                controller.navigationItem.title = datasource.name;
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case prototypesSection:  return "Prototypes"
        case templatesSection:   return "Templates"
        case datasourcesSection: return "Datasources"
        default: return ""
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == prototypesSection {
            return prototypes.count + (tableView.editing && !swipeEdit ? 1 : 0)
        } else if section == templatesSection {
            return templates.count
        } else if section == datasourcesSection {
            return datasources.count + (tableView.editing && !swipeEdit ? 1 : 0)
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (rowAction, indexPath) -> Void in
            self.removeRowAt(indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        let templateAction = UITableViewRowAction(style: .Normal, title: "As template") { (rowAction, indexPath) -> Void in
            if indexPath.section == prototypesSection {
                let newTemplate = DVTemplate(name: "template ".randomEnd(4), prototypeID: self.prototypes[indexPath.row].ID, client: self.client)
                newTemplate.saveWithCompletionHandler({ (template, error) -> Void in
                    if error != nil {
                        NSLog("template.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.templates.append(template)
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.templates.count-1, inSection: templatesSection)], withRowAnimation: .Fade)
                        }
                    }
                })
            }
        }
        
        let datasourceAction = UITableViewRowAction(style: .Normal, title: "As datasource") { (rowAction, indexPath) -> Void in
            if indexPath.section == templatesSection {
                let newDatasource = DVDatasource(name: "datasource ".randomEnd(4), templateID: self.templates[indexPath.row].ID, client: self.client)
                newDatasource.saveWithCompletionHandler({ (datasource, error) -> Void in
                    if error != nil {
                        NSLog("datasource.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.datasources.append(datasource)
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.datasources.count-1, inSection: datasourcesSection)], withRowAnimation: .Fade)
                        }
                    }
                })
            }
        }
        
        if indexPath.section == prototypesSection {
            if indexPath.row < prototypes.count {
                return swipeEdit ? [deleteAction, templateAction] : [deleteAction]
            }
        } else if indexPath.section == templatesSection {
            if indexPath.row < templates.count {
                return swipeEdit ? [deleteAction, datasourceAction] : [deleteAction]
            }
        } else if indexPath.section == datasourcesSection {
            if indexPath.row < datasources.count {
                return [deleteAction]
            }
        }
        return []
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let navDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NavDetailViewController") as! UINavigationController
        let detailViewController = navDetailViewController.topViewController as! DetailViewController
        
        let fields : [Field]
        let commitHandler : (commit: Bool, commitModificationsHander: () -> Void) -> Void
        
        if indexPath.section == prototypesSection {
            let prototype = prototypes[indexPath.row]
            
            fields = [
                Field(name:"ID", value:prototype.ID, readOnly: true),
                Field(name:"name", value:prototype.name),
                Field(name:"description", value:prototype.adescription),
            ]
            commitHandler = { (commit, completion) in
                if commit {
                    prototype.saveWithCompletionHandler({ (prototype, error) -> Void in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.prototypes[indexPath.row] = prototype
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                completion()
                            }
                        }
                    })
                } else {
                    completion()
                }
            }
        } else if indexPath.section == templatesSection {
            let template = templates[indexPath.row]
            
            fields = [
                Field(name: "ID", value: template.ID, readOnly: true),
                Field(name: "name", value: template.name),
                Field(name: "description", value: template.adescription),
                Field(name: "prototype ID", value: template.prototypeID ?? "None", readOnly: true),
            ]
            
            commitHandler = { (commit, completion) in
                if commit {
                    template.name = fields[1].value
                    template.adescription = fields[2].value
                    
                    template.saveWithCompletionHandler({ (template, error) -> Void in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.templates[indexPath.row] = template
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                completion()
                            }
                        } else {
                            completion()
                        }
                    })
                } else {
                    completion()
                }
            }
        } else {
            let datasource = datasources[indexPath.row]
            
            fields = [
                Field(name: "ID", value: datasource.ID, readOnly: true),
                Field(name: "name", value: datasource.name),
                Field(name: "description", value: datasource.adescription),
                Field(name: "template ID", value: datasource.templateID ?? "", readOnly: true),
            ]
            
            commitHandler = { (commit, completion) in
                if commit {
                    datasource.name = fields[1].value
                    datasource.adescription = fields[2].value
                    
                    datasource.saveWithCompletionHandler({ (datasource, error) -> Void in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.datasources[indexPath.row] = datasource
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                completion()
                            }
                        } else {
                            completion()
                        }
                    })
                } else {
                    completion()
                }
            }
        }
        
        detailViewController.configureWithFields(fields, commitModificationsHandler: commitHandler)
        self.navigationController?.presentViewController(navDetailViewController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        cell.selectionStyle = .Default
        
        if indexPath.section == prototypesSection {
            if indexPath.row < prototypes.count {
                cell.textLabel!.text = prototypes[indexPath.row].name
                cell.accessoryType = .DetailDisclosureButton
            } else {
                cell.textLabel!.text = "Add new prototype"
                cell.accessoryType = .None
            }
            
        } else if indexPath.section == templatesSection {
            cell.textLabel!.text = templates[indexPath.row].name
            cell.accessoryType = .DetailButton
            cell.selectionStyle = .None // templates have no keys or streams
        } else if indexPath.section == datasourcesSection {
            if indexPath.row < datasources.count {
                cell.textLabel!.text = datasources[indexPath.row].name
                cell.accessoryType = .DetailDisclosureButton
            } else {
                cell.textLabel!.text = "Add new datasource"
                cell.accessoryType = .None
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            removeRowAt(indexPath)
        } else if editingStyle == .Insert {
            if indexPath.section == prototypesSection {
                DVPrototype(name: "proto ".randomEnd(4), client: client).saveWithCompletionHandler({ (prototype, error) -> Void in
                    if error != nil {
                        NSLog("prototype.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.prototypes.append(prototype)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            } else if indexPath.section == datasourcesSection {
                DVDatasource(name: "datasource ".randomEnd(4), templateID: nil, client: client).saveWithCompletionHandler({ (datasource, error) -> Void in
                    if error != nil {
                        NSLog("datasource.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.datasources.append(datasource)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == prototypesSection && indexPath.row == prototypes.count {
            return  .Insert
        } else if indexPath.section == templatesSection && indexPath.row == templates.count {
            return  .Insert
        } else if indexPath.section == datasourcesSection && indexPath.row == datasources.count {
            return  .Insert
        }
        return .Delete
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Prevent selecting templates (nothing to show)
        if indexPath.section == templatesSection {
            return nil
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        swipeEdit = true
        super.tableView(tableView, willBeginEditingRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didEndEditingRowAtIndexPath: indexPath)
        swipeEdit = false
    }
    
    func removeRowAt(indexPath: NSIndexPath) {
        if indexPath.section == prototypesSection {
            // Delete the selected prototype
            prototypes[indexPath.row].deleteWithCompletionHandler({ (error) -> Void in
                if error != nil {
                    NSLog("prototype.delete: %@", error)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.prototypes.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
            })
        } else if indexPath.section == templatesSection {
            // Delete the selected template
            templates[indexPath.row].deleteWithCompletionHandler({ (error) -> Void in
                if error != nil {
                    NSLog("template.delete: %@", error)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.templates.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
            })
        } else if indexPath.section == datasourcesSection {
            // Delete the selected datasource
            datasources[indexPath.row].deleteWithCompletionHandler({ (error) -> Void in
                if error != nil {
                    NSLog("datasource.delete: %@", error)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.datasources.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    }
                }
            })
        }
    }
}

