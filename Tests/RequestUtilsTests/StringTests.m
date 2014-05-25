//
//  StringTests.m
//  RequestUtilsTests
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestUtils.h"


@interface StringTests : XCTestCase

@end


@implementation StringTests

#pragma mark URL parsing

- (void)testInvalidURL
{
	NSString *invalidURLString = @"foo\\bar";
	XCTAssertNil([invalidURLString URLValue], @"URLValue invalid URL test failed");
}

- (void)testURLFragment
{
	NSString *validURLString = @"?foo=bar";
	XCTAssertNotNil([validURLString URLValue], @"URLValue URL fragment test failed");
	XCTAssertEqualObjects([[validURLString URLValue] query], @"foo=bar", @"URLValue URL fragment test failed");
}

#pragma mark Paths

- (void)textURLEncoding
{
    NSString *input = @"foo bar";
	XCTAssertEqualObjects([input URLEncodedString], @"foo%20bar", @"URLEncoding test failed");
}

#pragma mark Paths

- (void)testAppendPath
{
	NSString *URLString = @"http://hello";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	XCTAssertEqualObjects(URLString, @"http://hello/world", @"URL append path test failed");
}

- (void)testAppendPath2
{
	NSString *URLString = @"http://hello?foo=bar";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	XCTAssertEqualObjects(URLString, @"http://hello/world?foo=bar", @"URL append path test failed");
}

- (void)testAppendPath3
{
	NSString *URLString = @"hello#world";
    URLString = [URLString stringByAppendingURLPathComponent:@"world"];
	XCTAssertEqualObjects(URLString, @"hello/world#world", @"URL append path test failed");
}

#pragma mark Path extension

- (void)testAppendPathExtension
{
	NSString *URLString = @"http://hello";
    URLString = [URLString stringByAppendingURLPathExtension:@"world"];
	XCTAssertEqualObjects(URLString, @"http://hello.world", @"URL append path extension test failed");
}

#pragma mark Query strings

- (void)testSimpleQueryString
{
	NSString *query = @"?foo=bar&bar=foo";
	NSDictionary *result = @{@"foo": @"bar", @"bar": @"foo"};
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:0], result, @"URLQueryParameters test failed");
}

- (void)testArrayQueryString
{
	NSString *query = @"?foo=bar&bar=foo&bar=bar";
	NSDictionary *result1 = @{@"foo": @"bar", @"bar": @[@"foo", @"bar"]};
	NSDictionary *result2 = @{@"foo": @"bar", @"bar": @"bar"};
	NSDictionary *result3 = @{@"foo": @[@"bar"], @"bar": @[@"foo", @"bar"]};
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:URLQueryOptionUseArrays], result1, @"URLQueryParameters test failed");
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue], result2, @"URLQueryParameters test failed");
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:URLQueryOptionAlwaysUseArrays], result3, @"URLQueryParameters test failed");
}

- (void)testArrayQueryString2
{
	NSString *query = @"?foo[]=bar&bar[]=foo&bar[]=bar";
	NSDictionary *result1 = @{@"foo": @[@"bar"], @"bar": @[@"foo", @"bar"]};
	NSDictionary *result2 = @{@"foo": @"bar", @"bar": @"bar"};
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:URLQueryOptionUseArrays], result1, @"URLQueryParameters test failed");
	XCTAssertEqualObjects([query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue], result2, @"URLQueryParameters test failed");
}

- (void)testUseArraySyntax
{
	NSDictionary *params = @{@"foo": @"bar", @"bar": @[@"foo"]};
    NSString *result1 = @"foo=bar&bar[]=foo";
    NSString *result2 = @"foo[]=bar&bar[]=foo";
    XCTAssertEqualObjects([NSString URLQueryWithParameters:params options:(URLQueryOptions)(URLQueryOptionUseArrays|URLQueryOptionUseArraySyntax)], result1, @"failed");
    XCTAssertEqualObjects([NSString URLQueryWithParameters:params options:(URLQueryOptions)(URLQueryOptionAlwaysUseArrays|URLQueryOptionUseArraySyntax)], result2, @"failed");
}

- (void)testAppendQuery
{
    NSString *query1 = @"?foo=bar";
    NSString *query2 = @"foo=bar";
    NSString *URLString1 = @"http://apple.com?";
    NSString *URLString2 = @"http://apple.com";
    NSString *result = @"http://apple.com?foo=bar";
    XCTAssertEqualObjects([URLString1 stringByAppendingURLQuery:query1], result, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString1 stringByAppendingURLQuery:query2], result, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString2 stringByAppendingURLQuery:query1], result, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString2 stringByAppendingURLQuery:query2], result, @"URLQueryParameters test failed");
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
    XCTAssertEqualObjects([URLString1 stringByMergingURLQuery:query1], result1, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString1 stringByMergingURLQuery:query2], result1, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString2 stringByMergingURLQuery:query1], result1, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString2 stringByMergingURLQuery:query2], result1, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString3 stringByMergingURLQuery:query1], result2, @"URLQueryParameters test failed");
    XCTAssertEqualObjects([URLString3 stringByMergingURLQuery:query2], result2, @"URLQueryParameters test failed");
}

@end
