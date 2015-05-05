//
//  DVStream.m
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

#import "DVStream.h"
#import "DVClient+HTTP.h"

@interface DVStream ()

@property (nonatomic, strong) id lastValue;

@end

@implementation DVStream


- (DVStream *)initWithName:(NSString *)name prototypeID:(NSString *)prototypeID client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:[NSString stringWithFormat:@"prototypes/%@/streams", prototypeID]])
    {
        self.name = name;
    }
    return self;
}

- (DVStream *)initWithName:(NSString *)name datasourceID:(NSString *)datasourceID  client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:[NSString stringWithFormat:@"datasources/%@/streams", datasourceID]])
    {
        self.name = name;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.name = jsonData[@"name"];
        self.adescription = jsonData[@"description"];
        self.metadata = jsonData[@"metadata"];
        self.lastValue = jsonData[@"lastValue"];
        NSDictionary * jUnit = jsonData[@"unit"];
        self.unitName = jUnit[@"name"];
        self.unitSymbol = jUnit[@"symbol"];
        NSArray * jLocation = jsonData[@"location"];
        if (jLocation)
        {
            self.location = [[DVLocation alloc] initWithJSON:jLocation error:error];
        }
    }
    return self;
}

- (NSMutableDictionary *)JSONData
{
    NSMutableDictionary * jsonData = [super JSONData];
    jsonData[@"name"] = self.name;
    if (self.adescription)
    {
        jsonData[@"description"] = self.adescription;
    }
    if (self.metadata)
    {
        jsonData[@"metadata"] = self.metadata;
    }
    if (self.unitName && self.unitSymbol)
    {
        jsonData[@"unit"] = @{@"name": self.unitName, @"symbol":self.unitSymbol};
    }
    if (self.location)
    {
        jsonData[@"location"] = [self.location JSONData];
    }
    return jsonData;
}

- (void)saveWithCompletionHandler:(void (^)(DVStream * stream, NSError * error))completionHandler
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

- (void)appendValues:(NSArray *)values completionHandler:(void (^)(NSError * error))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"values"];
    [self.client postResources:values atPath:path params:nil completionHandler:completionHandler];
}

- (void)valuesWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray * values, NSError * error))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"values"];
    [self.client getResourcesAtPath:path params:params type:[DVValue class] completionHandler:completionHandler];
}

- (void)valueWithID:(NSString *)ID completionHandler:(void (^)(DVValue * value, NSError * error))completionHandler
{
    NSString * path = [self.path stringByAppendingString:@"values"];
    [self.client getResourceWithID:ID atPath:path params:nil type:[DVValue class] completionHandler:completionHandler];
}

- (void)removeAllValuesWithCompletionHandler:(void (^)(NSError * error))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"values"];
    [self.client deleteResourceAtPath:path completionHandler:completionHandler];
}

@end
