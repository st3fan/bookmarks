// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#import "RSAKeyPair.h"
#import "JSONWebTokenUtils.h"

#import "FXAAsyncTestHelper.h"
#import "FXAToken.h"
#import "FXATokenClient.h"
#import "FXACertificate.h"
#import "FXAClient.h"
#import "FXAUtils.h"

#import "SyncBasicAuthorizer.h"
#import "SyncHawkCredentials.h"
#import "SyncHawkAuthorizer.h"
#import "SyncClient.h"


static NSString *kFirefoxAccountsProductionEndpoint = @"https://api.accounts.firefox.com/";
static NSString *kFirefoxAccountsProductionEndpointUsername = @"TODO";
static NSString *kFirefoxAccountsProductionEndpointPassword = @"TODO";

static NSString *kTokenServerProductionEndpoint = @"https://token.services.mozilla.com";
static NSString *kTokenServerProductionAudience = @"https://token.services.mozilla.com";

static NSString *kSyncApplicationName = @"sync";
static NSString *kSyncApplicationVersion = @"1.5";


@interface SyncClientTestCase : XCTestCase

@end


@implementation SyncClientTestCase {
    NSURL *_storageEndpoint;
    FXAKeysData *_keysData;
    FXAToken *_token;
    SyncHawkCredentials *_credentials;
}

- (void) setUp
{
    // Generate our key pair

    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);

    // Login to Firefox Accounts and get our keys and certificate

    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsProductionEndpoint]];
    XCTAssertNotNil(client);
    
    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: kFirefoxAccountsProductionEndpointUsername
        password: kFirefoxAccountsProductionEndpointPassword];
    XCTAssertNotNil(client);
    
    [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
            [client fetchKeysWithKeyFetchToken: loginResult.keyFetchToken credentials: credentials completionHandler: ^(FXAKeysData *keysData, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithError: error];
                    });
                } else {
                    [client signCertificateWithKeyPair: keyPair duration: 86400 sessionToken: loginResult.sessionToken completionHandler: ^(FXACertificate *certificate, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [asyncTestHelper finishWithResult: @[keysData, certificate]];
                        });
                    }];
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);

    FXAKeysData *keysData = asyncTestHelper.result[0];
    XCTAssertEqualObjects([keysData class], [FXAKeysData class]);
    XCTAssertNotNil(keysData.a);
    XCTAssertNotNil(keysData.b);

    FXACertificate *certificate = asyncTestHelper.result[1];
    XCTAssertEqualObjects([certificate class], [FXACertificate class]);
    XCTAssertNotNil(certificate.certificate);

    // Create an assertion
    
    unsigned long long issuedAt = ([[NSDate date] timeIntervalSince1970] * 1000) - (60 * 1000);
    unsigned long long duration = JSONWebTokenUtilsDefaultAssertionDuration;
    
    NSString *assertion = [JSONWebTokenUtils createAssertionWithPrivateKeyToSignWith: keyPair.privateKey
        certificate: certificate.certificate audience: kTokenServerProductionAudience issuer: JSONWebTokenUtilsDefaultAssertionIssuer
            issuedAt: issuedAt duration: duration];

    // Convert the assertion to a token
    
    asyncTestHelper = [FXAAsyncTestHelper new];

    FXATokenClient *tokenClient = [[FXATokenClient new] initWithEndpoint: [NSURL URLWithString: kTokenServerProductionEndpoint]];
    XCTAssertNotNil(tokenClient);
    
    NSString *clientState = [FXAUtils computeClientState: keysData.b];
    
    [tokenClient getTokenForApplication: kSyncApplicationName version: kSyncApplicationVersion assertion: assertion clientState: clientState completionHandler:^(FXAToken *token, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            _token = token;
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
    
    _credentials = [[SyncHawkCredentials alloc] initWithToken: token key: keysData.b];
    XCTAssertNotNil(_credentials);
    
    _storageEndpoint = [NSURL URLWithString: token.endpoint];
    XCTAssertNotNil(_storageEndpoint);
}

- (void) testSyncClientSetup
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    // Run an 'empty' sync with no engines. This will still connect, authenticate, check collections, etc.
    
    SyncClient *client = [[SyncClient alloc] initWithIdentifier: @"testSyncClientSetup" storageEndpoint: _storageEndpoint];
    [client performSyncWithCredentials: _credentials completionHandler: ^(SyncStatus *status, NSError* error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: status];
        }
    }];
    
    //
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
}

@end
