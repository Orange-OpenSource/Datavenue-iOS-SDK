//
//  DetailViewController.swift
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
//  Created by Marc Capdevielle on 30/04/2015.
//  Copyright (c) 2015 Orange. All rights reserved.
//

import UIKit

struct Action {
    var name : String
    var handler : (() -> Void)?
}

class Field {
    var name = ""
    var value = ""
    var readOnly = false
    
    init (name: String, value: String, readOnly: Bool = false) {
        self.name = name
        self.value = value
        self.readOnly = readOnly
    }
}

let fieldsSection = 0
let actionsSection = 1

class DetailViewController : UITableViewController {
    
    var commitModificationsHandler : ((commit: Bool, completionHandler:(() -> Void)) -> Void)?
    var fields = [Field]()
    var actions = [Action]()
    
    func configureWithFields(fields: [Field], commitModificationsHandler:((commit: Bool, completionHandler:(() -> Void)) ->Void)) {
        self.fields = fields
        self.commitModificationsHandler = commitModificationsHandler
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelEdit")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "saveEdit")
    }
    
    func cancelEdit() {
        commitModificationsHandler!(commit: false, completionHandler: {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func saveEdit() {
        commitModificationsHandler!(commit: true, completionHandler: {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == fieldsSection ? fields.count : actions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == fieldsSection {
            let cell = tableView.dequeueReusableCellWithIdentifier("FieldCell", forIndexPath: indexPath) as! FieldViewCell
            cell.configureField(fields[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ActionCell", forIndexPath: indexPath) as! ActionViewCell
            cell.configureAction(actions[indexPath.row])
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}


