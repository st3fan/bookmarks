// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#import "FXAToken.h"

#import "SyncAuthorizer.h"
#import "SyncCredentials.h"
#import "SyncKeyBundle.h"
#import "SyncHawkCredentials.h"


@interface SyncHawkCredentialsTestCase : XCTestCase

@end


@implementation SyncHawkCredentialsTestCase

- (void) testSyncHawkCredentials
{
    NSDictionary *JSONToken = @{
        @"id": @"eyJleHBpcmVzIjogMTQyMTcyNjg1Mi43NjQzMzksICJzYWx0IjogIjhlODgyMCIsICJ1aWQiOiAxMTcsICJzZXJ2aWNlX2VudHJ5IjogImh0dHA6Ly9kYjEub2xkc3luYy5kZXYubGNpcC5vcmcife3l2BYSAa8DBtMMI_Df0LAeqV1B",
        @"key": @"RDudeXnp9IsAuNAMG7JR7aLEkzU=",
        @"uid": @117,
        @"endpoint": @"http://db1.oldsync.dev.lcip.org/1.1/117",
        @"duration": @31536000
    };
    FXAToken *token = [[FXAToken alloc] initWithJSONObject: JSONToken];

    unsigned char keyBytes[] = {
        0x6f, 0x14, 0xa6, 0x1d, 0x2c, 0x40, 0xab, 0x25, 0xa1, 0x19, 0xb2, 0x84, 0xc4, 0xd2, 0xb3, 0xb4,
        0x51, 0x0e, 0xc8, 0xaf, 0x98, 0x0b, 0xb2, 0xf4, 0x6b, 0x17, 0x2f, 0x48, 0xdd, 0x6d, 0x4c, 0x88
    };
    NSData *key = [NSData dataWithBytes: keyBytes length: sizeof keyBytes];

    SyncHawkCredentials *credentials = [[SyncHawkCredentials alloc] initWithToken: token key: key];
    XCTAssertNotNil(credentials);
    XCTAssertNotNil(credentials.authorizer);
    XCTAssertNotNil(credentials.globalKeyBundle);
    
    // Test the Authorizer
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://127.0.0.1:8080/1.1/"]];
    XCTAssertNotNil(request);
    
    NSString *authorizationHeader = [credentials.authorizer authorizeSyncRequest: request];
    XCTAssertTrue([authorizationHeader hasPrefix: @"Hawk "]);

    // Test the key derivation
    
    XCTAssertNotNil(credentials.globalKeyBundle.encryptionKey);
    XCTAssertTrue([credentials.globalKeyBundle.encryptionKey length] == 32);
    
    XCTAssertNotNil(credentials.globalKeyBundle.validationKey);
    XCTAssertTrue([credentials.globalKeyBundle.validationKey length] == 32);
}

@end
