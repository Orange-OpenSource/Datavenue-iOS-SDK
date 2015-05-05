//
//  DVClient+HTTP.h
//  Pods
//
//  Created by Marc Capdevielle on 09/04/2015.
//
//

#import <Foundation/Foundation.h>
#import "DVClient.h"

extern NSString * const DVErrorDomain;

typedef void (^DVResourcesHandler)(NSArray * resources, NSError * error);

typedef void (^DVResourceHandler)(id resource, NSError * error);

typedef void (^DVHandler)(NSError * error);

@interface DVClient (HTTP)

- (NSURLSessionDataTask *) requestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params jsonData:(id)jsonData
                        completionHandler:(void (^)(id jsonData, NSError * error))completionHandler;

- (void)postResource:(DVResource *)resource atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler;
- (void)postResources:(NSArray *)resources atPath:(NSString *)path params:(NSDictionary *)params completionHandler:(DVHandler)completionHandler;
- (void)getResourceWithID:(NSString *)resourceID atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler;
- (void)getResourcesAtPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourcesHandler)completionHandler;
- (void)putResource:(DVResource *)resource atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler;
- (void)deleteResourceAtPath:(NSString *)path completionHandler:(DVHandler)completionHandler;
- (void)regenerateKey:(DVKey *)key completionHandler:(DVResourceHandler)completionHandler;

@end
