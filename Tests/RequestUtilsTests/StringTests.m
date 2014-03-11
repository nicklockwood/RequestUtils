//
//  StringTests.m
//  RequestUtilsTests
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StringTests.h"
#import "RequestUtils.h"


@implementation StringTests

#pragma mark URL parsing

- (void)testNilURL
{    
	NSString *nilString = nil;
	NSAssert([nilString URLValue] == nil, @"URLValue nil test failed");
}

- (void)testInvalidURL
{
	NSString *invalidURLString = @"foo\\bar";
	NSAssert([invalidURLString URLValue] == nil, @"URLValue invalid URL test failed");
}

- (void)testURLFragment
{
	NSString *validURLString = @"?foo=bar";
	NSAssert([validURLString URLValue] != nil, @"URLValue URL fragment test failed");
	NSAssert([[[validURLString URLValue] query] isEqualToString:@"foo=bar"], @"URLValue URL fragment test failed");
}

#pragma mark Paths

- (void)textURLEncoding
{
    NSString *input = @"foo bar";
    NSString *expected = @"foo%20bar";
	NSAssert([expected isEqualToString:[input URLEncodedString]], @"URLEncoding test failed");
}

- (void)textNilURLEncoding
{
    NSString *nilString = nil;
	NSAssert([nilString URLValue] == nil, @"URLEncoding nil test failed");
}

#pragma mark Paths

- (void)testAppendPath
{
	NSString *URLString = @"http://hello";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	NSAssert([URLString isEqualToString:@"http://hello/world"], @"URL append path test failed");
}

- (void)testAppendPath2
{
	NSString *URLString = @"http://hello?foo=bar";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	NSAssert([URLString isEqualToString:@"http://hello/world?foo=bar"], @"URL append path test failed");
}

- (void)testAppendPath3
{
	NSString *URLString = @"hello#world";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	NSAssert([URLString isEqualToString:@"hello/world#world"], @"URL append path test failed");
}

#pragma mark Path extension

- (void)testAppendPathExtension
{
	NSString *URLString = @"http://hello";
    URLString = [URLString stringByAppendingURLPathExtension:@"world"];
	NSAssert([URLString isEqualToString:@"http://hello.world"], @"URL append path extension test failed");
}

#pragma mark Query strings

- (void)testSimpleQueryString
{
	NSString *query = @"?foo=bar&bar=foo";
	NSDictionary *result = @{@"foo": @"bar", @"bar": @"foo"};
	NSAssert([[query URLQueryParametersWithOptions:0] isEqual:result], @"URLQueryParameters test failed");
}

- (void)testArrayQueryString
{
	NSString *query = @"?foo=bar&bar=foo&bar=bar";
	NSDictionary *result1 = @{@"foo": @"bar", @"bar": @[@"foo", @"bar"]};
	NSDictionary *result2 = @{@"foo": @"bar", @"bar": @"bar"};
	NSDictionary *result3 = @{@"foo": @[@"bar"], @"bar": @[@"foo", @"bar"]};
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionUseArrays] isEqual:result1], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue] isEqual:result2], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionAlwaysUseArrays] isEqual:result3], @"URLQueryParameters test failed");
}

- (void)testArrayQueryString2
{
	NSString *query = @"?foo[]=bar&bar[]=foo&bar[]=bar";
	NSDictionary *result1 = @{@"foo": @[@"bar"], @"bar": @[@"foo", @"bar"]};
	NSDictionary *result2 = @{@"foo": @"bar", @"bar": @"bar"};
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionUseArrays] isEqual:result1], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue] isEqual:result2], @"URLQueryParameters test failed");
}

- (void)testAppendQuery
{
    NSString *query1 = @"?foo=bar";
    NSString *query2 = @"foo=bar";
    NSString *URLString1 = @"http://apple.com?";
    NSString *URLString2 = @"http://apple.com";
    NSString *result = @"http://apple.com?foo=bar";
    NSAssert([[URLString1 stringByAppendingURLQuery:query1] isEqualToString:result], @"URLQueryParameters test failed");
    NSAssert([[URLString1 stringByAppendingURLQuery:query2] isEqualToString:result], @"URLQueryParameters test failed");
    NSAssert([[URLString2 stringByAppendingURLQuery:query1] isEqualToString:result], @"URLQueryParameters test failed");
    NSAssert([[URLString2 stringByAppendingURLQuery:query2] isEqualToString:result], @"URLQueryParameters test failed");
}

- (void)testMergeQuery
{
    NSString *query1 = @"?foo=bar";
    NSString *query2 = @"foo=bar";
    NSString *URLString1 = @"http://apple.com?";
    NSString *URLString2 = @"http://apple.com";
    NSString *URLString3 = @"http://apple.com?baz=bleem";
    NSString *result1 = @"http://apple.com?foo=bar";
    NSString *result2 = @"http://apple.com?baz=bleem&foo=bar";
    NSAssert([[URLString1 stringByMergingURLQuery:query1] isEqualToString:result1], @"URLQueryParameters test failed");
    NSAssert([[URLString1 stringByMergingURLQuery:query2] isEqualToString:result1], @"URLQueryParameters test failed");
    NSAssert([[URLString2 stringByMergingURLQuery:query1] isEqualToString:result1], @"URLQueryParameters test failed");
    NSAssert([[URLString2 stringByMergingURLQuery:query2] isEqualToString:result1], @"URLQueryParameters test failed");
    NSAssert([[URLString3 stringByMergingURLQuery:query1] isEqualToString:result2], @"URLQueryParameters test failed");
    NSAssert([[URLString3 stringByMergingURLQuery:query2] isEqualToString:result2], @"URLQueryParameters test failed");
}

@end
