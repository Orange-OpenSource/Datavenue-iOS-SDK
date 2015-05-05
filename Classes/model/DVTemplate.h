//
//  DVTemplate.h
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
//  Created by Marc Capdevielle on 03/04/2015.
//
//

#import <Foundation/Foundation.h>
#import "DVPrototype.h"

/**
 * A template is a snapshot of a prototype at a given time.
 * It can be used to instanciate new datasources.
 */
@interface DVTemplate : DVResource

/// Name of the template. Must be unique. Max length: 64
@property (nonatomic, strong) NSString * name;

/// Description of the template. May be nil. Max length: 256
@property (nonatomic, strong) NSString * adescription;

/// ID of the prototype that was used to create the template
@property (nonatomic, readonly) NSString * prototypeID;

/**
 * Create a new template for an existing prototype. Must be saved with saveWithCompletionHandler:
 *
 * @param name Name of the template. Must be unique.
 * @param prototypeID ID of the prototype to snapshot.
 * @param client DVClient used for saving/deleting the resource.
 * @return a DVTemplate
 */
- (DVTemplate *)initWithName:(NSString *)name prototypeID:(NSString *)prototypeID client:(DVClient *)client;

/**
 * Create or update the DVTemplate.
 *
 * @param completionHandler The handler will pass an NSError if any, or a new or updated DVTemplate on success.
 */
- (void)saveWithCompletionHandler:(void (^)(DVTemplate * template, NSError * error))completionHandler;

@end
