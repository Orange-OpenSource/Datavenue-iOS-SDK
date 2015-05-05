//
//  DVresource.m
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
//  Created by Marc Capdevielle on 04/04/2015.
//
//

#import "DVResource.h"
#import "NSString+DVUtils.h"
#import "DVClient+HTTP.h"

@interface DVResource ()

@property (nonatomic, strong) NSString * ID;
@property (nonatomic, strong) NSDate * created;
@property (nonatomic, strong) NSDate * updated;

@property (nonatomic, strong) DVClient * client;
@property (nonatomic, strong) NSString * path;
@property (nonatomic, strong) NSString * basePath;

@end

@implementation DVResource

- (instancetype)initWithClient:(DVClient *)client basePath:(NSString *)basePath
{
    if (self = [super init])
    {
        self.ID = nil;
        self.client = client;
        self.path = basePath;
        self.basePath = basePath;
    }
    return self;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if (self = [super init])
    {
        self.ID = jsonData[@"id"];
        self.created = [jsonData[@"created"] dateUsingISO8601Encoding];
        self.updated = [jsonData[@"updated"] dateUsingISO8601Encoding];
        
        self.client = client;
        self.path = self.ID ? [basePath stringByAppendingPathComponent:self.ID] : basePath;
        self.basePath = basePath;
    }
    return self;
}

- (NSMutableDictionary *)JSONData
{
    return [[NSMutableDictionary alloc] init];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,id:%@", [super description], _ID];
}

- (void)deleteWithCompletionHandler:(void (^)(NSError *))completionHandler
{
    return [self.client deleteResourceAtPath:self.path completionHandler:completionHandler];
}

@end