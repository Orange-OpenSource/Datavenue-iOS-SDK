//
//  DVAPIKey.m
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

#import "DVKey.h"
#import "NSString+DVUtils.h"
#import "DVClient+HTTP.h"

@interface DVResource ()

@property (nonatomic, strong) NSString * path;

@end

@interface DVKey ()

@property (nonatomic, strong) NSString * value;
@property (nonatomic, assign) bool isPrimary;

@end

@implementation DVKey

- (DVKey *)initWithName:(NSString *)name rigths:(NSArray *)rights prototypeID:(NSString *)prototypeID client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:[NSString stringWithFormat:@"prototypes/%@/keys", prototypeID]])
    {
        self.name = name;
        self.rights = rights;
    }
    return self;
}

- (DVKey *)initWithName:(NSString *)name rigths:(NSArray *)rights datasourceID:(NSString *)datasourceID client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:[NSString stringWithFormat:@"datasources/%@/keys", datasourceID]])
    {
        self.name = name;
        self.rights = rights;
    }
    return self;
}

- (instancetype)initPrimaryKeyWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.name = jsonData[@"name"];
        self.value = jsonData[@"value"];
        self.path = [basePath stringByAppendingPathComponent:@"pmkey"];
        self.isPrimary = YES;
        self.status = YES;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.name = jsonData[@"name"];
        self.value = jsonData[@"value"];
        self.status = [@"activated" isEqualToString:jsonData[@"status"]];
        self.rights = jsonData[@"rights"];
        self.startDate = [jsonData[@"startDate"] dateUsingISO8601Encoding];
        self.endDate = [jsonData[@"endDate"] dateUsingISO8601Encoding];
    }
    return self;
}

- (NSMutableDictionary *)JSONData
{
    NSMutableDictionary * jsonData = [super JSONData];
    jsonData[@"name"] = self.name;
    if (!self.isPrimary)
    {
        jsonData[@"status"] = self.status ? @"activated" : @"deactivated";
    }
    jsonData[@"rights"] = self.rights;
    if (self.startDate)
    {
        jsonData[@"startDate"] = [NSString iso8601stringFromDate:self.startDate];
    }
    if (self.endDate)
    {
        jsonData[@"endDate"] = [NSString iso8601stringFromDate:self.endDate];
    }
    return jsonData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,name:%@,value:%@,status:%@", super.description, self.name, self.value, self.status ? @"activated" : @"deactivated"];
}

- (void)saveWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler
{
    if (self.ID)
    {
        [self.client putResource:self atPath:self.path params:nil type:[self class] completionHandler:completionHandler];
    }
    else
    {
        [self.client postResource:self atPath:self.basePath params:nil type:[self class] completionHandler:completionHandler];
    }
}

- (void)regenerateWithCompletionHandler:(void (^)(DVKey *, NSError *))completionHandler
{
    [self.client regenerateKey:self completionHandler:completionHandler];
}


@end
