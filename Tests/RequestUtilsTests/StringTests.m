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
	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"foo", @"bar", nil];
	NSAssert([[query URLQueryParametersWithOptions:0] isEqual:result], @"URLQueryParameters test failed");
}

- (void)testArrayQueryString
{
	NSString *query = @"?foo=bar&bar=foo&bar=bar";
	NSDictionary *result1 = [NSDictionary dictionaryWithObjectsAndKeys:
							 @"bar", @"foo", [NSArray arrayWithObjects:@"foo", @"bar", nil], @"bar", nil];
	NSDictionary *result2 = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"bar", @"bar", nil];
	NSDictionary *result3 = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSArray arrayWithObject:@"bar"], @"foo",
							 [NSArray arrayWithObjects:@"foo", @"bar", nil], @"bar", nil];
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionUseArrays] isEqual:result1], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue] isEqual:result2], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionAlwaysUseArrays] isEqual:result3], @"URLQueryParameters test failed");
}

- (void)testArrayQueryString2
{
	NSString *query = @"?foo[]=bar&bar[]=foo&bar[]=bar";
	NSDictionary *result1 = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSArray arrayWithObject:@"bar"], @"foo",
							 [NSArray arrayWithObjects:@"foo", @"bar", nil], @"bar", nil];
	NSDictionary *result2 = [NSDictionary dictionaryWithObjectsAndKeys:@"bar", @"foo", @"bar", @"bar", nil];
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionUseArrays] isEqual:result1], @"URLQueryParameters test failed");
	NSAssert([[query URLQueryParametersWithOptions:URLQueryOptionKeepLastValue] isEqual:result2], @"URLQueryParameters test failed");
}

@end
