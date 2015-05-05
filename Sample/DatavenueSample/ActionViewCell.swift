//
//  DetailViewCell.swift
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

class ActionViewCell : UITableViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    var action : Action?
    
    func configureAction(action: Action) {
        self.action = action
        button.titleLabel?.text = action.name
    }
    
    @IBAction func didTouchButton(sender: AnyObject) {
        action!.handler!()
    }
}
