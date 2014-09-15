// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "FXATokenClient.h"
#import "FXAToken.h"
#import "RSAKeyPair.h"
#import "MockMyIDTokenFactory.h"
#import "FXAAsyncTestHelper.h"
#import <XCTest/XCTest.h>


static NSString *kProductionTestUsername = @"test";
static NSString *kProductionkTestTokenServerEndpoint = @"https://token.services.mozilla.com/";
static NSString *kProductionTestAudience = @"https://token.services.mozilla.com";

static NSString *kStagingTestUsername = @"test";
static NSString *kStagingTestTokenServerEndpoint = @"https://tokenserver.sateh.com";
static NSString *kStagingTestAudience = @"https://tokenserver.sateh.com";

static NSString *kDevelopmentTestUsername = @"test";
static NSString *kDevelopmentTestTokenServerEndpoint = @"https://token.dev.lcip.org";
static NSString *kDevelopmentTestAudience = @"https://token.dev.lcip.org";

static NSString *kSyncApplicationName = @"sync";
static NSString *kSyncApplicationVersion = @"1.5";

@interface FXATokenClientTest : XCTestCase
@end


@implementation FXATokenClientTest

- (void) runRemoteSuccessTestWithUsername: (NSString*) username endpoint: (NSString*) endpoint audience: (NSString*) audience clientState: (NSString*) clientState
{
    FXATokenClient *client = [[FXATokenClient new] initWithEndpoint: [NSURL URLWithString: endpoint]];
    XCTAssertNotNil(client);
    
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 1024];
    XCTAssertNotNil(keyPair);
    
    NSString *assertion = [[MockMyIDTokenFactory defaultFactory] createAssertionWithKeyPair: keyPair username: username audience: audience];
    XCTAssertNotNil(assertion);

    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    [client getTokenForApplication: kSyncApplicationName version: kSyncApplicationVersion assertion: assertion clientState: clientState completionHandler:^(FXAToken *token, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: token];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    FXAToken *token = asyncTestHelper.result;
    XCTAssertNotNil(token.identifier);
    XCTAssertNotNil(token.key);
    XCTAssertNotNil(token.uid);
    XCTAssertNotNil(token.endpoint);

    //XCTAssertEqualObjects([kTestEndpoint stringByAppendingString: [token.uid stringValue]], token.endpoint);
}

//- (void) testProductionRemoteSuccess
//{
//    [self runRemoteSuccessTestWithUsername: kProductionTestUsername endpoint: kProductionkTestTokenServerEndpoint audience: kProductionTestAudience clientState: @""];
//}

- (void) testStagingRemoteSuccess
{
    [self runRemoteSuccessTestWithUsername: kStagingTestUsername endpoint: kStagingTestTokenServerEndpoint audience: kStagingTestAudience clientState: @""];
}
//
//- (void) testDevelopmentRemoteSuccess
//{
//    [self runRemoteSuccessTestWithUsername: kDevelopmentTestUsername endpoint: kDevelopmentTestTokenServerEndpoint audience: kDevelopmentTestAudience clientState: @""];
//}

@end
