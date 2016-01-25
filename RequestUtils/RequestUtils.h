//
//  RequestUtils.h
//
//  Version 1.1.2
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


NS_ASSUME_NONNULL_BEGIN


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

@property (nonatomic, readonly) NSString *URLEncodedString;
@property (nonatomic, readonly) NSString *URLDecodedString;

- (NSString *)URLDecodedString:(BOOL)decodePlusAsSpace;

#pragma mark URL path extension

@property (nonatomic, readonly) NSString *stringByDeletingURLPathExtension;
@property (nonatomic, readonly) NSString *URLPathExtension;

- (NSString *)stringByAppendingURLPathExtension:(NSString *)extension;

#pragma mark URL paths

@property (nonatomic, readonly) NSString *stringByDeletingLastURLPathComponent;
@property (nonatomic, readonly) NSString *lastURLPathComponent;

- (NSString *)stringByAppendingURLPathComponent:(NSString *)str;

#pragma mark URL query

+ (NSString *)URLQueryWithParameters:(NSDictionary<NSString *, id> *)parameters;
+ (NSString *)URLQueryWithParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options;

@property (nonatomic, readonly) NSString *URLQuery;
@property (nonatomic, readonly) NSString *stringByDeletingURLQuery;

- (NSString *)stringByReplacingURLQueryWithQuery:(NSString *)query;
- (NSString *)stringByAppendingURLQuery:(NSString *)query;
- (NSString *)stringByMergingURLQuery:(NSString *)query;
- (NSString *)stringByMergingURLQuery:(NSString *)query options:(URLQueryOptions)options;
- (NSDictionary<NSString *, NSString *> *)URLQueryParameters;
- (NSDictionary<NSString *, NSString *> *)URLQueryParametersWithOptions:(URLQueryOptions)options;

#pragma mark URL fragment ID

@property (nonatomic, readonly) NSString *URLFragment;
@property (nonatomic, readonly) NSString *stringByDeletingURLFragment;

- (NSString *)stringByAppendingURLFragment:(NSString *)fragment;

#pragma mark URL conversion

@property (nonatomic, readonly, nullable) NSURL *URLValue;

- (nullable NSURL *)URLValueRelativeToURL:(nullable NSURL *)baseURL;

#pragma mark base 64

@property (nonatomic, readonly) NSString *base64EncodedString;
@property (nonatomic, readonly) NSString *base64DecodedString;

@end


@interface NSURL (RequestUtils)

+ (instancetype)URLWithComponents:(NSDictionary<NSString *, NSString *> *)components;

@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *components;

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

+ (instancetype)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary<NSString *, id> *)parameters;
+ (instancetype)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary<NSString *, id> *)parameters;
+ (instancetype)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary<NSString *, id> *)parameters;

@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *GETParameters;
@property (nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *POSTParameters;
@property (nonatomic, readonly, nullable) NSString *HTTPBasicAuthUser;
@property (nonatomic, readonly, nullable) NSString *HTTPBasicAuthPassword;

@end


@interface NSMutableURLRequest (RequestUtils)

@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *GETParameters;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *POSTParameters;

- (void)setGETParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options;
- (void)addGETParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options;
- (void)setPOSTParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options;
- (void)addPOSTParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options;
- (void)setHTTPBasicAuthUser:(NSString *)user password:(nullable NSString *)password;

@end


NS_ASSUME_NONNULL_END
