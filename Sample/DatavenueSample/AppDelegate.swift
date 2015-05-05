//
//  AppDelegate.swift
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // This info can be retrieved from your Datavenue account.
    // More information at https://datavenue.orange.com
    var defaults = [
        "baseURL": "https://api.orange.com/datavenue/v1/",
        "clientID": "HGvvZGZaitG5MIMiQkPBFAtHZPBDArra",
        "accountID": "537c6fc33bae42d6b9fc6e6ffca1a2da",
        "primaryMasterKey":"ddce1ba92d344e0c8a7dea639f4ecd2b",
        "masterKey": "3b4444cd33704ef6b198446c53dea7e7",
    ]
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Register default settings
        let settings = NSUserDefaults.standardUserDefaults()
        if settings.stringForKey("baseURL") == nil {
            settings.registerDefaults(defaults)
            settings.synchronize()
        }
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        window!.tintColor = UIColor.orangeColor()
        
        return true
    }

    // MARK: - Split view

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController!, ontoPrimaryViewController primaryViewController:UIViewController!) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DatasourceViewController {
                if topAsDetailController.datasource == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }

}

