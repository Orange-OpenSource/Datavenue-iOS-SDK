//
//  DVTemplate.m
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

#import "DVTemplate.h"
#import "DVClient+HTTP.h"

@interface DVTemplate ()

@property (nonatomic, strong) NSString * prototypeID;

@end

@implementation DVTemplate

- (DVTemplate *)initWithName:(NSString *)name prototypeID:(NSString *)prototypeID client:(DVClient *)client
{
    if (self = [super initWithClient:client basePath:@"templates"])
    {
        self.name = name;
        self.prototypeID = prototypeID;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.name = jsonData[@"name"];
        self.adescription = jsonData[@"description"];
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
    // Only include prototypeID if no ID (on creation of the template)
    if (!self.ID && self.prototypeID)
    {
        jsonData[@"prototypeId"] = self.prototypeID;
    }
    return jsonData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,name:%@,adescription:%@,prototypeID:%@", [super description], _name, _adescription, _prototypeID];
}

- (void)saveWithCompletionHandler:(void (^)(DVTemplate * template, NSError * error))completionHandler
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

@end
