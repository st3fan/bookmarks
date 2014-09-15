// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#import "FXAAsyncTestHelper.h"
#import "FXAClient.h"
#import "FXAAuthenticator.h"


static NSString *FXAAuthenticatorTestCaseEmail = @""; // TODO: Fill me in
static NSString *FXAAuthenticatorTestCasePassword = @""; // TODO: Fill me in


@interface FXAAuthenticatorTestCase : XCTestCase

@end


@implementation FXAAuthenticatorTestCase

- (void)testDefaultAuthenticator
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAAuthenticator *authenticator = [FXAAuthenticator defaultAuthenticator];
    [authenticator authenticateWithEmail:FXAAuthenticatorTestCaseEmail password:FXAAuthenticatorTestCasePassword completion:^(RSAKeyPair *keyPair, FXAKeysData *keys, FXACertificate *certificate, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: @{@"keyPair":keyPair, @"keys":keys, @"certificate":certificate}];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    RSAKeyPair *keyPair = [asyncTestHelper.result objectForKey: @"keyPair"];
    XCTAssertNotNil(keyPair);
    
    FXAKeysData *keys = [asyncTestHelper.result objectForKey: @"keys"];
    XCTAssertNotNil(keys);
    
    FXACertificate *certificate = [asyncTestHelper.result objectForKey: @"certificate"];
    XCTAssertNotNil(certificate);
}

- (void) testWithIncorrectPassword
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAAuthenticator *authenticator = [FXAAuthenticator defaultAuthenticator];
    [authenticator authenticateWithEmail:FXAAuthenticatorTestCaseEmail password: @"thisisnotcorrect" completion:^(RSAKeyPair *keyPair, FXAKeysData *keys, FXACertificate *certificate, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: @{@"keyPair":keyPair, @"keys":keys, @"certificate":certificate}];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.result);
    XCTAssertNotNil(asyncTestHelper.error);
    
    XCTAssertEqualObjects(asyncTestHelper.error.domain, FXAErrorDomain);
    XCTAssertEqual(asyncTestHelper.error.code, FXAErrorCodeIncorrectPassword);
}

@end
