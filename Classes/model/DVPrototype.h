//
//  DVPrototype.h
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
#import "DVResource.h"
#import "DVKey.h"
#import "DVStream.h"

/**
 * An prototype data provider to handle streams of values and keys to control the access to theses streams.
 */
@interface DVPrototype : DVResource

/// The unique name of the resource. Max length: 64
@property (nonatomic, strong) NSString * name;

/// A description for the resource. May be nil. Max length: 256
@property (nonatomic, strong) NSString * adescription;

/// A dictionary of key/value strings
@property (nonatomic, strong) NSDictionary * metadata;

/**
 * Create a new prototype resource. Must be saved with saveWithCompletionHandler:
 *
 * @param name Name of the prototype. Must be unique. Max length: 64.
 * @param client DVClient used for saving/deleting the resource.
 * @return a DVPrototype
 */
- (DVPrototype *)initWithName:(NSString *)name client:(DVClient *)client;

/**
 * Retrieve the keys of the DVPrototype (or DVDatasource) resource.
 * 
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or a list of DVKey on success.
 */
- (void)keysWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray *, NSError *))completionHandler;

/**
 * Retrieve a key using its ID
 *
 * @param keyID The unique key identifier
 * @param completionHandler The handler will pass an error if any, or a DVKey on success.
 */
- (void)keyWithID:(NSString *)keyID completionHandler:(void (^)(DVKey *, NSError *))completionHandler;

/**
 * Retrieve the streams of the DVPrototype (or DVDatasource) resource.
 *
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or a list of DVStream on success.
 */
- (void)streamsWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray *, NSError *))completionHandler;

/**
 * Retrieve a stream using its ID
 *
 * @param streamID The unique key identifier
 * @param completionHandler The handler will pass an error if any, or a DVStream on success.
 */
- (void)streamWithID:(NSString *)streamID completionHandler:(void (^)(DVStream *, NSError *))completionHandler;

/**
 * Update or create the prototype.
 *
 * @param completionHandler The handler will pass on completion a NSError on error, or a new or updated DVPrototype on success.
 */
- (void)saveWithCompletionHandler:(void (^)(DVPrototype *, NSError *))completionHandler;

@end
