// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSData+Utils.h"


@interface NSData_UtilsTest : XCTestCase

@end


@implementation NSData_UtilsTest

- (void)testDataWithDatas
{
    NSData *data1 = [@"Hello" dataUsingEncoding: NSUTF8StringEncoding];
    NSData *data2 = [@"World" dataUsingEncoding: NSUTF8StringEncoding];
    
    NSData *t1 = [NSData dataByAppendingDatas: @[]];
    XCTAssertNotNil(t1);
    XCTAssertTrue([t1 length] == 0);

    NSData *t2 = [NSData dataByAppendingDatas: @[data1]];
    XCTAssertNotNil(t2);
    XCTAssertEqualObjects(t2, data1);
    
    NSData *t3 = [NSData dataByAppendingDatas: @[data1, data2]];
    XCTAssertNotNil(t3);
    XCTAssertEqualObjects(t3, [@"HelloWorld" dataUsingEncoding: NSUTF8StringEncoding]);
}

- (void) testDataLeftZeroPaddedToLength
{
    NSData *data = [NSData dataWithBytes: "\x11\x22\x33\x44" length: 4];
    
    NSData *padded1 = [data dataLeftZeroPaddedToLength: 8];
    NSData *expected1 = [NSData dataWithBytes: "\x00\x00\x00\x00\x11\x22\x33\x44" length: 8];
    XCTAssertNotNil(padded1);
    XCTAssertEqualObjects(padded1, expected1);

    NSData *padded2 = [data dataLeftZeroPaddedToLength: 2];
    NSData *expected2 = [NSData dataWithBytes: "\x11\x22\x33\x44" length: 4];
    XCTAssertNotNil(padded2);
    XCTAssertEqualObjects(padded2, expected2);
}

- (void) testRightZeroPaddedToLength
{
    NSData *data = [NSData dataWithBytes: "\x11\x22\x33\x44" length: 4];
    
    NSData *padded1 = [data dataRightZeroPaddedToLength: 8];
    NSData *expected1 = [NSData dataWithBytes: "\x11\x22\x33\x44\x00\x00\x00\x00" length: 8];
    XCTAssertNotNil(padded1);
    XCTAssertEqualObjects(padded1, expected1);

    NSData *padded2 = [data dataRightZeroPaddedToLength: 2];
    NSData *expected2 = [NSData dataWithBytes: "\x11\x22\x33\x44" length: 4];
    XCTAssertNotNil(padded2);
    XCTAssertEqualObjects(padded2, expected2);
}

- (void) testBase64URLEncoding
{
    // Make sure no padding is added

    XCTAssertEqualObjects(
        [[@"any carnal pleasure." dataUsingEncoding: NSUTF8StringEncoding] base64URLEncodedStringWithOptions: 0],
        @"YW55IGNhcm5hbCBwbGVhc3VyZS4"
    );

    XCTAssertEqualObjects(
        [[@"any carnal pleasure" dataUsingEncoding: NSUTF8StringEncoding] base64URLEncodedStringWithOptions: 0],
        @"YW55IGNhcm5hbCBwbGVhc3VyZQ"
    );

    XCTAssertEqualObjects(
        [[@"any carnal pleasur" dataUsingEncoding: NSUTF8StringEncoding] base64URLEncodedStringWithOptions: 0],
        @"YW55IGNhcm5hbCBwbGVhc3Vy"
    );

    XCTAssertEqualObjects(
        [[@"any carnal pleasu" dataUsingEncoding: NSUTF8StringEncoding] base64URLEncodedStringWithOptions: 0],
        @"YW55IGNhcm5hbCBwbGVhc3U"
    );

    XCTAssertEqualObjects(
        [[@"any carnal pleas" dataUsingEncoding: NSUTF8StringEncoding] base64URLEncodedStringWithOptions: 0],
        @"YW55IGNhcm5hbCBwbGVhcw"
    );
}

- (void) testBase64URLEncodeCharacterSet
{
    unsigned char data[] = {
        0x6b, 0xf8, 0xd8, 0xef, 0xc8, 0xac, 0x18, 0x75, 0x50, 0xf9, 0xd3, 0xa0, 0xdd, 0x98, 0x64, 0x36, 0x03, 0x42, 0xb0, 0x0c,
        0x23, 0x23, 0x18, 0xca, 0x75, 0x35, 0x6d, 0xfe, 0x17, 0x74, 0xb3, 0xe3, 0xd6, 0x75, 0x60, 0x81, 0xf5, 0xd9, 0xdb, 0xa9
    };
    
    XCTAssertEqualObjects(
        [[NSData dataWithBytes: data length: sizeof data] base64URLEncodedStringWithOptions: 0],
        @"a_jY78isGHVQ-dOg3ZhkNgNCsAwjIxjKdTVt_hd0s-PWdWCB9dnbqQ"
    );
}

- (void) testBase64URLDecoding
{
    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"YW55IGNhcm5hbCBwbGVhc3VyZS4" options: 0],
        [@"any carnal pleasure." dataUsingEncoding: NSUTF8StringEncoding]
    );

    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"YW55IGNhcm5hbCBwbGVhc3VyZQ" options: 0],
        [@"any carnal pleasure" dataUsingEncoding: NSUTF8StringEncoding]
    );

    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"YW55IGNhcm5hbCBwbGVhc3Vy" options: 0],
        [@"any carnal pleasur" dataUsingEncoding: NSUTF8StringEncoding]
    );

    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"YW55IGNhcm5hbCBwbGVhc3U" options: 0],
        [@"any carnal pleasu" dataUsingEncoding: NSUTF8StringEncoding]
    );

    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"YW55IGNhcm5hbCBwbGVhcw" options: 0],
        [@"any carnal pleas" dataUsingEncoding: NSUTF8StringEncoding]
    );
}

- (void) testBase64URLDecodingCharacterSet
{
    unsigned char data[] = {
        0x6b, 0xf8, 0xd8, 0xef, 0xc8, 0xac, 0x18, 0x75, 0x50, 0xf9, 0xd3, 0xa0, 0xdd, 0x98, 0x64, 0x36, 0x03, 0x42, 0xb0, 0x0c,
        0x23, 0x23, 0x18, 0xca, 0x75, 0x35, 0x6d, 0xfe, 0x17, 0x74, 0xb3, 0xe3, 0xd6, 0x75, 0x60, 0x81, 0xf5, 0xd9, 0xdb, 0xa9
    };
    
    XCTAssertEqualObjects(
        [[NSData alloc] initWithBase64URLEncodedString: @"a_jY78isGHVQ-dOg3ZhkNgNCsAwjIxjKdTVt_hd0s-PWdWCB9dnbqQ" options: 0],
        [NSData dataWithBytes: data length: sizeof data]
    );
}

@end
