//
//  ValuesViewController.swift
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

class ValuesViewController: UITableViewController {
    
    var stream : DVStream?
    var values = [DVValue]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        reloadData()
    }
    
    func reloadData() {
        stream?.valuesWithParams(nil) { (values, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.values = values as! [DVValue]
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count // + (tableView.editing ? 1 : 0) // TODO fix values insertion ?
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ValueCell", forIndexPath: indexPath) as! UITableViewCell
        
        let value = values[indexPath.row];
        cell.textLabel!.text = value.valueAsString()
        cell.detailTextLabel?.text = (value.at != nil ? "At: " + NSString.iso8601stringFromDate(value.at) : "")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let value = values.removeAtIndex(indexPath.row)
            value.deleteWithCompletionHandler() { (error) -> Void in
                if let error = error {
                    NSLog("delete error: %@", error)
                }
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}