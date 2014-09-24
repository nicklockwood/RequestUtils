//
//  RequestUtils.h
//
//  Version 1.1
//
//  Created by Nick Lockwood on 11/01/2012.
//  Copyright (C) 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/RequestUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <Foundation/Foundation.h>


#ifndef REQUEST_UTILS
#define REQUEST UTILS

static NSString *const URLSchemeComponent = @"scheme";
static NSString *const URLHostComponent = @"host";
static NSString *const URLPortComponent = @"port";
static NSString *const URLUserComponent = @"user";
static NSString *const URLPasswordComponent = @"password";
static NSString *const URLPathComponent = @"path";
static NSString *const URLParameterStringComponent = @"parameterString";
static NSString *const URLQueryComponent = @"query";
static NSString *const URLFragmentComponent = @"fragment";

#endif


typedef NS_ENUM(NSUInteger, URLQueryOptions)
{
    //mutually exclusive
    URLQueryOptionDefault = 0,
    URLQueryOptionKeepLastValue,
    URLQueryOptionKeepFirstValue,
    URLQueryOptionUseArrays,
    URLQueryOptionAlwaysUseArrays,
    
    //can be |ed with other values
    URLQueryOptionUseArraySyntax = 8,
    URLQueryOptionSortKeys = 16
};


@interface NSString (RequestUtils)

#pragma mark URLEncoding

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString:(BOOL)decodePlusAsSpace;

#pragma mark URL path extension

- (NSString *)stringByAppendingURLPathExtension:(NSString *)extension;
- (NSString *)stringByDeletingURLPathExtension;
- (NSString *)URLPathExtension;

#pragma mark URL paths

- (NSString *)stringByAppendingURLPathComponent:(NSString *)str;
- (NSString *)stringByDeletingLastURLPathComponent;
- (NSString *)lastURLPathComponent;

#pragma mark URL query

+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters;
+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters options:(URLQueryOptions)options;

- (NSString *)URLQuery;
- (NSString *)stringByDeletingURLQuery;
- (NSString *)stringByReplacingURLQueryWithQuery:(NSString *)query;
- (NSString *)stringByAppendingURLQuery:(NSString *)query;
- (NSString *)stringByMergingURLQuery:(NSString *)query;
- (NSString *)stringByMergingURLQuery:(NSString *)query options:(URLQueryOptions)options;
- (NSDictionary *)URLQueryParameters;
- (NSDictionary *)URLQueryParametersWithOptions:(URLQueryOptions)options;

#pragma mark URL fragment ID

- (NSString *)URLFragment;
- (NSString *)stringByDeletingURLFragment;
- (NSString *)stringByAppendingURLFragment:(NSString *)fragment;

#pragma mark URL conversion

- (NSURL *)URLValue;
- (NSURL *)URLValueRelativeToURL:(NSURL *)baseURL;

#pragma mark base 64

- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;

@end


@interface NSURL (RequestUtils)

+ (instancetype)URLWithComponents:(NSDictionary *)components;
- (NSDictionary *)components;

- (NSURL *)URLWithScheme:(NSString *)scheme;
- (NSURL *)URLWithHost:(NSString *)host;
- (NSURL *)URLWithPort:(NSString *)port;
- (NSURL *)URLWithUser:(NSString *)user;
- (NSURL *)URLWithPassword:(NSString *)password;
- (NSURL *)URLWithPath:(NSString *)path;
- (NSURL *)URLWithParameterString:(NSString *)parameterString;
- (NSURL *)URLWithQuery:(NSString *)query;
- (NSURL *)URLWithFragment:(NSString *)fragment;

@end


@interface NSURLRequest (RequestUtils)

+ (instancetype)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary *)parameters;
+ (instancetype)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters;
+ (instancetype)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters;

- (NSDictionary *)GETParameters;
- (NSDictionary *)POSTParameters;
- (NSString *)HTTPBasicAuthUser;
- (NSString *)HTTPBasicAuthPassword;

@end


@interface NSMutableURLRequest (RequestUtils)

- (void)setGETParameters:(NSDictionary *)parameters;
- (void)setGETParameters:(NSDictionary *)parameters options:(URLQueryOptions)options;
- (void)addGETParameters:(NSDictionary *)parameters options:(URLQueryOptions)options;
- (void)setPOSTParameters:(NSDictionary *)parameters;
- (void)setPOSTParameters:(NSDictionary *)parameters options:(URLQueryOptions)options;
- (void)addPOSTParameters:(NSDictionary *)parameters options:(URLQueryOptions)options;
- (void)setHTTPBasicAuthUser:(NSString *)user password:(NSString *)password;

@end
