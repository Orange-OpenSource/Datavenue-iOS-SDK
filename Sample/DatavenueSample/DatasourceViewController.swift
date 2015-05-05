//
//  AccountViewController.swift
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

let keysSection = 0
let streamsSection = 1

class DatasourceViewController: UITableViewController {
    
    var datasource : DVPrototype? // either a DVPrototype or a DVDatasource
        
    var keys = [DVKey]()
    var streams = [DVStream]()
    
    var swipeEdit = false
    var insertedNewCell = false
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        reloadData()
    }
        
    func reloadData() {
        datasource?.keysWithParams(nil) { (keys, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.keys = keys as! [DVKey]
                    self.tableView.reloadSections(NSIndexSet(index: keysSection), withRowAnimation: .Automatic)
                }
            }
        }
        
        datasource?.streamsWithParams(nil) { (streams, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.streams = streams as! [DVStream]
                    self.tableView.reloadSections(NSIndexSet(index: streamsSection), withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showValues" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! ValuesViewController
                let stream = streams[indexPath.row]
                controller.stream = stream
                controller.navigationItem.title = stream.name;
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == keysSection ? "Keys" : "Streams"
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case keysSection: return keys.count + (tableView.editing && !swipeEdit ? 1 : 0)
        case streamsSection: return streams.count + (tableView.editing && !swipeEdit ? 1 : 0)
        default: return 0
        }
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if !swipeEdit {
            let indexPaths = [NSIndexPath(forRow:keys.count, inSection:keysSection), NSIndexPath(forRow: streams.count, inSection: streamsSection)]
            if editing {
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                insertedNewCell = true
            } else if insertedNewCell {
                insertedNewCell = false
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell

        if indexPath.section == keysSection {
            cell = tableView.dequeueReusableCellWithIdentifier("KeyCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.row < keys.count {
                cell.textLabel!.text =  keys[indexPath.row].name
                cell.accessoryType = .DetailButton
                cell.selectionStyle = .None
            } else {
                cell.textLabel!.text = "Add new key"
                cell.accessoryType = .None
                cell.selectionStyle = .Default
            }
        } else { // Streams
            cell = tableView.dequeueReusableCellWithIdentifier("StreamCell", forIndexPath: indexPath) as! UITableViewCell
            if indexPath.row < streams.count {
                cell.textLabel!.text = streams[indexPath.row].name
                cell.accessoryType = .DetailDisclosureButton
            } else {
                cell.textLabel!.text = "Add new Stream"
                cell.accessoryType = .None
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == keysSection && indexPath.row == keys.count {
            return  .Insert;
        }
        if indexPath.section == streamsSection && indexPath.row == streams.count {
            return  .Insert;
        }
        return .Delete;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if indexPath.section == keysSection {
                keys[indexPath.row].deleteWithCompletionHandler({ (error) -> Void in
                    if error != nil {
                        NSLog("key.delete: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            let removed = self.keys.removeAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            } else if indexPath.section == streamsSection {
                streams[indexPath.row].deleteWithCompletionHandler({ (error) -> Void in
                    if error != nil {
                        NSLog("stream.delete: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.streams.removeAtIndex(indexPath.row)
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            }
        } else if editingStyle == .Insert {
            if indexPath.section == keysSection {
                let key : DVKey
                if datasource!.isKindOfClass(DVDatasource) {
                    key = DVKey(name: "key ".randomEnd(4), rigths:["GET", "POST", "PUT", "DELETE"], datasourceID: datasource!.ID, client: datasource!.client)
                } else { // it's a prototype
                    key = DVKey(name: "key ".randomEnd(4), rigths:["GET", "POST", "PUT", "DELETE"], prototypeID: datasource!.ID, client: datasource!.client)
                }
                key.saveWithCompletionHandler({ (key, error) -> Void in
                    if error != nil {
                        NSLog("key.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.keys.append(key)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            } else if indexPath.section == streamsSection {
                let stream : DVStream
                if datasource!.isKindOfClass(DVDatasource) {
                    stream = DVStream(name: "stream ".randomEnd(4), datasourceID: datasource!.ID, client: datasource!.client)
                } else { // it's a prototype
                    stream = DVStream(name: "stream ".randomEnd(4), prototypeID: datasource!.ID, client: datasource!.client)
                }
                stream.saveWithCompletionHandler({ (stream, error) -> Void in
                    if error != nil {
                        NSLog("stream.save: %@", error)
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.streams.append(stream)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                        }
                    }
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        swipeEdit = true
        super.tableView(tableView, willBeginEditingRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didEndEditingRowAtIndexPath: indexPath)
        swipeEdit = false
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let navDetailViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NavDetailViewController") as! UINavigationController
        let detailViewController = navDetailViewController.topViewController as! DetailViewController
        
        let fields : [Field]
        let actions : [Action]
        let commitHandler : (commit: Bool, commitModificationsHander: () -> Void) -> Void
        weak var weakDetailVC = detailViewController

        if indexPath.section == keysSection {
            let key = keys[indexPath.row]
            
            fields = [
                Field(name: "ID", value: key.ID, readOnly: true),
                Field(name: "name", value: key.name),
                Field(name: "value", value: key.value, readOnly: true),
                Field(name: "rights", value: join(",", key.rights as! [String])),
                Field(name: "status", value: key.status ? "activated" : "deactivated"),
                Field(name: "start date", value: key.startDate != nil ? NSString.iso8601stringFromDate(key.startDate) : ""),
                Field(name: "end date", value: key.endDate != nil ? NSString.iso8601stringFromDate(key.endDate) : ""),
            ]

            commitHandler = { (commit, completion) in
                if commit {
                    key.name = fields[1].value
                    key.rights = fields[3].value.componentsSeparatedByString(",")
                    key.status = fields[4].value == "activated"
                    key.startDate = NSString(string:fields[5].value).dateUsingISO8601Encoding()
                    key.endDate = NSString(string:fields[6].value).dateUsingISO8601Encoding()
                    
                    key.saveWithCompletionHandler({ (key, error) -> Void in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.keys[indexPath.row] = key
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
            let stream = streams[indexPath.row]
            
            fields = [
                Field(name: "ID", value: stream.ID, readOnly: true),
                Field(name: "name", value: stream.name),
                Field(name: "description", value: stream.adescription),
                Field(name: "unit name", value: stream.unitName ?? ""),
                Field(name: "unit symbol", value: stream.unitSymbol ?? ""),
                Field(name: "latitude", value: stream.location?.latitude.description ?? ""),
                Field(name: "longitude", value: stream.location?.longitude.description ?? ""),
            ]
            
            commitHandler = { (commit, completion) in
                if commit {
                    stream.name = fields[1].value
                    stream.adescription = fields[2].value
                    stream.unitName = fields[3].value
                    stream.unitSymbol = fields[4].value
                    if fields[5].value != "" && fields[6].value != "" {
                        stream.location = DVLocation(latitude: (fields[5].value as NSString).doubleValue, longitude: (fields[6].value as NSString).doubleValue)
                    }
                    
                    stream.saveWithCompletionHandler({ (stream, error) in
                        if error == nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.streams[indexPath.row] = stream
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
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteAction = UITableViewRowAction(style: .Normal, title: "Delete") { (error, indePath) -> Void in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        }
        deleteAction.backgroundColor = UIColor.redColor()
        
        if indexPath.section == keysSection {
            let regenerateAction = UITableViewRowAction(style: .Normal, title: "Regenerate") { (rowAction, indexPath) -> Void in
                self.keys[indexPath.row].regenerateWithCompletionHandler() { (key, error) -> Void in
                    if error == nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.keys[indexPath.row] = key
                            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        }
                    } else {
                        println("key.regenerate: error: ", error)
                    }
                }
            }
            return swipeEdit ? [deleteAction, regenerateAction] : [deleteAction]
        } else if indexPath.section == streamsSection {
            let randomValuesAction = UITableViewRowAction(style: .Normal, title: "Add random values") { (rowAction, indexPath) -> Void in
                var randomValues = [NSNumber]()
                for _ in 0..<10 {
                    randomValues.append(NSNumber(unsignedInt: arc4random()))
                }
                self.streams[indexPath.row].appendValues(randomValues, completionHandler: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                })
            }
            return swipeEdit ? [deleteAction, randomValuesAction] : [deleteAction]
        }
        
        return []
    }

}