//
//  NSString+DVUtils.h
//  Pods
//
//  Created by Marc Capdevielle on 08/04/2015.
//
//

#import <Foundation/Foundation.h>

@interface NSString (DVUtils)

- (NSDate *)dateUsingISO8601Encoding;
+ (NSString *)iso8601stringFromDate:(NSDate *)value;

@end
