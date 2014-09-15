// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "RSAKeyPair.h"
#import "MockMyIDTokenFactory.h"
#import "BIDRemoteVerifier.h"
#import "FXAAsyncTestHelper.h"
#import <XCTest/XCTest.h>



static NSString *kTestUsername = @"test";
static NSString *kTestCertificateIssuer = @"mockmyid.com";
static NSString *kTestEmail = @"test@mockmyid.com";
static NSString *kTestAudience = @"http://localhost:8080";

static const NSString *kVerifierEndpoint = @"https://verifier.login.persona.org/verify";


@interface MockMyIDTokenFactoryTest : XCTestCase

@end


@implementation MockMyIDTokenFactoryTest

- (void) testRSASuccess
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 1024];
    NSString *assertion = [[MockMyIDTokenFactory defaultFactory] createAssertionWithKeyPair: keyPair username: kTestUsername audience: kTestAudience];
    XCTAssertNotNil(assertion);
    
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    //BIDRemoteVerifier *verifier = [[BIDRemoteVerifier alloc] initWithEndpoint: [NSURL URLWithString: @"http://sync.local:10000/verify"]];
    BIDRemoteVerifier *verifier = [BIDRemoteVerifier defaultRemoteVerifier];
    [verifier verifyAssertion: assertion audience:kTestAudience completionHandler:^(BIDVerifierReceipt *verifierReceipt, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: verifierReceipt];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    BIDVerifierReceipt *receipt = asyncTestHelper.result;
    XCTAssertTrue(receipt.okay);
    XCTAssertEqualObjects(receipt.email, @"test@mockmyid.com");
    XCTAssertEqualObjects(receipt.audience, @"http://localhost:8080");
    XCTAssertNotNil(receipt.expires);
    XCTAssertEqualObjects(receipt.issuer, @"mockmyid.com");
}

@end
