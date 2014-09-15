// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncKeyBundle.h"
#import "SyncRecord.h"


@interface SyncRecordTestCase : XCTestCase

@end


@implementation SyncRecordTestCase

- (void) testSyncRecord
{
     NSDictionary *object = @{
        @"username": @"12410150",
        @"payload": @"{\"syncID\":\"fdJRVBcVCHh1\",\"storageVersion\":5,\"engines\":{\"clients\":{\"version\":1,\"syncID\":\"ARV4P8Vb-_wQ\"},\"bookmarks\":{\"version\":2,\"syncID\":\"qdA1iXgSXPgo\"},\"forms\":{\"version\":1,\"syncID\":\"FccDJxey41C2\"},\"history\":{\"version\":1,\"syncID\":\"pmh8oViljz8n\"},\"passwords\":{\"version\":1,\"syncID\":\"nog7TsuxXXsz\"},\"prefs\":{\"version\":2,\"syncID\":\"QtU7YyySM7cQ\"},\"tabs\":{\"version\":1,\"syncID\":\"YthgvUxqTWNd\"},\"addons\":{\"version\":1,\"syncID\":\"p3h5-W9-4wMK\"}}}",
        @"id": @"global",
        @"modified": @1387311376.37
     };
    
     SyncRecord *record = [[SyncRecord alloc] initWithJSONRepresentation: object];
     XCTAssertNotNil(record);
     XCTAssertNotNil(record.payload);
     XCTAssertNotNil(record.identifier);
     XCTAssertNotNil(record.modified);
}

- (void) testEncryptedSyncRecordWithoutKey
{
    NSDictionary *object = @{
        @"payload": @"{\"ciphertext\":\"WaPcz56YGK5w7m07NUJp+Tv6+sg0cItynYtvhaq2weq+Jz/p47Nu2Feyy3ntB+HcUtZkASHiastAYlqeW5N8A+a3Ka2KlL7/N7Knkb/Y1i0OCC+D7YgPw8M65g7R7Cen2K1xohVhO6WjcDVbGJfn1yf7uCY104aggKA4Rx0t1hEtF31ax06LN3fCVNFxp9pHS1Vm8U+8jeX4jKfNH+mSEQ==\",\"IV\":\"CcguNksnbsMXFbIH5TUWHA==\",\"hmac\":\"7615d80cd0da7459106220eb215b50b012d5d866c00d796e8a381b07c69840c8\"}",
        @"id": @"keys",
        @"modified": @1387311362.27
    };

     SyncRecord *record = [[SyncRecord alloc] initWithJSONRepresentation: object];
     XCTAssertNil(record);
}

- (void) testEncryptedSyncRecord
{
    unsigned char key[] = {
        0x6f, 0x14, 0xa6, 0x1d, 0x2c, 0x40, 0xab, 0x25, 0xa1, 0x19, 0xb2, 0x84, 0xc4, 0xd2, 0xb3, 0xb4,
        0x51, 0x0e, 0xc8, 0xaf, 0x98, 0x0b, 0xb2, 0xf4, 0x6b, 0x17, 0x2f, 0x48, 0xdd, 0x6d, 0x4c, 0x88
    };
    
    SyncKeyBundle *keyBundle = [[SyncKeyBundle alloc] initWithKey: [NSData dataWithBytes: key length: sizeof key]];
    
    NSDictionary *object = @{
        @"id": @"keys",
        @"modified": @1390144653.39,
        @"payload": @"{\"ciphertext\":\"iHsSl8N0pC081LwffmtijWto4ZvUPGPltF7PpAV6u+vgSnZElTpUTxNxIgNVzh8Aid0dhyLEwJ+xVv5LaSr5JmNY7YwUHi8t1WIv0UHSMR+hDU4\\/853ALS\\/KuA8\\/FmqocebEuaKKrOC9sjkr8iI5wjX8TFzbYEA0vSR1DUXUrvAbOH+Fwyi+t05ydh5gMVnlBVxuplKIHgdDm4h8Gygr4g==\",\"IV\":\"3hFxkWuX\\/RDVvPGspy36+A==\",\"hmac\":\"08571cb4a6a7e6ab76721f50021861a3430c8cef29e099e155af7cc5c737442f\"}"
    };
    
    SyncRecord *record = [[SyncRecord alloc] initWithJSONRepresentation: object keyBundle: keyBundle];
    XCTAssertNotNil(record);
}

@end
