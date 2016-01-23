//
//  RequestTests.m
//  RequestUtilsTests
//
//  Created by Nick Lockwood on 11/09/2012.
//
//

#import <XCTest/XCTest.h>
#import "RequestUtils.h"


@interface RequestTests : XCTestCase

@end


@implementation RequestTests

#pragma mark Request generation

- (void)testGETRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
	NSDictionary *parameters = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest GETRequestWithURL:URL parameters:parameters];
	XCTAssertEqualObjects([request GETParameters], parameters, @"GETRequest test failed");
}

- (void)testGETRequest2
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com?foo=bar"];
	NSDictionary *parameters = [@"bar=foo" URLQueryParameters];
    NSDictionary *result = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest GETRequestWithURL:URL parameters:parameters];
	XCTAssertEqualObjects([request GETParameters], result, @"GETRequest2 test failed");
}

- (void)testGETRequest3
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com?"];
    NSDictionary *parameters = [@"foo=bar&bar=foo" URLQueryParameters];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request addGETParameters:parameters options:0];
    NSURL *result = [NSURL URLWithString:@"http://example.com?foo=bar&bar=foo"];
	XCTAssertEqualObjects([request URL], result, @"GETRequest3 test failed");
}

- (void)testPOSTRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
	NSDictionary *parameters = [@"foo=bar&bar=foo" URLQueryParameters];
	NSURLRequest *request = [NSURLRequest POSTRequestWithURL:URL parameters:parameters];
	XCTAssertEqualObjects([request POSTParameters], parameters, @"POSTRequest test failed");
}

- (void)testNonStringPOSTParams
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
	NSDictionary *parameters = @{@"foo": @1, @"bar": [NSValue valueWithRange:NSMakeRange(1, 10)]};
	NSURLRequest *request = [NSURLRequest POSTRequestWithURL:URL parameters:parameters];
    NSDictionary *result = @{@"foo": [parameters[@"foo"] description], @"bar": [parameters[@"bar"] description]};
	XCTAssertEqualObjects([request POSTParameters], result, @"POSTRequest non-strings test failed");
}

- (void)testMultipartFormRequest
{
    NSURL *URL = [NSURL URLWithString:@"http://example.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setMultipartFormDataWithBoundary:@"test-boundary"
                                  constructor:^(URLRequestMultipartFormDataConstructor *constructor) {
                                      [constructor addPartWithKey:@"foo" withValue:@"bar"];
                                      [constructor addPartWithKey:@"foo"
                                                     withFilename:@"bar.jpg"
                                                  withContentType:@"image/jpeg"
                                                        withValue:[@"bar-data" dataUsingEncoding:NSUTF8StringEncoding]];
                                  }];

    NSString *result = @"--test-boundary\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\nbar\r\n--test-boundary\r\nContent-Disposition: form-data; name=\"foo\"; filename=\"bar.jpg\"\r\nContent-Type: image/jpeg\r\n\r\nbar-data\r\n--test-boundary--\r\n";
    XCTAssertEqualObjects([[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding],
                          result,
                          @"MultipartFormRequest test failed");
}

@end
