// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSData+Base16.h"
#import "FXAAsyncTestHelper.h"
#import "FXAKeyStretcher.h"

@interface FXAPasswordStretcherTest : XCTestCase

@end

@implementation FXAPasswordStretcherTest

- (void) testPasswordStretcher
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    NSDictionary *parameters = @{
        @"PBKDF2_rounds_1": @20000,
        @"PBKDF2_rounds_2": @20000,
        @"salt": @"d8f159adc6d4e2e65bb97d7b8acee11c00000000000000000000000000000000",
        @"scrypt_N": @65536,
        @"scrypt_r": @8,
        @"scrypt_p": @1,
        @"type": @"PBKDF2/scrypt/PBKDF2/v1"
    };
    
    NSString *username = @"TODO";
    NSString *password = @"TODO";

    FXAKeyStretcher *keyStretcher = [[FXAKeyStretcher alloc] initWithJSONParameters: parameters];
    XCTAssertNotNil(keyStretcher);

    [keyStretcher stretchUsername: username password: password completionHandler: ^(NSData *stretchedPassword, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: stretchedPassword];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    NSData *expectedStretchedPassword = [[NSData alloc] initWithBase16EncodedString: @"0217f51b9b4fc9fae4521a296a1b032113c2fa70d3960f372fef0ecc6137fb7b" options: NSDataBase16DecodingOptionsDefault];
    NSData *actualStretchedPassword = asyncTestHelper.result;
    XCTAssertEqualObjects(actualStretchedPassword, expectedStretchedPassword);
}

@end
