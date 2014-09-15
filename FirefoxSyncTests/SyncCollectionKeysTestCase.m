// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncKeyBundle.h"
#import "SyncCollectionKeys.h"


@interface SyncCollectionKeysTestCase : XCTestCase

@end


@implementation SyncCollectionKeysTestCase

- (void) testSimpleCollectionKeys
{
    unsigned char expectedEncryptionKey[] = {
        0x1b, 0xa4, 0x86, 0x05, 0x4b, 0xda, 0x2c, 0x7f, 0x15, 0xd0, 0x41, 0x65, 0xc0, 0x69, 0x02, 0x73,
        0x47, 0x20, 0x8d, 0x49, 0x1d, 0xfe, 0x7b, 0x24, 0x30, 0x98, 0xc6, 0x43, 0xd6, 0x6f, 0xf6, 0x2f
    };
    
    unsigned char expectedValidationKey[] = {
        0x4c, 0x43, 0x9c, 0xe9, 0x2a, 0x68, 0x98, 0x6a, 0x81, 0x3b, 0x67, 0x0f, 0x9c, 0x60, 0x2b, 0x2f,
        0xb2, 0xa2, 0x61, 0x30, 0x51, 0xd1, 0x7f, 0x67, 0x34, 0xc4, 0x11, 0xe6, 0xe4, 0xb1, 0x25, 0xe8
    };

    NSDictionary *object = @{
        @"collection": @"crypto",
        @"id": @"keys",
        @"collections": @{},
        @"default": @[ @"G6SGBUvaLH8V0EFlwGkCc0cgjUkd/nskMJjGQ9Zv9i8=", @"TEOc6SpomGqBO2cPnGArL7KiYTBR0X9nNMQR5uSxJeg=" ],
    };
    
    SyncCollectionKeys *collectionKeys = [[SyncCollectionKeys alloc] initWithJSONRepresentation: object];
    XCTAssertNotNil(collectionKeys);
    
    SyncKeyBundle *keyBundle = [collectionKeys keyBundleForCollection: @"bookmarks"];
    XCTAssertNotNil(keyBundle);
    
    XCTAssertEqualObjects(
        keyBundle.encryptionKey,
        [NSData dataWithBytes: expectedEncryptionKey length: sizeof expectedEncryptionKey]
    );

    XCTAssertEqualObjects(
        keyBundle.validationKey,
        [NSData dataWithBytes: expectedValidationKey length: sizeof expectedValidationKey]
    );
}

- (void) testNonDefaultCollectionKeys
{
    unsigned char expectedEncryptionKey[] = {
        0x1b, 0xa4, 0x86, 0x05, 0x4b, 0xda, 0x2c, 0x7f, 0x15, 0xd0, 0x41, 0x65, 0xc0, 0x69, 0x02, 0x73,
        0x47, 0x20, 0x8d, 0x49, 0x1d, 0xfe, 0x7b, 0x24, 0x30, 0x98, 0xc6, 0x43, 0xd6, 0x6f, 0xf6, 0x2f
    };
    
    unsigned char expectedValidationKey[] = {
        0x4c, 0x43, 0x9c, 0xe9, 0x2a, 0x68, 0x98, 0x6a, 0x81, 0x3b, 0x67, 0x0f, 0x9c, 0x60, 0x2b, 0x2f,
        0xb2, 0xa2, 0x61, 0x30, 0x51, 0xd1, 0x7f, 0x67, 0x34, 0xc4, 0x11, 0xe6, 0xe4, 0xb1, 0x25, 0xe8
    };
    
    unsigned char expectedBookmarksEncryptionKey[] = {
        0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6f, 0x70, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68,
        0x71, 0x77, 0x65, 0x72, 0x74, 0x79, 0x75, 0x69, 0x6f, 0x70, 0x61, 0x73, 0x64, 0x66, 0x67, 0x68
    };
    
    unsigned char expectedBookmarksValidationKey[] = {
        0x7a, 0x78, 0x63, 0x76, 0x62, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x68, 0x67, 0x66, 0x64, 0x73, 0x61,
        0x7a, 0x78, 0x63, 0x76, 0x62, 0x6e, 0x6d, 0x6c, 0x6b, 0x6a, 0x68, 0x67, 0x66, 0x64, 0x73, 0x61
    };

    NSDictionary *object = @{
        @"collection": @"crypto",
        @"id": @"keys",
        @"collections": @{
            @"bookmarks": @[@"cXdlcnR5dWlvcGFzZGZnaHF3ZXJ0eXVpb3Bhc2RmZ2g=", @"enhjdmJubWxramhnZmRzYXp4Y3Zibm1sa2poZ2Zkc2E="]
        },
        @"default": @[ @"G6SGBUvaLH8V0EFlwGkCc0cgjUkd/nskMJjGQ9Zv9i8=", @"TEOc6SpomGqBO2cPnGArL7KiYTBR0X9nNMQR5uSxJeg=" ],
    };
    
    SyncCollectionKeys *collectionKeys = [[SyncCollectionKeys alloc] initWithJSONRepresentation: object];
    XCTAssertNotNil(collectionKeys);

    //
    
    SyncKeyBundle *keyBundle = [collectionKeys keyBundleForCollection: @"history"];
    XCTAssertNotNil(keyBundle);
    
    XCTAssertEqualObjects(
        keyBundle.encryptionKey,
        [NSData dataWithBytes: expectedEncryptionKey length: sizeof expectedEncryptionKey]
    );

    XCTAssertEqualObjects(
        keyBundle.validationKey,
        [NSData dataWithBytes: expectedValidationKey length: sizeof expectedValidationKey]
    );
    
    //

    keyBundle = [collectionKeys keyBundleForCollection: @"bookmarks"];
    XCTAssertNotNil(keyBundle);
    
    XCTAssertEqualObjects(
        keyBundle.encryptionKey,
        [NSData dataWithBytes: expectedBookmarksEncryptionKey length: sizeof expectedBookmarksEncryptionKey]
    );

    XCTAssertEqualObjects(
        keyBundle.validationKey,
        [NSData dataWithBytes: expectedBookmarksValidationKey length: sizeof expectedBookmarksValidationKey]
    );
}

@end
