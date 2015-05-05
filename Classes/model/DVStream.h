//
//  DVStream.h
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
#import "DVLocation.h"
#import "DVValue.h"

/**
 * A stream contains a set of values and defines a unit, a location and some metadata.
 */
@interface DVStream : DVResource

/** The name of the stream. Max length: 32 */
@property (nonatomic, strong) NSString * name;

/** The description of the stream. Max length: 256 */
@property (nonatomic, strong) NSString * adescription;

/** Pairs of NSString to store metadata related to the stream */
@property (nonatomic, strong) NSDictionary * metadata;

/** The last value added to the stream */
@property (nonatomic, readonly) id lastValue;

/* The unit name of the values of the stream */
@property (nonatomic, strong) NSString * unitName;

/** The unit symbol of the values of the stream */
@property (nonatomic, strong) NSString * unitSymbol;

/** Location of the stream */
@property (nonatomic, strong) DVLocation * location;

/**
 * New DVStream for a prototype. Must be saved with saveWithCompletionHandler:.
 *
 * @param name THe name for the stream. Must be unique to the prototype. Max length: 32.
 * @param prototypeID The DVPrototype to associate the stream to.
 * @param client DVClient used for saving/deleting the stream.
 * @return a DVStream that can be saved with saveWithCompletionHandler:.
 */
- (DVStream *)initWithName:(NSString *)name prototypeID:(NSString *)prototypeID client:(DVClient *)client;

/**
 * New DVStream for a datasource. Must be saved with saveWithCompletionHandler:.
 *
 * @param name THe name for the stream. Must be unique to the datasouce. Max length: 32.
 * @param datasourceID The DVPrototype to associate the stream to.
 * @param client DVClient used for saving/deleting the stream.
 * @return a DVStream that can be saved with saveWithCompletionHandler:.
 */
- (DVStream *)initWithName:(NSString *)name datasourceID:(NSString *)datasourceID  client:(DVClient *)client;

/**
 * Create or update the DVStream.
 *
 * @param completionHandler The handler will pass an NSError if any, or a DVStream on success.
 */
- (void)saveWithCompletionHandler:(void (^)(DVStream * stream, NSError * error))completionHandler;

/**
 * Add values to the DVStream.
 *
 * @param values Values can be either some DVValue or any kind of JSON Object values.
 * @param completionHandler The handler will pass an error if any, or nil on success.
 */
- (void)appendValues:(NSArray *)values completionHandler:(void (^)(NSError * error))completionHandler;

/**
 * Retreive some values from the stream.
 *
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or a list of DVValue on success.
 */
- (void)valuesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * values, NSError * error))completionHandler;

/**
 * Retreive a value from the stream by its unique ID.
 *
 * @param ID Identifier of the value resource.
 * @param completionHandler The handler will pass an error if any, or a list of DVValue on success.
 */
- (void)valueWithID:(NSString *)ID completionHandler:(void (^)(DVValue * value, NSError * error))completionHandler;

/**
 * Remove all values of the stream
 *
 * @param completionHandler The handler will pass an error if any, or nil on success.
 */
- (void)removeAllValuesWithCompletionHandler:(void (^)(NSError * error))completionHandler;

@end
