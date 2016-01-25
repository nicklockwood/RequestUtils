//
//  RequestUtils.m
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

#import "RequestUtils.h"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


#pragma GCC diagnostic ignored "-Wgnu"
#pragma GCC diagnostic ignored "-Wundef"
#pragma GCC diagnostic ignored "-Wselector"


@implementation NSData (RequestUtils)

- (NSString *)RequestUtils_UTF8String
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end


@implementation NSString (RequestUtils)

#pragma mark URLEncoding

- (NSString *)URLEncodedString
{
    static NSString *const unsafeChars = @"!*'\"();:@&=+$,/?%#[]% ";

#if !(__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9) && !(__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0)

    if (![self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)])
    {
        CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (__bridge CFStringRef)self,
                                                                      NULL,
                                                                      (__bridge CFStringRef)unsafeChars,
                                                                      kCFStringEncodingUTF8);
        return (__bridge_transfer NSString *)encoded;
    }

#endif

    static NSCharacterSet *allowedChars;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSCharacterSet *disallowedChars = [NSCharacterSet characterSetWithCharactersInString:unsafeChars];
        allowedChars = [disallowedChars invertedSet];
    });

    return (NSString *)[self stringByAddingPercentEncodingWithAllowedCharacters:allowedChars];
}

- (NSString *)URLDecodedString
{
    return [self URLDecodedString:NO];
}

- (NSString *)URLDecodedString:(BOOL)decodePlusAsSpace
{
    NSString *string = self;
    if (decodePlusAsSpace)
    {
        string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }

#if !(__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9) && !(__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0)

    if (![self respondsToSelector:@selector(stringByRemovingPercentEncoding)])
    {
        return (NSString *)[string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }

#endif

    return (NSString *)[string stringByRemovingPercentEncoding];
}

#pragma mark URL path extension

- (NSString *)stringByAppendingURLPathExtension:(NSString *)extension
{
    NSString *lastPathComponent = [self.lastURLPathComponent stringByAppendingPathExtension:extension];
    return [self.stringByDeletingLastURLPathComponent stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)stringByDeletingURLPathExtension
{
    NSString *lastPathComponent = [self.lastURLPathComponent stringByDeletingPathExtension];
    return [self.stringByDeletingLastURLPathComponent stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)URLPathExtension
{
    return self.lastURLPathComponent.pathExtension;
}

#pragma mark URL paths

- (NSString *)stringByAppendingURLPathComponent:(NSString *)str
{
    NSString *url = self;
    
    //remove fragment
    NSString *fragment = url.URLFragment;
    url = url.stringByDeletingURLFragment;
    
    //remove query
    NSString *query = url.URLQuery;
    url = url.stringByDeletingURLQuery;
    
    //strip leading slash on path
    if ([str hasPrefix:@"/"])
    {
        str = [str substringFromIndex:1];
    }
    
    //add trailing slash
    if (url.length && ![url hasSuffix:@"/"])
    {
        url = [url stringByAppendingString:@"/"];
    }
    
    //reassemble url
    url = [url stringByAppendingString:str];
    url = [url stringByAppendingURLQuery:query];
    url = [url stringByAppendingURLFragment:fragment];
    
    return url;
}

- (NSString *)stringByDeletingLastURLPathComponent
{
    NSString *url = self;
    
    //remove fragment
    NSString *fragment = url.URLFragment;
    url = url.stringByDeletingURLFragment;
    
    //remove query
    NSString *query = url.URLQuery;
    url = url.stringByDeletingURLQuery;
    
    //trim path
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) url = [url substringToIndex:range.location + 1];
    
    //reassemble url
    url = [url stringByAppendingURLQuery:query];
    url = [url stringByAppendingURLFragment:fragment];
    
    return url;
}

- (NSString *)lastURLPathComponent
{
    NSString *url = self;
    
    //remove fragment
    url = url.stringByDeletingURLFragment;
    
    //remove query
    url = url.stringByDeletingURLQuery;
    
    //get last path component
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) url = [url substringFromIndex:range.location + 1];
    
    return url;
}

#pragma mark Query strings

+ (NSString *)URLQueryWithParameters:(NSDictionary<NSString *, id> *)parameters
{
    return [self URLQueryWithParameters:parameters options:URLQueryOptionDefault];
}

+ (NSString *)URLQueryWithParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options
{
    options = options ?: URLQueryOptionUseArrays;
    
    BOOL sortKeys = !!(options & URLQueryOptionSortKeys);
    if (sortKeys)
    {
        options -= URLQueryOptionSortKeys;
    }
    
    BOOL useArraySyntax = !!(options & URLQueryOptionUseArraySyntax);
    if (useArraySyntax)
    {
        options -= URLQueryOptionUseArraySyntax;
        NSAssert(options == URLQueryOptionUseArrays || options == URLQueryOptionAlwaysUseArrays,
                 @"URLQueryOptionUseArraySyntax has no effect unless combined with URLQueryOptionUseArrays or URLQueryOptionAlwaysUseArrays option");
    }
  
    NSMutableString *result = [NSMutableString string];
    NSArray<NSString *> *keys = parameters.allKeys;
    if (sortKeys) keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys)
    {
        id value = parameters[key];
        NSString *encodedKey = key.description.URLEncodedString;
        if ([value isKindOfClass:[NSArray class]])
        {
            if (options == URLQueryOptionKeepFirstValue && [value count])
            {
                if (result.length)
                {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [[value firstObject] description].URLEncodedString];
            }
            else if (options == URLQueryOptionKeepLastValue && [value count])
            {
                if (result.length)
                {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [[value lastObject] description].URLEncodedString];
            }
            else
            {
                for (NSString *element in value)
                {
                    if (result.length)
                    {
                        [result appendString:@"&"];
                    }
                    if (useArraySyntax)
                    {
                        [result appendFormat:@"%@[]=%@", encodedKey, element.description.URLEncodedString];
                    }
                    else
                    {
                        [result appendFormat:@"%@=%@", encodedKey, element.description.URLEncodedString];
                    }
                }
            }
        }
        else
        {
            if (result.length)
            {
                [result appendString:@"&"];
            }
            if (useArraySyntax && options == URLQueryOptionAlwaysUseArrays)
            {
                [result appendFormat:@"%@[]=%@", encodedKey, [value description].URLEncodedString];
            }
            else
            {
                [result appendFormat:@"%@=%@", encodedKey, [value description].URLEncodedString];
            }
        }
    }
    
    return result;
}

- (NSRange)rangeOfURLQuery
{
    NSRange queryRange = NSMakeRange(0, self.length);
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.length)
    {
        queryRange.length -= (queryRange.length - fragmentStart.location);
    }
    NSRange queryStart = [self rangeOfString:@"?"];
    if (queryStart.length)
    {
        queryRange.location = queryStart.location;
        queryRange.length -= queryRange.location;
    }
    NSString *queryString = [self substringWithRange:queryRange];
    if (queryStart.length || [queryString rangeOfString:@"="].length)
    {
        return queryRange;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (NSString *)URLQuery
{
    NSRange queryRange = [self rangeOfURLQuery];
    if (queryRange.location == NSNotFound)
    {
        return nil;
    }
    NSString *queryString = [self substringWithRange:queryRange];
    if ([queryString hasPrefix:@"?"])
    {
        queryString = [queryString substringFromIndex:1];
    }
    return queryString;
}

- (NSString *)stringByDeletingURLQuery
{
    NSRange queryRange = [self rangeOfURLQuery];
    if (queryRange.location != NSNotFound)
    {
        NSString *prefix = [self substringToIndex:queryRange.location];
        NSString *suffix = [self substringFromIndex:queryRange.location + queryRange.length];
        return [prefix stringByAppendingString:suffix];
    }
    return self;
}

- (NSString *)stringByReplacingURLQueryWithQuery:(NSString *)query
{
    return [self.stringByDeletingURLQuery stringByAppendingURLQuery:query];
}

- (NSString *)stringByAppendingURLQuery:(NSString *)query
{
    //check for empty input
    query = query.URLQuery;
    if ([query length] == 0)
    {
        return self;
    }
    
    NSString *result = self;
    NSString *fragment = result.URLFragment;
    result = self.stringByDeletingURLFragment;
    NSString *existingQuery = result.URLQuery;
    if (existingQuery.length)
    {
        result = [result stringByAppendingFormat:@"&%@", query];
    }
    else
    {
        result = [result.stringByDeletingURLQuery stringByAppendingFormat:@"?%@", query];
    }
    if (fragment.length)
    {
        result = [result stringByAppendingFormat:@"#%@", fragment];
    }
    return result;
}

- (NSString *)stringByMergingURLQuery:(NSString *)query
{
    return [self stringByMergingURLQuery:query options:URLQueryOptionDefault];
}

- (NSString *)stringByMergingURLQuery:(NSString *)query options:(URLQueryOptions)options
{
    NSParameterAssert(options <= URLQueryOptionAlwaysUseArrays);
    options = options ?: URLQueryOptionKeepLastValue;
    
    //check for empty input
    query = query.URLQuery;
    if (query.length == 0)
    {
        return self;
    }
    
    //check for nil query string
    NSString *queryString = self.URLQuery;
    if (queryString.length == 0)
    {
        return [self stringByAppendingURLQuery:query];
    }
    
    NSMutableDictionary *parameters = (NSMutableDictionary *)[queryString URLQueryParametersWithOptions:options];
    NSDictionary *newParameters = [query URLQueryParametersWithOptions:options];
    for (NSString *key in newParameters)
    {
        id value = newParameters[key];
        id oldValue = parameters[key];
        if ([oldValue isKindOfClass:[NSArray class]])
        {
            if ([value isKindOfClass:[NSArray class]])
            {
                value = [oldValue arrayByAddingObjectsFromArray:value];
            }
            else
            {
                value = [oldValue arrayByAddingObject:value];
            }
        }
        else if (oldValue)
        {
            if ([value isKindOfClass:[NSArray class]])
            {
                value = [@[oldValue] arrayByAddingObjectsFromArray:value];
            }
            else if (options == URLQueryOptionKeepFirstValue)
            {
                value = oldValue;
            }
            else if (options == URLQueryOptionUseArrays ||
                     options == URLQueryOptionAlwaysUseArrays)
            {
                value = @[oldValue, value];
            }
        }
        else if (options == URLQueryOptionAlwaysUseArrays)
        {
            value = @[value];
        }
        parameters[key] = value;
    }

    return [self stringByReplacingURLQueryWithQuery:[NSString URLQueryWithParameters:parameters options:options]];
}

- (NSDictionary<NSString *, NSString *> *)URLQueryParameters
{
    return [self URLQueryParametersWithOptions:URLQueryOptionDefault];
}

- (NSDictionary<NSString *, NSString *> *)URLQueryParametersWithOptions:(URLQueryOptions)options
{
    NSParameterAssert(options <= URLQueryOptionAlwaysUseArrays);
    options = options ?: URLQueryOptionKeepLastValue;
    
    NSString *queryString = self.URLQuery;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray<NSString *> *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [parts[0] URLDecodedString:YES];
        if (parts.count > 1)
        {
            id value = [parts[1] URLDecodedString:YES];
            BOOL arrayValue = [key hasSuffix:@"[]"];
            if (arrayValue)
            {
                key = [key substringToIndex:[key length] - 2];
            }
            id existingValue = result[key];
            if ([existingValue isKindOfClass:[NSArray class]])
            {
                value = [existingValue arrayByAddingObject:value];
            }
            else if (existingValue)
            {
                if (options == URLQueryOptionKeepFirstValue)
                {
                    value = existingValue;
                }
                else if (options != URLQueryOptionKeepLastValue)
                {
                    value = @[existingValue, value];
                }
            }
            else if ((arrayValue && options == URLQueryOptionUseArrays) || options == URLQueryOptionAlwaysUseArrays)
            {
                value = @[value];
            }
            result[key] = value;
        }
    }
    return result;
}

#pragma mark URL fragment ID

- (NSString *)URLFragment
{
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.location != NSNotFound)
    {
        return [self substringFromIndex:fragmentStart.location + 1];
    }
    return nil;
}

- (NSString *)stringByDeletingURLFragment
{
    NSRange fragmentStart = [self rangeOfString:@"#"];
    if (fragmentStart.location != NSNotFound)
    {
        return [self substringToIndex:fragmentStart.location];
    }
    return self;
}

- (NSString *)stringByAppendingURLFragment:(NSString *)fragment
{
    if (fragment)
    {
        NSRange fragmentStart = [self rangeOfString:@"#"];
        if (fragmentStart.location != NSNotFound)
        {
            return [self stringByAppendingString:fragment];
        }
        return [self stringByAppendingFormat:@"#%@", fragment];
    }
    return self;
}

#pragma mark URL conversion

- (nullable NSURL *)URLValue
{
    if (self.absolutePath)
    {
        return [NSURL fileURLWithPath:self];
    }
    return [NSURL URLWithString:self];
}

- (nullable NSURL *)URLValueRelativeToURL:(nullable NSURL *)baseURL
{
    return [NSURL URLWithString:self relativeToURL:baseURL];
}

#pragma mark base 64

- (NSString *)base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
        
#if !(__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9) && !(__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0)
    
    if (![self respondsToSelector:@selector(base64EncodedStringWithOptions:)])
    {
        return data.base64Encoding;
    }
    
#endif

    return [data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
}

- (NSString *)base64DecodedString
{
    NSData *data;
    
#if !(__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9) && !(__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_7_0)
    
    if (![NSData instancesRespondToSelector:@selector(initWithBase64EncodedString:options:)])
    {
        data = [[NSData alloc] initWithBase64Encoding:self];
    }
    else
    
#endif
        
    {
        data = [[NSData alloc] initWithBase64EncodedString:self options:(NSDataBase64DecodingOptions)0];
    }
    
    return [data RequestUtils_UTF8String];
}

@end


@implementation NSURL (RequestUtils)

+ (NSURL *)URLWithComponents:(NSDictionary<NSString *, NSString *> *)components
{
    NSString *URL = @"";
    NSString *fragment = components[URLFragmentComponent];
    if ([fragment hasPrefix:@"#"])
    {
        fragment = [fragment substringFromIndex:1];
    }
    if (fragment)
    {
        URL = [NSString stringWithFormat:@"#%@", fragment];
    }
    NSString *query = components[URLQueryComponent];
    if (query)
    {
        if ([query isKindOfClass:[NSDictionary class]])
        {
            query = [NSString URLQueryWithParameters:(NSDictionary *)query];
        }
        if ([query hasPrefix:@"?"] || [query hasPrefix:@"&"])
        {
            query = [query substringFromIndex:1];
        }
        URL = [NSString stringWithFormat:@"?%@%@", query, URL];
    }
    NSString *parameterString = components[URLParameterStringComponent];
    if (parameterString)
    {
        URL = [NSString stringWithFormat:@";%@%@", parameterString, URL];
    }
    NSString *path = components[URLPathComponent];
    if (path)
    {
        URL = [path stringByAppendingString:URL];
    }
    NSString *port = components[URLPortComponent];
    if (port)
    {
        URL = [NSString stringWithFormat:@":%@%@", port, URL];
    }
    NSString *host = components[URLHostComponent];
    if (host)
    {
        URL = [host stringByAppendingString:URL];
    }
    NSString *user = components[URLUserComponent];
    if (user)
    {
        NSString *password = components[URLPasswordComponent];
        if (password)
        {
            user = [user stringByAppendingFormat:@":%@", password];
        }
        URL = [user stringByAppendingFormat:@"@%@", URL];
    }
    NSString *scheme = components[URLSchemeComponent];
    if (scheme)
    {
        URL = [scheme stringByAppendingFormat:@"://%@", URL];
    }
    return [NSURL URLWithString:URL];
}

- (NSDictionary<NSString *, NSString *> *)components
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *key in @[URLSchemeComponent, URLHostComponent,
                           URLPortComponent, URLUserComponent,
                           URLPasswordComponent, URLPortComponent,
                           URLPathComponent, URLParameterStringComponent,
                           URLQueryComponent, URLFragmentComponent])
    {
        id value = [self valueForKey:key];
        if (value)
        {
            result[key] = value;
        }
    }
    return result;
}

- (NSURL *)URLWithValue:(NSString *)value forComponent:(NSString *)component
{
    NSMutableDictionary *components = (NSMutableDictionary *)self.components;
    if (value)
    {
        components[component] = value;
    }
    else
    {
        [components removeObjectForKey:component];
    }
    return [NSURL URLWithComponents:components];
}

- (NSURL *)URLWithScheme:(NSString *)scheme
{
    NSString *URLString = self.absoluteString;
    URLString = [URLString substringFromIndex:self.scheme.length];
    return (NSURL *)[NSURL URLWithString:[scheme stringByAppendingString:URLString]];
}

- (NSURL *)URLWithHost:(NSString *)host
{
    return [self URLWithValue:host forComponent:URLHostComponent];
}

- (NSURL *)URLWithPort:(NSString *)port
{
    return [self URLWithValue:port forComponent:URLPortComponent];
}

- (NSURL *)URLWithUser:(NSString *)user
{
    return [self URLWithValue:user forComponent:URLUserComponent];
}

- (NSURL *)URLWithPassword:(NSString *)password
{
    return [self URLWithValue:password forComponent:URLPasswordComponent];
}

- (NSURL *)URLWithPath:(NSString *)path
{
    return [self URLWithValue:path forComponent:URLPathComponent];
}

- (NSURL *)URLWithParameterString:(NSString *)parameterString
{
    return [self URLWithValue:parameterString forComponent:URLParameterStringComponent];
}

- (NSURL *)URLWithQuery:(NSString *)query
{
    return [self URLWithValue:query forComponent:URLQueryComponent];
}

- (NSURL *)URLWithFragment:(NSString *)fragment
{
    return [self URLWithValue:fragment forComponent:URLFragmentComponent];
}

@end


@implementation NSURLRequest (RequestUtils)

+ (instancetype)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary<NSString *, id> *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    method = method.uppercaseString;
    request.HTTPMethod = method;
    
    //set method and parameters
    if ([method isEqualToString:@"GET"])
    {
        [request addGETParameters:parameters options:URLQueryOptionDefault];
    }
    else
    {
        [request setPOSTParameters:parameters options:URLQueryOptionDefault];
    }
    
    //accept gzip encoded data by default
    [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    return request;
}

+ (instancetype)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary<NSString *, id> *)parameters
{
    return [self HTTPRequestWithURL:URL method:@"GET" parameters:parameters];
}

+ (instancetype)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary<NSString *, id> *)parameters
{
    return [self HTTPRequestWithURL:URL method:@"POST" parameters:parameters];
}

- (nullable NSDictionary<NSString *, NSString *> *)GETParameters
{
    return self.URL.query.URLQueryParameters;
}

- (nullable NSDictionary<NSString *, NSString *> *)POSTParameters
{
    return [self.HTTPBody RequestUtils_UTF8String].URLQueryParameters;
}

- (nullable NSArray<NSString *> *)HTTPBasicAuthComponents
{
    NSString *authHeader = [self valueForHTTPHeaderField:@"Authorization"];
    return [[authHeader stringByReplacingOccurrencesOfString:@"Basic " withString:@""].base64DecodedString componentsSeparatedByString:@":"];
}

- (nullable NSString *)HTTPBasicAuthUser
{
    NSString *user = [self HTTPBasicAuthComponents].firstObject;
    return user.length? user: self.URL.user;
}

- (nullable NSString *)HTTPBasicAuthPassword
{
    NSArray<NSString *> *components = [self HTTPBasicAuthComponents];
    return components.count == 2? components.lastObject: self.URL.password;
}

@end


@implementation NSMutableURLRequest (RequestUtils)

- (void)setGETParameters:(NSDictionary<NSString *, id> *)parameters
{
    [self setGETParameters:parameters options:URLQueryOptionDefault];
}

- (void)setGETParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options
{
    self.URL = [self.URL URLWithQuery:[NSString URLQueryWithParameters:parameters options:options]];
}

- (void)addGETParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options
{
    NSString *query = [NSString URLQueryWithParameters:parameters options:options];
    NSString *existingQuery = self.URL.query;
    if (existingQuery.length)
    {
        query = [existingQuery stringByMergingURLQuery:query options:options];
    }
    self.URL = [self.URL URLWithQuery:query];
}

- (void)setPOSTParameters:(NSDictionary<NSString *, id> *)parameters
{
    [self setPOSTParameters:parameters options:URLQueryOptionDefault];
}

- (void)setPOSTParameterString:(NSString *)parameterString
{
    NSData *data = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    [self addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self addValue:[NSString stringWithFormat:@"%tu", data.length] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:data];
}
                       
- (void)setPOSTParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options
{
    NSString *content = [NSString URLQueryWithParameters:parameters options:options];
    [self setPOSTParameterString:content];
}

- (void)addPOSTParameters:(NSDictionary<NSString *, id> *)parameters options:(URLQueryOptions)options
{
    NSString *query = [NSString URLQueryWithParameters:parameters options:options];
    NSString *content = [[self.HTTPBody RequestUtils_UTF8String] ?: @"" stringByMergingURLQuery:query options:options];
    [self setPOSTParameterString:content];
}

- (void)setHTTPBasicAuthUser:(NSString *)user password:(nullable NSString *)password
{
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", user ?: @"", password ?: @""];
    authHeader = [NSString stringWithFormat:@"Basic %@", authHeader.base64EncodedString];
    [self addValue:authHeader forHTTPHeaderField:@"Authorization"];
}

@end
