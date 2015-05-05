//
//  DVPrototype.m
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

#import "DVPrototype.h"
#import "DVClient+HTTP.h"

@implementation DVPrototype

- (DVPrototype *)initWithName:(NSString *)name client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:@"prototypes"])
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
    return jsonData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,name:%@,adescription:%@", [super description], _name, _adescription];
}

- (void)keysWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"keys"];
    return [self.client getResourcesAtPath:path params:params type:[DVKey class] completionHandler:completionHandler];
}

- (void)keyWithID:(NSString *)keyID completionHandler:(void (^)(DVKey *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"keys"];
    return [self.client getResourceWithID:keyID atPath:path params:nil type:[DVKey class] completionHandler:completionHandler];
}

- (void)streamsWithParams:(NSDictionary *)params completionHandler:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"streams"];
    return [self.client getResourcesAtPath:path params:params type:[DVStream class] completionHandler:completionHandler];
}

- (void)streamWithID:(NSString *)streamID completionHandler:(void (^)(DVStream *, NSError *))completionHandler
{
    NSString * path = [self.path stringByAppendingPathComponent:@"streams"];
    return [self.client getResourceWithID:streamID atPath:path params:nil type:[DVStream class] completionHandler:completionHandler];
}

- (void)saveWithCompletionHandler:(void (^)(DVPrototype *, NSError *))completionHandler
{
    if (self.ID)
    {
        [self.client putResource:self atPath:self.path params:nil type:[self class] completionHandler:completionHandler];
    }
    else
    {
        [self.client postResource:self atPath:self.path params:nil type:[self class] completionHandler:completionHandler];
    }
}

@end
