//
//  DVAPIKey.h
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

@interface DVKey : DVResource

@property (nonatomic, strong) NSString * name;
@property (nonatomic, readonly) NSString * value;
@property (nonatomic, assign) bool status;
@property (nonatomic, strong) NSArray * rights;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSDate * endDate;
@property (nonatomic, readonly) bool isPrimary;

- (DVKey *)initWithName:(NSString *)name rigths:(NSArray *)rights prototypeID:(NSString *)prototypeID client:(DVClient *)client;
- (DVKey *)initWithName:(NSString *)name rigths:(NSArray *)rights datasourceID:(NSString *)datasourceID client:(DVClient *)client;


- (DVKey *)initPrimaryKeyWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath;

- (void)saveWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler;
- (void)regenerateWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler;

@end
