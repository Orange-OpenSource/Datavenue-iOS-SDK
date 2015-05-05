//
//  DVResource.h
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
//  Created by Marc Capdevielle on 04/04/2015.
//
//

#import <Foundation/Foundation.h>

@class DVClient;

/**
 * The base class of all retrieve resources.
 */
@interface DVResource : NSObject

/**
 * All retrived resources have a unique ID.
 */
@property (nonatomic, readonly) NSString * ID;

/**
 * Time of resource creation.
 */
@property (nonatomic, readonly) NSDate * created;

/**
 * Time of last resource modification.
 */
@property (nonatomic, readonly) NSDate * updated;

/**
 * DVClient used to request the resource
 */
@property (nonatomic, readonly) DVClient * client;

/**
 * Basepath of the resource
 */
@property (nonatomic, readonly) NSString * basePath;

/**
 * Path to the resource
 */
@property (nonatomic, readonly) NSString * path;

/**
 * Create a resource localy.
 *
 * @param client DVClient used for saving/deleting the resource.
 * @param basePath base path to the resource.
 */
- (instancetype)initWithClient:(DVClient *)client basePath:(NSString *)basePath;

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath;

- (NSMutableDictionary *)JSONData;

/**
 * Delete the resource from the server.
 *
 * @param completionHandler The handler will pass on completion an NSError on error, or nil on success.
 */
- (void)deleteWithCompletionHandler:(void (^)(NSError *))completionHandler;

@end
