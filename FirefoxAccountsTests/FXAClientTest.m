// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <XCTest/XCTest.h>
#import "RSAKeyPair.h"
#import "FXACertificate.h"
#import "FXAAsyncTestHelper.h"
#import "FXAClient.h"

@interface FXAClientTest : XCTestCase

@end

static NSString *kFirefoxAccountsEndpoint = @"https://fxa-auth-server.sateh.com/";
static NSString *kFirefoxAccountsEndpointTestUsernameFormat = @"fxa-auth-test-%d-%d@basement.sateh.com";
static NSString *kFirefoxAccountsEndpointTestPassword = @"foobartest";

@implementation FXAClientTest

- (NSString*) generateRandomUsername
{
    return [NSString stringWithFormat: kFirefoxAccountsEndpointTestUsernameFormat,
        (NSUInteger) [[NSDate date] timeIntervalSince1970], rand()];
}

- (void) testCreateAccount
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);
    
    NSString *randomUsername = [self generateRandomUsername];
    
    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [asyncTestHelper finishWithError: error];
            } else {
                [asyncTestHelper finishWithResult: @[createAccountResult, credentials]];
            }
        });
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    FXACreateAccountResult *createAccountResult = asyncTestHelper.result[0];
    XCTAssertNotNil(createAccountResult);
    XCTAssertNotNil(createAccountResult.uid);

    FXACredentials *credentials = asyncTestHelper.result[1];
    XCTAssertNotNil(credentials);
    XCTAssertNotNil(credentials.email);
    XCTAssertNotNil(credentials.password);
    XCTAssertNotNil(credentials.authPW);
    XCTAssertNotNil(credentials.unwrapBKey);
}

- (void) testLogin
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);

    NSString *randomUsername = [self generateRandomUsername];
    
    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
            [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithError: error];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithResult: loginResult];
                    });
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    FXALoginResult *loginResult = asyncTestHelper.result;

    XCTAssertNotNil(loginResult.keyFetchToken);
    XCTAssertTrue([loginResult.keyFetchToken length] == 32);

    XCTAssertNotNil(loginResult.sessionToken);
    XCTAssertTrue([loginResult.sessionToken length] == 32);

    XCTAssertNotNil(loginResult.uid);
}

- (void) testLoginWithUnknownAccount
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);
    
    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: @"foo@kdejkde.com" password: @"dejkdekdje"];
    
    [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [asyncTestHelper finishWithError: error];
            } else {
                [asyncTestHelper finishWithResult: loginResult];
            }
        });
    }];

    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.result);
    XCTAssertNotNil(asyncTestHelper.error);
    
    // TODO: Check if the error is set correctly
}

- (void) testLoginWithBadPassword
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);

    NSString *randomUsername = [self generateRandomUsername];

    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
            FXACredentials *badCredentials = [[FXACredentials alloc] initWithEmail: credentials.email password: @"badpassword"];
            [client loginWithCredentials: badCredentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [asyncTestHelper finishWithError: error];
                    } else {
                        [asyncTestHelper finishWithResult: loginResult];
                    }
                });
            }];
        }
    }];

    [asyncTestHelper waitForTimeout: 15.0];
    
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.result);
    XCTAssertNotNil(asyncTestHelper.error);

    // TODO: Check if the error is set correctly
}

- (void) testDestroySession
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);
    
    NSString *randomUsername = [self generateRandomUsername];

    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
            [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithError: error];
                    });
                } else {
                    [client destroySessionWithToken: loginResult.sessionToken completionHandler:^(NSError *error) {
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithError: error];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithResult: @"OK"];
                            });
                        }
                    }];
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
}

- (void) testFetchKeys
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);
    
    NSString *randomUsername = [self generateRandomUsername];
    
    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
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
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithResult: keysData];
                            });
                        }
                    }];
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);

    FXAKeysData *keysData = asyncTestHelper.result;

    XCTAssertNotNil(keysData.a);
    //XCTAssertEqualObjects(keysData.a, [[NSData alloc] initWithBase16EncodedString: @"7678cc3f89591fb3fd69230d6637a619b4c75db30201a15f49f7185af58372b6"]);

    XCTAssertNotNil(keysData.b);
    //XCTAssertEqualObjects(keysData.b, [[NSData alloc] initWithBase16EncodedString: @"1e96840840a42618c44b205ab7f8b9ca327eb1b557ef07729ed324f1436ad644"]);
}

- (void) testSignCertificate
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsEndpoint]];
    XCTAssertNotNil(client);

    NSString *randomUsername = [self generateRandomUsername];

    [client createAccountWithEmail: randomUsername password: kFirefoxAccountsEndpointTestPassword completionHandler:^(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [asyncTestHelper finishWithError: error];
            });
        } else {
            [client loginWithCredentials: credentials completionHandler: ^(FXALoginResult *loginResult, NSError *error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithError: error];
                    });
                } else {
                    [client signCertificateWithKeyPair: keyPair duration: 60 * 60 * 1000 sessionToken: loginResult.sessionToken completionHandler: ^(FXACertificate *certificate, NSError *error) {
                        if (error) {
                            [asyncTestHelper finishWithError: error];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithResult: certificate];
                            });
                        }
                    }];
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 30.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);

    FXACertificate *certificate = asyncTestHelper.result;
    XCTAssertEqualObjects([certificate class], [FXACertificate class]);
    XCTAssertNotNil(certificate.certificate);
}

@end
