//
//  DVDatasource.h
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
 * An data provider to handle streams of values and keys to control the access to theses streams.
 * A datasource can be either created from a template (see DVTemplate) or just by creating it empty and saving it.
 */
@interface DVDatasource : DVPrototype

/// ID of the template that was used to generate this datasource. May be nil if the datasource was not created from a template.
@property (nonatomic, readonly) NSString * templateID;

/// Unique identifier for the datasource. Max length: 64. May be nil
@property (nonatomic, strong) NSString * serial;

/**
 * Create a new datasource. Must be saved with saveWithCompletionHandler:
 *
 * @param name Name of the datasource. Must be unique. Max length: 64.
 * @param templateID ID of the template to use as model. May be nil to create an empty datasource.
 * @param client DVClient used for saving/deleting the resource.
 * @return a DVDatasource
 */
- (DVDatasource *)initWithName:(NSString *)name templateID:(NSString *)templateID client:(DVClient *)client;

/**
 * Update or create the datasource.
 *
 * @param completionHandler The handler will pass on completion a NSError on error, or a new or updated DVDatasource on success.
 */
- (void)saveWithCompletionHandler:(void (^)(DVDatasource * datasource, NSError * error))completionHandler;

@end
