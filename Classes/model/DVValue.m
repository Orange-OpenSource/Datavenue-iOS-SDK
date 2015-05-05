//
//  DVValue.m
//  Pods
//
//  Created by Marc Capdevielle on 07/04/2015.
//
//

#import "DVValue.h"
#import "NSString+DVUtils.h"
#import "DVClient+HTTP.h"

@implementation DVValue

- (instancetype)initWithJSON:(NSDictionary *)jsonData error:(NSError **)error client:(DVClient *)client basePath:(NSString *)basePath
{
    if (self = [super initWithJSON:jsonData error:error client:client basePath:basePath])
    {
        self.value = jsonData[@"value"];
        if (jsonData[@"location"])
        {
            self.location = [[DVLocation alloc] initWithJSON:jsonData[@"location"] error:error];
        }
        self.at = [jsonData[@"at"] dateUsingISO8601Encoding];
        self.metadata = jsonData[@"metadata"];
    }
    return self;
}

- (NSMutableDictionary *)JSONData
{
    NSMutableDictionary * jsonData = [super JSONData];
    jsonData[@"value"] = self.value;
    if (self.location)
    {
        jsonData[@"location"] = [self.location JSONData];
    }
    if (self.at)
    {
        jsonData[@"at"] = self.at;
    }
    if (self.metadata)
    {
        jsonData[@"metadata"] = self.metadata;
    }
    return jsonData;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@,value:%@location:%@,at:%@,metadata:%@", [super description], _value, [_location description], _at, _metadata];
}

- (NSString *)valueAsString
{
    return [NSString stringWithFormat:@"%@", self.value];
}

@end
