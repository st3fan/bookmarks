// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncClient.h"
#import "SyncStatus.h"
#import "SyncCollectionStatistics.h"
#import "SyncCollection.h"
#import "SyncCredentials.h"
#import "SyncHawkCredentials.h"
#import "SyncAuthenticator.h"
#import "SimpleSyncCollection.h"
#import "FXAAsyncTestHelper.h"
#import "NSString+Utils.h"
#import "BaseSyncTestCase.h"

#import <XCTest/XCTest.h>


static NSString *Email = @"TODO";
static NSString *Password = @"TODO";


@implementation BaseSyncTestCase

- (void) setUp
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    SyncAuthenticator *authenticator = [SyncAuthenticator defaultAuthenticator];
    [authenticator authenticateWithEmail: Email password: Password completion:^(NSURL *endpoint, SyncHawkCredentials *credentials, NSError *error) {
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
    
    _credentials = credentials;
    _endpoint = endpoint;
}

- (NSString*) uniqueSyncClientIdentifier
{
    return [NSString randomAlphanumericStringWithLength: 16];
}

@end
