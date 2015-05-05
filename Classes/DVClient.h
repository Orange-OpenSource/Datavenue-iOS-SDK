//
//  DVClient.h
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
#import "DVAccount.h"
#import "DVDatasource.h"
#import "DVPrototype.h"
#import "DVTemplate.h"
#import "DVKey.h"
#import "DVStream.h"
#import "DVLocation.h"
#import "DVValue.h"

/**
 * NSError codes specific to Datavenue
 */
typedef NS_ENUM(NSUInteger, DVErrorCode)
{
    /// Returned when Status request returns the KO value
    DVErrorCodeStatusKO = 2000,
    /// All requests will fail with this code when the Key is missing
    DVErrorCodeMissingMasterOrApiKey,
    /// All requests will fail with this code when the Client ID is missing
    DVErrorCodeMissingClientKey,
    /// Error returned when a DVValue cannot serialize its value that must be a valid JSON Object
    DVErrorCodeInvalidJSONObject,
};

/**
 * DVClient is the entrypoint to retrieve, save and delete resources from the Datavenue server.
 */
@interface DVClient : NSObject

/**
 * Orange Partner Client ID
 */
@property (nonatomic, copy) NSString * clientID;

/**
 * Default key used when DVContext.key is not defined.
 * Can be set either to a primary master key, a master key or a api key.
 */
@property (nonatomic, copy) NSString * key;

/** 
 * Base URL to access the Datavenue API. Defaults to production backend.
 */
@property (nonatomic, copy) NSURL * baseURL;

@property (nonatomic, strong) NSURLSession * session;

/**
 * Check the status of the service.
 *
 * @param clientID Orange Partner client ID.
 * @param key Key to use for all requests.
 *
 */
- (instancetype)initWithClientID:(NSString *)clientID key:(NSString *)key;

/**
 * Check the status of the service.
 *
 * @param completionHandler The handler will pass an error if any, or nil on success.
 */
- (void)statusWithCompletionHandler:(void (^)(NSError *))completionHandler;

/**
 * Retrieve a Datavenue account according to its ID.
 *
 * @param accountID The unique ID of the account to retrieve.
 * @param completionHandler The handler will pass an error if any, or the corresponding DVAccount on success.
 */
- (void)accountWithID:(NSString *)accountID completionHandler:(void (^)(DVAccount * account, NSError * error))completionHandler;

/**
 * Retrieve a datasource according to its ID.
 *
 * @param datasourceID The unique ID of the datasource to retrieve.
 * @param completionHandler The handler will pass an error if any, or the corresponding DVDatasource on success.
 */
- (void)datasourceWithID:(NSString *)datasourceID completionHandler:(void (^)(DVDatasource * datasource, NSError * error))completionHandler;

/**
 * Retrieve a prototype according to its ID.
 *
 * @param prototypeID The unique ID of the prototype to retrieve.
 * @param completionHandler The handler will pass an error if any, or the corresponding DVPrototype on success.
 */
- (void)prototypeWithID:(NSString *)prototypeID completionHandler:(void (^)(DVPrototype * prototype, NSError * error))completionHandler;

/**
 * Retrieve a template according to its ID.
 *
 * @param templateID The unique ID of the template to retrieve.
 * @param completionHandler The handler will pass an error if any, or the corresponding DVTemplate on success.
 */
- (void)templateWithID:(NSString *)templateID completionHandler:(void (^)(DVTemplate * template, NSError * error))completionHandler;

/**
 * Retrieve all the templates.
 *
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or an array of DVDatasource on success.
 */
- (void)datasourcesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * datasources, NSError * error))completionHandler;

/**
 * Retrieve all the prototypes.
 *
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or an array of DVPrototype on success.
 */
- (void)prototypesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * prototypes, NSError * error))completionHandler;

/**
 * Retrieve all the templates.
 *
 * @param params Optional request parameters (see request parameters section).
 * @param completionHandler The handler will pass an error if any, or an array of DVDatasource on success.
 */
- (void)templatesWithParams:(NSDictionary*)params completionHandler:(void (^)(NSArray * templates, NSError * error))completionHandler;

@end
