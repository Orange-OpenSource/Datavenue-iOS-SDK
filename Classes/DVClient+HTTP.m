//
//  DVClient+HTTP.m
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

#import "DVClient+HTTP.h"
#import "DVDatasource.h"
#import "DVResource.h"

NSString * const DVErrorDomain = @"com.orange.datavenue.client";

NSString * const DVApiHeaderKey = @"X-ISS-Key";
NSString * const DVOrangePartnerKeyHeaderKey = @"X-OAPI-Key";

@implementation DVClient (HTTP)

#pragma mark - Private methods

- (NSURL *)urlWithPath:(NSString *)path params:(NSDictionary *)params
{
    // Append params to path
    if (params && params.count > 0)
    {
        NSMutableString * buff = [[NSMutableString alloc] init];
        for (NSString * key in params)
        {
            [buff appendString:(buff.length == 0) ? @"?" : @"&"];
            [buff appendFormat:@"%@=%@", key, params[key]];
        }
        path = [path stringByAppendingString:buff];
    }
    // Prepend baseURL
    return [NSURL URLWithString:path relativeToURL:self.baseURL];
}

- (BOOL)validStatusCode:(NSInteger)statusCode
{
    return statusCode == 200 || statusCode == 201 || statusCode == 202 || statusCode == 204;
}

- (NSURLSessionDataTask *) requestForPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params jsonData:(id)jsonData
                        completionHandler:(void (^)(id jsonData, NSError * error))completionHandler
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:[self urlWithPath:path params:params]];
    request.HTTPMethod = method;
    
    // Set Datavenue API key
    if (!self.key)
    {
        completionHandler(nil, [[NSError alloc] initWithDomain:DVErrorDomain code:DVErrorCodeMissingMasterOrApiKey userInfo:nil]);
        return nil;
    }
    [request setValue:self.key forHTTPHeaderField:DVApiHeaderKey];

    // Set Orange Partner API key
    if (!self.clientID)
    {
        completionHandler(nil, [[NSError alloc] initWithDomain:DVErrorDomain code:DVErrorCodeMissingClientKey userInfo:nil]);
        return nil;
    }
    [request setValue:self.clientID forHTTPHeaderField:DVOrangePartnerKeyHeaderKey];
    
    // Set JSON body
    if (jsonData)
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSError * error;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
        if (error)
        {
            completionHandler(nil, error);
            return nil;
        }
    }
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request
                                                  completionHandler:^(NSData * data, NSURLResponse * response, NSError * error)
                                   {
                                       id jsonData = nil;
                                       if (!error)
                                       {
                                           if (response) {
                                               if (data)
                                               {
                                                   jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                                   removeAllDictNulls(jsonData);
                                               }
                                               NSHTTPURLResponse * httpresponse = (NSHTTPURLResponse *)response;
                                               if (![self validStatusCode:httpresponse.statusCode])
                                               {
                                                   // On error, embbed JSON data as error info
                                                   error = [NSError errorWithDomain:DVErrorDomain code:httpresponse.statusCode userInfo:jsonData];
                                                   jsonData = nil;
                                               }
                                               else
                                               {
                                                   // When status code is valid, ignore parser errors (because there is no data)
                                                   error = nil;
                                               }
                                           } else {
                                               // Should never happen (error and response being nil)
                                               error = [NSError errorWithDomain:DVErrorDomain code:1 userInfo:nil];
                                           }
                                       }
                                       completionHandler(jsonData, error);
                                   }];
    [task resume];
    return task;
}

#pragma mark - Request methods

- (void)postResource:(DVResource *)resource atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler
{
    [self requestForPath:path method:@"POST" params:params jsonData:[resource JSONData] completionHandler:^(id jsonData, NSError *error) {
        DVResource * resource = nil;
        if (!error && jsonData)
        {
            resource = [[type alloc] initWithJSON:jsonData error:&error client:self basePath:path];
            if (error) // json parsing error, remove resource
            {
                resource = nil;
            }
        }
        completionHandler(resource, error);
    }];
}

- (void)postResources:(NSArray *)resources atPath:(NSString *)path params:(NSDictionary *)params completionHandler:(DVHandler)completionHandler
{
    NSMutableArray * jResources = [[NSMutableArray alloc] init];
    for (id resource in resources)
    {
        if ([resource isKindOfClass:[DVResource class]])
        {
            [jResources addObject:[resource JSONData]];
        }
        else if ([NSJSONSerialization isValidJSONObject:resources])
        {
            [jResources addObject:@{@"value":resource}];
        }
        else
        {
            completionHandler([NSError errorWithDomain:DVErrorDomain code:DVErrorCodeInvalidJSONObject userInfo:nil]);
            break;
        }
    }
    [self requestForPath:path method:@"POST" params:params jsonData:jResources completionHandler:^(id jsonData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)putResource:(DVResource *)resource atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler
{
    [self requestForPath:path method:@"PUT" params:params jsonData:[resource JSONData] completionHandler:^(id jsonData, NSError *error) {
        DVResource * updatedResource = nil;
        if (!error)
        {
            if (jsonData)
            {
                updatedResource = [[type alloc] initWithJSON:jsonData error:&error client:self basePath:path];
                if (error) // json parsing error, remove resource
                {
                    updatedResource = nil;
                }
            } else {
                // when no JSON withour error (204 No Content), reuse previous ressource
                updatedResource = resource;
            }
        }
        completionHandler(updatedResource, error);
    }];
}

- (void)getResourceWithID:(NSString *)resourceID atPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourceHandler)completionHandler
{
    NSString * urlPath = [path stringByAppendingPathComponent:resourceID];
    [self requestForPath:urlPath method:@"GET" params:params jsonData:nil completionHandler:^(id jsonData, NSError *error) {
        DVResource * resource = nil;
        if (!error && jsonData)
        {
            resource = [[type alloc] initWithJSON:jsonData error:&error client:self basePath:path];
            if (error) // json parsing error, remove resource
            {
                resource = nil;
            }
        }
        completionHandler(resource, error);
    }];
}

- (void)getResourcesAtPath:(NSString *)path params:(NSDictionary *)params type:(Class)type completionHandler:(DVResourcesHandler)completionHandler
{
    [self requestForPath:path method:@"GET" params:params jsonData:nil completionHandler:^(id jsonData, NSError *error) {
        NSMutableArray * resources = nil;
        if (!error)
        {
            resources = [[NSMutableArray alloc] init];
            if (jsonData)
            {
                for (NSDictionary * jResource in jsonData)
                {
                    DVResource * resource = [[type alloc] initWithJSON:jResource error:&error client:self basePath:path];
                    if (error) // json parsing error, remove resources
                    {
                        resources = nil;
                        break;
                    }
                    [resources addObject:resource];
                }
            }
        }
        completionHandler(resources, error);
    }];
}

- (void)deleteResourceAtPath:(NSString *)path completionHandler:(DVHandler)completionHandler
{
    [self requestForPath:path method:@"DELETE" params:nil jsonData:nil completionHandler:^(id jsonData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)regenerateKey:(DVKey *)key completionHandler:(DVResourceHandler)completionHandler
{
    NSString * path = [key.path stringByAppendingString:@"/regenerate"];
    [self requestForPath:path method:@"GET" params:nil jsonData:nil completionHandler:^(id jsonData, NSError *error) {
        DVKey * newKey = nil;
        if (!error && jsonData)
        {
            newKey = [[DVKey alloc] initWithJSON:jsonData error:&error client:self basePath:key.basePath];
            if (error) // json parsing error, remove resource
            {
                newKey = nil;
            }
        }
        completionHandler(key, error);
    }];
}

// Remove all NSNull from NSMutableDictionary...
void removeAllDictNulls(id jsonData)
{
    if ([jsonData isKindOfClass:[NSMutableDictionary class]]) {
        for (id key in [jsonData allKeys])
        {
            id value = jsonData[key];
            if (value == [NSNull null])
            {
                [jsonData removeObjectForKey:key];
            }
            else
            {
                removeAllDictNulls(value);
            }
        }
    }
    else if ([jsonData isKindOfClass:[NSMutableArray class]])
    {
        for (id value in jsonData)
        {
            removeAllDictNulls(value);
        }
    }
}

@end
