//
//  URLTests.m
//  RequestUtilsTests
//
//  Created by Tate Johnson on 28/07/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RequestUtils.h"


@interface URLTests : XCTestCase

@end

@implementation URLTests

- (void)testURLWithPath
{
	NSURL *url = [[NSURL URLWithString:@"http://local.host"] URLWithPath:@"/test"];
	XCTAssertEqualObjects([url absoluteString], @"http://local.host/test");
}

@end
