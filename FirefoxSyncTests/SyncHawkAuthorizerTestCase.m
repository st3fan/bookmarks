// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncHawkAuthorizer.h"


@interface SyncHawkAuthorizerTestCase : XCTestCase

@end


@implementation SyncHawkAuthorizerTestCase

- (void) testHawkAuthorizer
{
    NSString *keyIdentifier = @"someKeyIdentifier";
    NSData *key = [NSData dataWithBytes: "0123456789abcdef0123456789abcdef" length: 32];
    SyncHawkAuthorizer *authorizer = [[SyncHawkAuthorizer alloc] initWithKeyIdentifier: keyIdentifier key: key];
    XCTAssertNotNil(authorizer);
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://127.0.0.1:8080/1.1/"]];
    XCTAssertNotNil(request);
    
    NSString *authorizationHeader = [authorizer authorizeSyncRequest: request];
    XCTAssertNotNil(authorizationHeader);
    XCTAssertTrue([authorizationHeader hasPrefix: @"Hawk "]);
}

@end
