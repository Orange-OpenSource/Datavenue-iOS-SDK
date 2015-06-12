//
//  DVClient.m
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

#import "DVClient.h"
#import "DVClient+HTTP.h"
#import "DVResource.h"
#import "DVDatasource.h"

NSString * const DVDatavenuBackendEndpoint = @"https://api.orange.com/datavenue/v1/";

@implementation DVClient

- (instancetype)init
{
    if (self = [super init])
    {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        self.baseURL = [NSURL URLWithString:DVDatavenuBackendEndpoint];
    }
    return self;
}

- (instancetype)initWithClientID:(NSString *)clientID key:(NSString *)key
{
    if (self = [self init])
    {
        self.clientID = clientID;
        self.key = key;
    }
    return self;
}

- (void)statusWithCompletionHandler:(void (^)(NSError * error))completionHandler
{
    [self requestForPath:@"status" method:@"GET" params:nil jsonData:nil
              completionHandler:^(NSDictionary * jsonData, NSError * error)
     {
         if (!error)
         {
             if (![jsonData[@"status"] isEqualToString:@"ok"])
             {
                 error = [[NSError alloc] initWithDomain:DVErrorDomain code:DVErrorCodeStatusKO userInfo:jsonData];
             }
         }
         completionHandler(error);
     }];
}

- (void)accountWithID:(NSString *)accountID completionHandler:(void (^)(DVAccount * account, NSError * error))completionHandler
{
    [self getResourceWithID:accountID atPath:@"accounts" params:nil type:[DVAccount class] completionHandler:completionHandler];
}

- (void)datasourceWithID:(NSString *)datasourceID completionHandler:(void (^)(DVDatasource * datasource, NSError * error))completionHandler
{
    [self getResourceWithID:datasourceID atPath:@"datasources" params:nil type:[DVDatasource class] completionHandler:completionHandler];
}

- (void)prototypeWithID:(NSString *)prototypeID completionHandler:(void (^)(DVPrototype * prototype, NSError * error))completionHandler
{
    [self getResourceWithID:prototypeID atPath:@"prototypes" params:nil type:[DVPrototype class] completionHandler:completionHandler];
}

- (void)templateWithID:(NSString *)templateID completionHandler:(void (^)(DVTemplate * template, NSError * error))completionHandler
{
    [self getResourceWithID:templateID atPath:@"templates" params:nil type:[DVTemplate class] completionHandler:completionHandler];
}

- (void)datasourcesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * datasources, NSError * error))completionHandler
{
    [self getResourcesAtPath:@"datasources" params:params type:[DVDatasource class] completionHandler:completionHandler];
}

- (void)prototypesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * prototypes, NSError * error))completionHandler
{
    [self getResourcesAtPath:@"prototypes" params:params type:[DVPrototype class] completionHandler:completionHandler];
}

- (void)templatesWithParams:(NSDictionary*)params completionHandler:(void (^)(NSArray * templates, NSError * error))completionHandler;
{
    [self getResourcesAtPath:@"templates" params:params type:[DVTemplate class] completionHandler:completionHandler];
}

@end
