// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "SyncBasicAuthorizer.h"


@interface SyncBasicAuthorizerTestCase : XCTestCase

@end


@implementation SyncBasicAuthorizerTestCase

- (void) testBasicAuthorizer
{
    SyncBasicAuthorizer *basicAuthorizer = [[SyncBasicAuthorizer alloc] initWithUsername: @"" password: @""]; // TODO: Fill me in
    XCTAssertNotNil(basicAuthorizer);
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://127.0.0.1:8080/1.1/"]];
    XCTAssertNotNil(request);
    
    NSString *authorizationHeader = [basicAuthorizer authorizeSyncRequest: request];
    XCTAssertEqualObjects(authorizationHeader, @"Basic TODO FILL ME IN");
}

@end
