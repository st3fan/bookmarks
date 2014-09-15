// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSData+Base32.h"


@interface NSData_Base32Test : XCTestCase
@end


@implementation NSData_Base32Test

- (void) testBase32EncodingTestVectors
{
    XCTAssertEqualObjects(@"", [[NSMutableData data] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MY======", [[@"f" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MZXQ====", [[@"fo" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MZXW6===", [[@"foo" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MZXW6YQ=", [[@"foob" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MZXW6YTB", [[@"fooba" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"MZXW6YTBOI======", [[@"foobar" dataUsingEncoding: NSUTF8StringEncoding] base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault]);
}

- (void) testBase32DecodingTestVectors
{
    XCTAssertEqualObjects([@"" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"f" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MY======" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fo" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MZXQ====" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foo" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MZXW6===" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foob" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MZXW6YQ=" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fooba" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MZXW6YTB" options: NSDataBase32DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foobar" dataUsingEncoding: NSUTF8StringEncoding], [[NSData alloc] initWithBase32EncodedString: @"MZXW6YTBOI======" options: NSDataBase32DecodingOptionsDefault]);
}

@end
