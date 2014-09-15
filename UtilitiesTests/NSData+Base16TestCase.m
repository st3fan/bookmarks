// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSData+Base16.h"


@interface NSData_Base16Test : XCTestCase

@end


@implementation NSData_Base16Test

- (void) testBase16EncodingWithTestVectors
{
    XCTAssertEqualObjects(@"", [[@"" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"66", [[@"f" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"666F", [[@"fo" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"666F6F", [[@"foo" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"666F6F62", [[@"foob" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"666F6F6261", [[@"fooba" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);
    XCTAssertEqualObjects(@"666F6F626172", [[@"foobar" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]);

    XCTAssertEqualObjects(@"", [[@"" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"66", [[@"f" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"666f", [[@"fo" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"666f6f", [[@"foo" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"666f6f62", [[@"foob" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"666f6f6261", [[@"fooba" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
    XCTAssertEqualObjects(@"666f6f626172", [[@"foobar" dataUsingEncoding: NSUTF8StringEncoding] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase]);
}

- (void) testBase16DecodingWithTestVectors
{
    XCTAssertEqualObjects([NSData dataWithBytes: "\x01\x23\x45\x67\x89\xab\xcd\xef" length: 8],
        [[NSData alloc] initWithBase16EncodedString:@"0123456789abcdef" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([NSData dataWithBytes: "\x01\x23\x45\x67\x89\xab\xcd\xef" length: 8],
        [[NSData alloc] initWithBase16EncodedString:@"0123456789ABCDEF" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([NSData dataWithBytes: "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xaa\xbb\xcc\xdd\xee\xff" length: 16],
        [[NSData alloc] initWithBase16EncodedString:@"00112233445566778899AABBCCDDEEFF" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([NSData dataWithBytes: "\x00\x11\x22\x33\x44\x55\x66\x77\x88\x99\xaa\xbb\xcc\xdd\xee\xff" length: 16],
        [[NSData alloc] initWithBase16EncodedString:@"00112233445566778899aabbccddeeff" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([NSData dataWithBytes: "" length: 0],
        [[NSData alloc] initWithBase16EncodedString:@"" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertNil([[NSData alloc] initWithBase16EncodedString:@"a" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertNil([[NSData alloc] initWithBase16EncodedString:@"nothex" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([@"" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"f" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"66" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fo" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666F" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foo" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666F6F" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foob" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666F6F62" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fooba" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666F6F6261" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foobar" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666F6F626172" options:NSDataBase16DecodingOptionsDefault]);

    XCTAssertEqualObjects([@"" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"f" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"66" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fo" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666f" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foo" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666f6f" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foob" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666f6f62" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"fooba" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666f6f6261" options:NSDataBase16DecodingOptionsDefault]);
    XCTAssertEqualObjects([@"foobar" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSData alloc] initWithBase16EncodedString:@"666f6f626172" options:NSDataBase16DecodingOptionsDefault]);
}

@end
