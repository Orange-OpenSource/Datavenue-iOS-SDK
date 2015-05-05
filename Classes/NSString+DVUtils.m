//
//  NSString+DVUtils.m
//  Pods
//
//  Created by Marc Capdevielle on 08/04/2015.
//
//

#import "NSString+DVUtils.h"

@implementation NSString (DVUtils)

static NSDateFormatter * iso8601Formatter = nil;
static dispatch_once_t onceToken;

- (NSDate *)dateUsingISO8601Encoding
{
    dispatch_once(&onceToken, ^{
        iso8601Formatter = [[NSDateFormatter alloc] init];
        iso8601Formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    
    return [iso8601Formatter dateFromString:self];
}

+ (NSString *)iso8601stringFromDate:(NSDate *)value
{
    dispatch_once(&onceToken, ^{
        iso8601Formatter = [[NSDateFormatter alloc] init];
        iso8601Formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    });
    
    return [iso8601Formatter stringFromDate:value];
}


- (NSString *)URLEscape
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}
@end
