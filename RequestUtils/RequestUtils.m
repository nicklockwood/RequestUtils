//
//  RequestUtils.m
//
//  Version 1.0.1
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


NSString *const URLSchemeComponent = @"scheme";
NSString *const URLHostComponent = @"host";
NSString *const URLPortComponent = @"port";
NSString *const URLUserComponent = @"user";
NSString *const URLPasswordComponent = @"password";
NSString *const URLPathComponent = @"path";
NSString *const URLParameterStringComponent = @"parameterString";
NSString *const URLQueryComponent = @"query";
NSString *const URLFragmentComponent = @"fragment";


@implementation NSString (RequestUtils)

#pragma mark URLEncoding

- (NSString *)URLEncodedString
{
    CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                  (__bridge CFStringRef)[self description],
                                                                  NULL,
                                                                  CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                                  kCFStringEncodingUTF8);
    return CFBridgingRelease(encoded);
}

- (NSString *)URLDecodedString:(BOOL)decodePlusAsSpace
{
    NSString *string = [self description];
    if (decodePlusAsSpace)
    {
        string = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }
    return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark URL path extension

- (NSString *)stringByAppendingURLPathExtension:(NSString *)extension
{
    NSString *lastPathComponent = [[self lastURLPathComponent] stringByAppendingPathExtension:extension];
    return [[self stringByDeletingLastURLPathComponent] stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)stringByDeletingURLPathExtension
{
    NSString *lastPathComponent = [[self lastURLPathComponent] stringByDeletingPathExtension];
    return [[self stringByDeletingLastURLPathComponent] stringByAppendingURLPathComponent:lastPathComponent];
}

- (NSString *)URLPathExtension
{
    return [[self lastURLPathComponent] pathExtension];
}

#pragma mark URL paths

- (NSString *)stringByAppendingURLPathComponent:(NSString *)str
{
    NSString *url = self;
    
    //remove fragment
    NSString *fragment = [url URLFragment];
    url = [url stringByDeletingURLFragment];
    
    //remove query
    NSString *query = [url URLQuery];
    url = [url stringByDeletingURLQuery];
    
    //strip leading slash on path
    if ([str hasPrefix:@"/"])
    {
        str = [str substringFromIndex:1];
    }
    
    //add trailing slash
    if ([url length] && ![url hasSuffix:@"/"])
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
    NSString *fragment = [url URLFragment];
    url = [url stringByDeletingURLFragment];
    
    //remove query
    NSString *query = [url URLQuery];
    url = [url stringByDeletingURLQuery];
    
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
    url = [url stringByDeletingURLFragment];
    
    //remove query
    url = [url stringByDeletingURLQuery];
    
    //get last path component
    NSRange range = [url rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location != NSNotFound) url = [url substringFromIndex:range.location + 1];
    
    return url;
}

#pragma mark Query strings

+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters
{
    return [self URLQueryWithParameters:parameters options:URLQueryOptionDefault];
}

+ (NSString *)URLQueryWithParameters:(NSDictionary *)parameters options:(URLQueryOptions)options
{
    BOOL useArraySyntax = options & 8;
    URLQueryOptions arrayHandling = (options & 7) ?: URLQueryOptionUseArrays;
    
    NSMutableString *result = [NSMutableString string];
    for (NSString *key in parameters)
    {
        NSString *encodedKey = [key URLEncodedString];
        id value = parameters[key];
        if ([value isKindOfClass:[NSArray class]])
        {
            if (arrayHandling == URLQueryOptionKeepFirstValue && [value count])
            {
                if ([result length])
                {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [value[0] URLEncodedString]];
            }
            else if (arrayHandling == URLQueryOptionKeepLastValue && [value count])
            {
                if ([result length])
                {
                    [result appendString:@"&"];
                }
                [result appendFormat:@"%@=%@", encodedKey, [[value lastObject] URLEncodedString]];
            }
            else
            {
                for (NSString *element in value)
                {
                    if ([result length])
                    {
                        [result appendString:@"&"];
                    }
                    if (useArraySyntax)
                    {
                        [result appendFormat:@"%@[]=%@", encodedKey, [element URLEncodedString]];
                    }
                    else
                    {
                        [result appendFormat:@"%@=%@", encodedKey, [element URLEncodedString]];
                    }
                }
            }
        }
        else
        {
            if ([result length])
            {
                [result appendString:@"&"];
            }
            if (useArraySyntax && arrayHandling == URLQueryOptionAlwaysUseArrays)
            {
                [result appendFormat:@"%@[]=%@", encodedKey, [value URLEncodedString]];
            }
            else
            {
                [result appendFormat:@"%@=%@", encodedKey, [value URLEncodedString]];
            }
        }
    }
    return result;
}

- (NSRange)rangeOfURLQuery
{
    NSRange queryRange = NSMakeRange(0, [self length]);
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
    return [[self stringByDeletingURLQuery] stringByAppendingURLQuery:query];
}

- (NSString *)stringByAppendingURLQuery:(NSString *)query
{
    //check for nil input
    if ([query length] == 0)
    {
        return self;
    }
    
    NSString *result = self;
    NSString *fragment = [result URLFragment];
    result = [self stringByDeletingURLFragment];
    NSString *queryString = [result URLQuery];
    if (queryString)
    {
        if ([queryString length])
        {
            result = [result stringByAppendingFormat:@"&%@", query];
        }
        else
        {
            result = [result stringByAppendingString:query];
        }
    }
    else
    {
        result = [result stringByAppendingFormat:@"?%@", query];
    }
    if ([fragment length])
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
    URLQueryOptions arrayHandling = (options & 7) ?: URLQueryOptionKeepLastValue;
    
    //check for nil input
    query = [query URLQuery];
    if ([query length] == 0)
    {
        return self;
    }
    
    //check for nil query string
    NSString *queryString = [self URLQuery];
    if ([queryString length] == 0)
    {
        return [self stringByAppendingURLQuery:query];
    }
    
    NSMutableDictionary *parameters = [[queryString URLQueryParametersWithOptions:options] mutableCopy];
    
#if !__has_feature(objc_arc)
    [parameters autorelease];
#endif
    
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
            else if (arrayHandling == URLQueryOptionKeepFirstValue)
            {
                value = oldValue;
            }
            else if (arrayHandling == URLQueryOptionUseArrays ||
                     arrayHandling == URLQueryOptionAlwaysUseArrays)
            {
                value = @[oldValue, value];
            }
        }
        else if (arrayHandling == URLQueryOptionAlwaysUseArrays)
        {
            value = @[value];
        }
        parameters[key] = value;
    }

    return [self stringByReplacingURLQueryWithQuery:[NSString URLQueryWithParameters:parameters options:options]];
}

- (NSDictionary *)URLQueryParameters
{
    return [self URLQueryParametersWithOptions:URLQueryOptionDefault];
}

- (NSDictionary *)URLQueryParametersWithOptions:(URLQueryOptions)options
{
    URLQueryOptions arrayHandling = (options & 7) ?: URLQueryOptionKeepLastValue;
    
    NSString *queryString = [self URLQuery];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [parts[0] URLDecodedString:YES];
        if ([parts count] > 1)
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
                if (arrayHandling == URLQueryOptionKeepFirstValue)
                {
                    value = existingValue;
                }
                else if (arrayHandling != URLQueryOptionKeepLastValue)
                {
                    value = @[existingValue, value];
                }
            }
            else if ((arrayValue && arrayHandling == URLQueryOptionUseArrays) ||
                     arrayHandling == URLQueryOptionAlwaysUseArrays)
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

- (NSURL *)URLValue
{
    if ([self isAbsolutePath])
    {
        return [NSURL fileURLWithPath:self];
    }
    return [NSURL URLWithString:self];
}

- (NSURL *)URLValueRelativeToURL:(NSURL *)baseURL
{
    return [NSURL URLWithString:self relativeToURL:baseURL];
}

#pragma mark base 64

- (NSString *)base64EncodedString
{
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    NSData *inputData = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    unsigned char *outputBytes = (unsigned char *)malloc(maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    //truncate data to match actual output length
    if (outputLength)
    {
        outputBytes = realloc(outputBytes, outputLength);
        NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes length:outputLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
        
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        
        return (outputLength >= 4)? result: nil;
    }
    else
    {
        free(outputBytes);
        return nil;
    }
}

- (NSString *)base64DecodedString
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    
    if (outputLength)
    {
        NSString *result = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        
#if !__has_feature(objc_arc)
        [result autorelease];
#endif
        
        return result;
    }
    else
    {
        return nil;
    }
}

@end


@implementation NSURL (RequestUtils)

+ (NSURL *)URLWithComponents:(NSDictionary *)components
{
    NSString *URL = @"";
    NSString *fragment = components[URLFragmentComponent];
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

- (NSDictionary *)components
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
    NSMutableDictionary *components = [[self components] mutableCopy];
    
#if !__has_feature(objc_arc)
    [components autorelease];
#endif
    
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
    NSString *URL = [self absoluteString];
    URL = [URL substringFromIndex:[[self scheme] length]];
    return [NSURL URLWithString:[scheme stringByAppendingString:URL]];
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
    return [self URLWithValue:path forComponent:URLPasswordComponent];
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

+ (id)HTTPRequestWithURL:(NSURL *)URL method:(NSString *)method parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    method = [method uppercaseString];
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

+ (id)GETRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters
{
    return [NSURLRequest HTTPRequestWithURL:URL method:@"GET" parameters:parameters];
}

+ (id)POSTRequestWithURL:(NSURL *)URL parameters:(NSDictionary *)parameters
{
    return [NSURLRequest HTTPRequestWithURL:URL method:@"POST" parameters:parameters];
}

- (NSDictionary *)GETParameters
{
    return [[self.URL query] URLQueryParameters];
}

- (NSDictionary *)POSTParameters
{
    NSString *parameterString = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
    
#if !__has_feature(objc_arc)
    [parameterString autorelease];
#endif
    
    return [parameterString URLQueryParameters];
}

- (NSArray *)HTTPBasicAuthComponents
{
    NSString *authHeader = [self valueForHTTPHeaderField:@"Authorization"];
    if (authHeader)
    {
        return [[[authHeader stringByReplacingOccurrencesOfString:@"Basic " withString:@""] base64DecodedString] componentsSeparatedByString:@":"];
    }
    else
    {
        return @[[self.URL user] ?: @"", [self.URL password] ?: @""];
    }
}

- (NSString *)HTTPBasicAuthUser
{
	return [self HTTPBasicAuthComponents][0];
}

- (NSString *)HTTPBasicAuthPassword
{
    NSArray *components = [self HTTPBasicAuthComponents];
    return ([components count] == 2)? [components lastObject]: nil;
}

@end


@implementation NSMutableURLRequest (RequestUtils)

- (void)setGETParameters:(NSDictionary *)parameters
{
    [self setGETParameters:parameters options:URLQueryOptionDefault];
}

- (void)setGETParameters:(NSDictionary *)parameters options:(URLQueryOptions)options
{
    self.URL = [self.URL URLWithQuery:[NSString URLQueryWithParameters:parameters options:options]];
}

- (void)addGETParameters:(NSDictionary *)parameters options:(URLQueryOptions)options
{
    NSString *query = [NSString URLQueryWithParameters:parameters options:options];
    query = [[[self.URL absoluteString] URLQuery] ?: @"" stringByMergingURLQuery:query options:options];
    self.URL = [self.URL URLWithQuery:query];
}

- (void)setPOSTParameters:(NSDictionary *)parameters
{
    [self setPOSTParameters:parameters options:URLQueryOptionDefault];
}
                       
- (void)setPOSTParameters:(NSDictionary *)parameters options:(URLQueryOptions)options
{
    NSString *content = [NSString URLQueryWithParameters:parameters options:options];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self addValue:[NSString stringWithFormat:@"%i", (int)[data length]] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:data];
}

- (void)addPOSTParameters:(NSDictionary *)parameters options:(URLQueryOptions)options
{
    NSString *query = [NSString URLQueryWithParameters:parameters options:options];
    NSString *content = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
    
#if !__has_feature(objc_arc)
    [content autorelease];
#endif
    
    content = [content ?: @"" stringByMergingURLQuery:query options:options];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    [self addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self addValue:[NSString stringWithFormat:@"%i", (int)[data length]] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:data];
}

- (void)setHTTPBasicAuthUser:(NSString *)user password:(NSString *)password
{
    NSString *authHeader = [NSString stringWithFormat:@"%@:%@", (user ?: @""), (password ?: @"")];
    authHeader = [NSString stringWithFormat:@"Basic %@", [authHeader base64EncodedString]];
    [self addValue:authHeader forHTTPHeaderField:@"Authorization"];  
}

@end
