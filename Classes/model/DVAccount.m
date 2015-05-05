//
//  DVAccount.m
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

#import "DVAccount.h"
#import "DVClient+HTTP.h"

@interface DVAccount ()

@property (nonatomic, assign) bool isActivated;

@end

@implementation DVAccount

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.lastname = jsonData[@"lastname"];
        self.firstname = jsonData[@"firstname"];
        self.email = jsonData[@"email"];
        self.isActivated = [@"activated" isEqualToString:jsonData[@"status"]];
        self.primaryMasterKey = [[DVKey alloc] initPrimaryKeyWithJSON:jsonData[@"primaryMasterKey"] error:error client:client basePath:self.path ];
        NSString * masterKeyBasePath = [self.path stringByAppendingPathComponent:@"masterKeys"];
        self.masterKey = [[DVKey alloc] initWithJSON:jsonData[@"masterKey"] error:error client:client basePath:masterKeyBasePath];
    }
    return self;
}

- (NSMutableDictionary *)JSONData;
{
    NSMutableDictionary * jsonData = [super JSONData];
    jsonData[@"lastname"] = self.lastname;
    jsonData[@"firstname"] = self.firstname;
    jsonData[@"email"] = self.email;
    jsonData[@"status"] = self.isActivated ? @"activated" : @"deactivated";
    return jsonData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@lastName:%@,firstName:%@,email:%@,isActivated:%@", [super description], _lastname, _firstname, _email, _isActivated ? @"activated" : @"deactivated"];
}

- (void)primaryMasterKeyWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler
{
    return [self.client getResourceWithID:@"pmkey" atPath:self.path params:nil type:[DVKey class] completionHandler:completionHandler];
}

- (void)masterKeysWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"keys"];
    return [self.client getResourcesAtPath:path params:nil type:[DVKey class] completionHandler:completionHandler];
}

- (void)masterKeyWithID:(NSString *)keyID completionHandler:(void (^)(DVKey *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"keys"];
    return [self.client getResourceWithID:keyID atPath:path params:nil type:[DVKey class] completionHandler:completionHandler];
}

- (void)saveWithCompletionHandler:(void (^)(DVAccount * account, NSError * error))completionHandler
{
    [self.client putResource:self atPath:self.path params:nil type:[DVAccount class] completionHandler:completionHandler];
}


@end
