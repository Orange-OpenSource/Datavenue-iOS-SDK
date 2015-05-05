//
//  DVAccount.h
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

/**
 * Datavenue account.
 *
 * Gives access to the primary master key, and master keys.
 */
@interface DVAccount : DVResource

/// Last name of the user
@property (nonatomic, strong) NSString * lastname;

/// First name of the user
@property (nonatomic, strong) NSString * firstname;

/// Email of the user. If modified, must be unique.
@property (nonatomic, strong) NSString * email;

/// Status of the account, YES if activated
@property (nonatomic, readonly) bool isActivated;

/// The primary master key
@property (nonatomic, strong) DVKey * primaryMasterKey;

/// The master key
@property (nonatomic, strong) DVKey * masterKey;

/**
 * Retrieve the primary master key (more informations than the one included in DVAccount.primaryMasterKey property).
 *
 * @param completionHandler The handler will pass a NSError if any, or a DVKey of the primary master key on success.
 */
- (void)primaryMasterKeyWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler;

/**
 * Retrieve all the master keys for this DVAccount.
 *
 * @param completionHandler The handler will pass a NSError if any, or an array of DVKey of the master keys on success.
 */
- (void)masterKeysWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler;

/**
 * Retrieve the master key according to its ID.
 *
 * @param keyID the ID of the master key.
 * @param completionHandler The handler will pass a NSError if any, or a DVKey of the master key on success.
 */
- (void)masterKeyWithID:(NSString *)keyID completionHandler:(void (^)(DVKey *, NSError *))completionHandler;

/**
 * Save the modified account informations (lastname, firstname, email or isActivated).
 *
 * @param completionHandler The handler will pass a NSError if any, or a new and updated DVAccount on success.
 */
- (void)saveWithCompletionHandler:(void (^)(DVAccount * account, NSError * error))completionHandler;

@end
