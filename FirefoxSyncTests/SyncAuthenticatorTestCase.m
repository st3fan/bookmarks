// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#import "FXAAsyncTestHelper.h"
#import "SyncAuthenticator.h"


static NSString *SyncAuthenticatorTestCaseEmail = @"TODO";
static NSString *SyncAuthenticatorTestCasePassword = @"TODO";


@interface SyncAuthenticatorTestCase : XCTestCase
@end


@implementation SyncAuthenticatorTestCase

- (void) testDefaultAuthenticator
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    SyncAuthenticator *authenticator = [SyncAuthenticator defaultAuthenticator];
    [authenticator authenticateWithEmail: SyncAuthenticatorTestCaseEmail password: SyncAuthenticatorTestCasePassword completion:^(NSURL *endpoint, SyncHawkCredentials *credentials, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: @{@"endpoint":endpoint, @"credentials":credentials}];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    SyncHawkCredentials *credentials = [asyncTestHelper.result objectForKey: @"credentials"];
    XCTAssertNotNil(credentials);
    
    NSURL *endpoint = [asyncTestHelper.result objectForKey: @"endpoint"];
    XCTAssertNotNil(endpoint);
}

@end
