// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncKeyBundle.h"
#import "SyncAuthorizer.h"
#import "SyncBasicCredentials.h"


@interface SyncBasicCredentialsTestCase : XCTestCase

@end


@implementation SyncBasicCredentialsTestCase

- (void) testSyncBasicCredentials
{
    SyncBasicCredentials *credentials = [[SyncBasicCredentials alloc] initWithUsername: @"TODO" password: @"TODO" recoveryKey: @"TODO"];
    XCTAssertNotNil(credentials);
    XCTAssertNotNil(credentials.authorizer);
    XCTAssertNotNil(credentials.globalKeyBundle);
    
    // Test the Authorizer
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://127.0.0.1:8080/1.1/"]];
    XCTAssertNotNil(request);
    
    NSString *authorizationHeader = [credentials.authorizer authorizeSyncRequest: request];
    XCTAssertEqualObjects(authorizationHeader, @"Basic TODO");

    // Test the key derivation
    
    XCTAssertNotNil(credentials.globalKeyBundle.encryptionKey);
    XCTAssertNotNil(credentials.globalKeyBundle.validationKey);
}

@end
