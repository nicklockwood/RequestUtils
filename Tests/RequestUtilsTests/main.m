//
//  main.m
//  URLUtilsTests
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringTests.h"
#import "RequestTests.h"


int main (int argc, const char * argv[])
{
    @autoreleasepool 
	{
        //test string functions
        [[[StringTests alloc] init] runTests];
        
        //test request functions
        [[[RequestTests alloc] init] runTests];
    }
    return 0;
}

