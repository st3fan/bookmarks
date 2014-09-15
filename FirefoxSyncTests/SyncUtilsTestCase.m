// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncKeyBundle.h"
#import "SyncUtils.h"


@interface SyncUtilsTestCase : XCTestCase

@end


@implementation SyncUtilsTestCase

- (void) testEncodeUsername
{
    XCTAssertEqualObjects(
        [SyncUtils encodeUsername: @"sarentz@mozilla.com"],
        @"plsgqut6mdwlc2vv3dmf4wld2u5xm3bj"
    );
}

- (void) testDecodeSecret
{
    XCTAssertEqualObjects(
        [SyncUtils decodeRecoveryKey: @"mzxw6ytb9jrgcztpn5rgc4tcme"],
        [@"foobarbafoobarba" dataUsingEncoding: NSUTF8StringEncoding]
    );
}

- (void) testDecodeDecryptPayload
{
    NSDictionary *encryptedPayload = @{
        @"ciphertext": @"iHsSl8N0pC081LwffmtijWto4ZvUPGPltF7PpAV6u+vgSnZElTpUTxNxIgNVzh8Aid0dhyLEwJ+xVv5LaSr5JmNY7YwUHi8t1WIv0UHSMR+hDU4/853ALS/KuA8/FmqocebEuaKKrOC9sjkr8iI5wjX8TFzbYEA0vSR1DUXUrvAbOH+Fwyi+t05ydh5gMVnlBVxuplKIHgdDm4h8Gygr4g==",
        @"hmac": @"08571cb4a6a7e6ab76721f50021861a3430c8cef29e099e155af7cc5c737442f",
        @"IV": @"3hFxkWuX/RDVvPGspy36+A=="
    };

    unsigned char key[] = {
        0x6f, 0x14, 0xa6, 0x1d, 0x2c, 0x40, 0xab, 0x25, 0xa1, 0x19, 0xb2, 0x84, 0xc4, 0xd2, 0xb3, 0xb4,
        0x51, 0x0e, 0xc8, 0xaf, 0x98, 0x0b, 0xb2, 0xf4, 0x6b, 0x17, 0x2f, 0x48, 0xdd, 0x6d, 0x4c, 0x88
    };

    SyncKeyBundle *keyBundle = [[SyncKeyBundle alloc] initWithKey: [NSData dataWithBytes: key length: sizeof key]];
    
    //
    
    NSDictionary *decryptedPayload = [SyncUtils decryptPayload: encryptedPayload withKeyBundle: keyBundle];
    XCTAssertNotNil(decryptedPayload);

    XCTAssertNotNil(decryptedPayload[@"collection"]);
    XCTAssertNotNil(decryptedPayload[@"id"]);

    XCTAssertNotNil(decryptedPayload[@"collections"]);
    XCTAssertNotNil(decryptedPayload[@"default"]);
}

- (void) testDecodeDecryptPayloadWithBadKey
{
    NSDictionary *encryptedPayload = @{
        @"ciphertext": @"iHsSl8N0pC081LwffmtijWto4ZvUPGPltF7PpAV6u+vgSnZElTpUTxNxIgNVzh8Aid0dhyLEwJ+xVv5LaSr5JmNY7YwUHi8t1WIv0UHSMR+hDU4/853ALS/KuA8/FmqocebEuaKKrOC9sjkr8iI5wjX8TFzbYEA0vSR1DUXUrvAbOH+Fwyi+t05ydh5gMVnlBVxuplKIHgdDm4h8Gygr4g==",
        @"hmac": @"08571cb4a6a7e6ab76721f50021861a3430c8cef29e099e155af7cc5c737442f",
        @"IV": @"3hFxkWuX/RDVvPGspy36+A=="
    };

    unsigned char key[] = {
        0x6f, 0x14, 0xa6, 0x1d, 0x2c, 0x40, 0xab, 0x25, 0xa1, 0x19, 0xb2, 0x84, 0xc4, 0xd2, 0xb3, 0xb4,
        0x51, 0x0e, 0xc8, 0xaf, 0x98, 0x0b, 0xb2, 0xf4, 0x6b, 0x17, 0x2f, 0x48, 0xdd, 0x6d, 0x4c, 0x42
    };

    SyncKeyBundle *keyBundle = [[SyncKeyBundle alloc] initWithKey: [NSData dataWithBytes: key length: sizeof key]];
    
    //
    
    NSDictionary *decryptedPayload = [SyncUtils decryptPayload: encryptedPayload withKeyBundle: keyBundle];
    XCTAssertNil(decryptedPayload);
}

- (void) testDecodeDecryptPayloadWithBadHMAC
{
    NSDictionary *encryptedPayload = @{
        @"ciphertext": @"iHsSl8N0pC081LwffmtijWto4ZvUPGPltF7PpAV6u+vgSnZElTpUTxNxIgNVzh8Aid0dhyLEwJ+xVv5LaSr5JmNY7YwUHi8t1WIv0UHSMR+hDU4/853ALS/KuA8/FmqocebEuaKKrOC9sjkr8iI5wjX8TFzbYEA0vSR1DUXUrvAbOH+Fwyi+t05ydh5gMVnlBVxuplKIHgdDm4h8Gygr4g==",
        @"hmac": @"08571cb4a6a7e6ab76721f50021861a3430c8cef29e099e155af7cc5c737beef",
        @"IV": @"3hFxkWuX/RDVvPGspy36+A=="
    };

    unsigned char key[] = {
        0x6f, 0x14, 0xa6, 0x1d, 0x2c, 0x40, 0xab, 0x25, 0xa1, 0x19, 0xb2, 0x84, 0xc4, 0xd2, 0xb3, 0xb4,
        0x51, 0x0e, 0xc8, 0xaf, 0x98, 0x0b, 0xb2, 0xf4, 0x6b, 0x17, 0x2f, 0x48, 0xdd, 0x6d, 0x4c, 0x42
    };

    SyncKeyBundle *keyBundle = [[SyncKeyBundle alloc] initWithKey: [NSData dataWithBytes: key length: sizeof key]];
    
    //
    
    NSDictionary *decryptedPayload = [SyncUtils decryptPayload: encryptedPayload withKeyBundle: keyBundle];
    XCTAssertNil(decryptedPayload);
}

@end
