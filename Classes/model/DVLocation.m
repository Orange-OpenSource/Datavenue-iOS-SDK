//
//  DVLocation.m
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

#import "DVLocation.h"
#import "NSString+DVUtils.h"

@implementation DVLocation

- (instancetype)initWithLatitude:(double)latitude longitude:(double)longitude;
{
    if (self = [super init])
    {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

- (instancetype)initWithJSON:(NSArray *)jsonData error:(NSError **)error
{
    if (self = [super init])
    {
        self.latitude = [jsonData[1] doubleValue];
        self.longitude = [jsonData[0] doubleValue];
    }
    return self;
}

- (NSArray *)JSONData
{
    return @[@(self.latitude), @(self.longitude)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"location:longitude:%f,latitude:%f", _longitude, _latitude];
}

@end
