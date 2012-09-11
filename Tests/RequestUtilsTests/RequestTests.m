//
//  RequestTests.m
//  RequestUtilsTests
//
//  Created by Nick Lockwood on 11/09/2012.
//
//

#import "RequestTests.h"
#import "RequestUtils.h"


@implementation RequestTests

#pragma mark Request generation

- (void)testGETRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
	NSDictionary *parameters = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest GETRequestWithURL:URL parameters:parameters];
	NSAssert([[request GETParameters] isEqual:parameters], @"GETRequest test failed");
}

- (void)testGETRequest2
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com?foo=bar"];
	NSDictionary *parameters = [@"bar=foo" URLQueryParameters];
    NSDictionary *result = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest GETRequestWithURL:URL parameters:parameters];
	NSAssert([[request GETParameters] isEqual:result], @"GETRequest2 test failed");
}

- (void)testPOSTRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
	NSDictionary *parameters = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest POSTRequestWithURL:URL parameters:parameters];
	NSAssert([[request POSTParameters] isEqual:parameters], @"POSTRequest test failed");
}

@end
