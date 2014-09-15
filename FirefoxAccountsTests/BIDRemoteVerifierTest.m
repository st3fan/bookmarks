// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "BIDRemoteVerifier.h"
#import "RSAKeyPair.h"
#import "MockMyIDTokenFactory.h"
#import "FXAAsyncTestHelper.h"
#import <XCTest/XCTest.h>


static NSString *kTestUsername = @"test";
static NSString *kTestCertificateIssuer = @"mockmyid.com";
static NSString *kTestEmail = @"test@mockmyid.com";
static NSString *kTestAudience = @"http://localhost:8080";


@interface BIDRemoteVerifierTest : XCTestCase
@end


@implementation BIDRemoteVerifierTest

- (void) testCreateDefaultVerifier
{
    BIDRemoteVerifier *verifier = [BIDRemoteVerifier defaultRemoteVerifier];
    XCTAssertNotNil(verifier);
}

- (void) testCreateCustomVerifier
{
    BIDRemoteVerifier *verifier = [[BIDRemoteVerifier alloc] initWithEndpoint: [NSURL URLWithString: @"https://verifier.sateh.com/verify"]];
    XCTAssertNotNil(verifier);
}

- (void) testSuccessfulVerification
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 1024];
    NSString *assertion = [[MockMyIDTokenFactory defaultFactory] createAssertionWithKeyPair: keyPair username: kTestUsername audience: kTestAudience];
    XCTAssertNotNil(assertion);
    
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    BIDRemoteVerifier *verifier = [[BIDRemoteVerifier alloc] initWithEndpoint: [NSURL URLWithString: @"https://verifier.sateh.com/verify"]];
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

- (void) testFailedVerification
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 1024];
    NSString *assertion = [[MockMyIDTokenFactory defaultFactory] createAssertionWithKeyPair: keyPair username: @"test@foomyidfoo.com" audience: kTestAudience];
    XCTAssertNotNil(assertion);
    
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    BIDRemoteVerifier *verifier = [[BIDRemoteVerifier alloc] initWithEndpoint: [NSURL URLWithString: @"https://verifier.sateh.com/verify"]];
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
    XCTAssertFalse(receipt.okay);
    XCTAssertNotNil(receipt.reason);
}

@end
