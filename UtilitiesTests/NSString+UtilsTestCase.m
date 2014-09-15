// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSString+Utils.h"


@interface NSString_Utils : XCTestCase

@end


@implementation NSString_Utils

- (void) testRandomAlphanumericString
{
    NSString *s = [NSString randomAlphanumericStringWithLength: 8];
    XCTAssertNotNil(s);
    XCTAssertTrue([s length] == 8);
}

@end
