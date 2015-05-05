//
//  DVDatasource.m
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

#import "DVDatasource.h"
#import "DVClient+HTTP.h"

@interface DVDatasource ()

@property (nonatomic, strong) NSString * templateID;

@end

@implementation DVDatasource

- (DVDatasource *)initWithName:(NSString *)name templateID:(NSString *)templateID client:(DVClient *)client;
{
    if (self = [super initWithClient:client basePath:@"datasources"])
    {
        self.name = name;
        self.templateID = templateID;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if ((self = [super initWithJSON:jsonData error:error client:client basePath:basePath]) && *error == nil)
    {
        self.serial = jsonData[@"serial"];
        NSDictionary * jTemplate = jsonData[@"template"];
        if (jTemplate)
        {
            self.templateID = jTemplate[@"id"];
        }
    }
    return self;
}

- (NSMutableDictionary *)JSONData
{
    NSMutableDictionary * jsonData = [super JSONData];
    if (self.serial)
    {
        jsonData[@"serial"] = self.serial;
    }
    
    // Only set templateId on first post of Datasource (ID == nil)
    if (!self.ID && self.templateID)
    {
        jsonData[@"templateId"] = self.templateID;
    }
    return jsonData;
}

- (void)saveWithCompletionHandler:(void (^)(DVDatasource * datasource, NSError * error))completionHandler
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
