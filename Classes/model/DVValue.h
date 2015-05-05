//
//  DVValue.h
//  Pods
//
//  Created by Marc Capdevielle on 07/04/2015.
//
//

#import <Foundation/Foundation.h>
#import "DVResource.h"
#import "DVLocation.h"

/**
 * A single value of a DVStream
 */
@interface DVValue : DVResource

/// The measured value, can be a NSArray, NSDictionary, NSNumber, NSString, NSNull.
@property (nonatomic, strong) id value;

/// The location of the value. Nil if no location.
@property (nonatomic, strong) DVLocation * location;

/// Time when the measure was taken. If nil when saved, the current server time will be used.
@property (nonatomic, strong) NSDate * at;

/// A dictionary to store some metadata associated to the value
@property (nonatomic, strong) NSDictionary * metadata;

/**
 * Convenient method to access the value as a string.
 *
 * @return The value as a string.
 */
- (NSString *)valueAsString;

@end
