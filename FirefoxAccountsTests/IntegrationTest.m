//  IntegrationTest.m


#import <XCTest/XCTest.h>

#import "RSAKeyPair.h"
#import "FXACertificate.h"
#import "FXAAsyncTestHelper.h"
#import "FXAClient.h"
#import "FXATokenClient.h"
#import "FXAToken.h"
#import "FXAUtils.h"
#import "JSONWebTokenUtils.h"


static NSString *kFirefoxAccountsStagingEndpoint = @"https://api-accounts.stage.mozaws.net/";
static NSString *kFirefoxAccountsStagingEndpointUsername = @"stefan@arentz.ca";
static NSString *kFirefoxAccountsStagingEndpointPassword = @"q1w2e3r4";
//static NSString *kFirefoxAccountsStagingEndpointKeyA = @"66196ec6c94291da25b35d021b012749f7da3d61992370de64ad482357277bff";
//static NSString *kFirefoxAccountsStagingEndpointKeyB = @"b0939af693d09d2511a66842d1f949e09d64c2ae768bfebe2a6fb92da5157efc";
static NSString *kTokenServerStagingEndpoint = @"http://auth.oldsync.dev.lcip.org";

static NSString *kFirefoxAccountsProductionEndpoint = @"https://api.accounts.firefox.com";
static NSString *kFirefoxAccountsProductionEndpointUsername = @"stefan@arentz.ca";
static NSString *kFirefoxAccountsProductionEndpointPassword = @"q1w2e3r4";
//static NSString *kFirefoxAccountsProductionEndpointKeyA = @"66196ec6c94291da25b35d021b012749f7da3d61992370de64ad482357277bff";
//static NSString *kFirefoxAccountsProductionEndpointKeyB = @"b0939af693d09d2511a66842d1f949e09d64c2ae768bfebe2a6fb92da5157efc";
static NSString *kTokenServerProductionEndpoint = @"https://token.services.mozilla.com";
static NSString *kTokenServerProductionAudience = @"https://token.services.mozilla.com";

static NSString *kSyncApplicationName = @"sync";
static NSString *kSyncApplicationVersion = @"1.5";



@interface IntegrationTest : XCTestCase

@end


@implementation IntegrationTest

// TODO: Enable staging once it works again

//- (void) testFetchKeysFromStaging
//{
//    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
//
//    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsStagingEndpoint]];
//    XCTAssertNotNil(client);
//    
//    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: kFirefoxAccountsStagingEndpointUsername
//        password: kFirefoxAccountsStagingEndpointPassword];
//    XCTAssertNotNil(client);
//    
//    [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [asyncTestHelper finishWithError: error];
//            });
//        } else {
//            [client fetchKeysWithKeyFetchToken: loginResult.keyFetchToken credentials: credentials completionHandler: ^(FXAKeysData *keysData, NSError *error) {
//                if (error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [asyncTestHelper finishWithError: error];
//                    });
//                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [asyncTestHelper finishWithResult: keysData];
//                    });
//                }
//            }];
//        }
//    }];
//    
//    [asyncTestHelper waitForTimeout: 15.0];
//
//    XCTAssertFalse(asyncTestHelper.timedOut);
//    XCTAssertNotNil(asyncTestHelper.result);
//    XCTAssertNil(asyncTestHelper.error);
//
//    FXAKeysData *keysData = asyncTestHelper.result;
//
//    XCTAssertEqual([keysData.a length], (NSUInteger) 32);
////    XCTAssertEqualObjects(
////        [[NSData alloc] initWithBase16EncodedString: kFirefoxAccountsStagingEndpointKeyA],
////        keysData.a
////    );
//
//    XCTAssertEqual([keysData.b length], (NSUInteger) 32);
////    XCTAssertEqualObjects(
////        [[NSData alloc] initWithBase16EncodedString: kFirefoxAccountsStagingEndpointKeyB],
////        keysData.b
////    );
//}

- (void) testFetchKeysFromProduction
{
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [asyncTestHelper finishWithResult: keysData];
                    });
                }
            }];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);

    FXAKeysData *keysData = asyncTestHelper.result;

    XCTAssertEqual([keysData.a length], (NSUInteger) 32);
//    XCTAssertEqualObjects(
//        [[NSData alloc] initWithBase16EncodedString: kFirefoxAccountsProductionEndpointKeyA],
//        keysData.a
//    );

    XCTAssertEqual([keysData.b length], (NSUInteger) 32);
//    XCTAssertEqualObjects(
//        [[NSData alloc] initWithBase16EncodedString: kFirefoxAccountsProductionEndpointKeyB],
//        keysData.b
//    );
}

//- (void) testVerifyAssertionStaging
//{
//    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
//    XCTAssertNotNil(keyPair);
//
//    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
//
//    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: kFirefoxAccountsStagingEndpoint]];
//    XCTAssertNotNil(client);
//    
//    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: kFirefoxAccountsStagingEndpointUsername
//        password: kFirefoxAccountsStagingEndpointPassword];
//    XCTAssertNotNil(client);
//    
//    [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
//        if (error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [asyncTestHelper finishWithError: error];
//            });
//        } else {
//            [client signCertificateWithKeyPair: keyPair duration: 86400 sessionToken: loginResult.sessionToken completionHandler: ^(FXACertificate *certificate, NSError *error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [asyncTestHelper finishWithResult: certificate];
//                });
//            }];
//        }
//    }];
//    
//    [asyncTestHelper waitForTimeout: 15.0];
//
//    XCTAssertFalse(asyncTestHelper.timedOut);
//    XCTAssertNotNil(asyncTestHelper.result);
//    XCTAssertNil(asyncTestHelper.error);
//
//    FXACertificate *certificate = asyncTestHelper.result;
//    XCTAssertEqualObjects([certificate class], [FXACertificate class]);
//    XCTAssertNotNil(certificate.certificate);
//
//    //
//
//    unsigned long long issuedAt = [[NSDate date] timeIntervalSince1970] * 1000 - (15 * 1000); // TODO: Issue in the past because of clock skew errors
//    unsigned long long duration = JSONWebTokenUtilsDefaultAssertionDuration;
//    
//    NSString *assertion = [JSONWebTokenUtils createAssertionWithPrivateKeyToSignWith: keyPair.privateKey
//        certificate: certificate.certificate audience: kTokenServerStagingAudience issuer: JSONWebTokenUtilsDefaultAssertionIssuer
//            issuedAt: issuedAt duration: duration];
//    
//    //
//    
//    //sleep(3);
//    
//    asyncTestHelper = [FXAAsyncTestHelper new];
//
//    FXATokenClient *tokenClient = [[FXATokenClient new] initWithEndpoint: [NSURL URLWithString: kTokenServerStagingEndpoint]];
//    XCTAssertNotNil(tokenClient);
//    
//    [tokenClient getTokenForApplication: kSyncApplicationName version: kSyncApplicationVersion assertion: assertion completionHandler:^(FXAToken *token, NSError *error) {
//        if (error) {
//            [asyncTestHelper finishWithError: error];
//        } else {
//            [asyncTestHelper finishWithResult: token];
//        }
//    }];
//    
//    [asyncTestHelper waitForTimeout: 15.0];
//
//    XCTAssertFalse(asyncTestHelper.timedOut);
//    XCTAssertNotNil(asyncTestHelper.result);
//    XCTAssertNil(asyncTestHelper.error);
//    
//    FXAToken *token = asyncTestHelper.result;
//    XCTAssertNotNil(token.identifier);
//    XCTAssertNotNil(token.key);
//    XCTAssertNotNil(token.uid);
//    XCTAssertNotNil(token.endpoint);
//    //XCTAssertEqualObjects([kTestEndpoint stringByAppendingString: [token.uid stringValue]], token.endpoint);
//}

- (void) testVerifyAssertionProduction
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);

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
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithError: error];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [asyncTestHelper finishWithResult: @[keysData, certificate]];
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

    FXAKeysData *keysData = asyncTestHelper.result[0];
    XCTAssertEqualObjects([keysData class], [FXAKeysData class]);
    XCTAssertNotNil(keysData.a);
    XCTAssertNotNil(keysData.b);

    FXACertificate *certificate = asyncTestHelper.result[1];
    XCTAssertEqualObjects([certificate class], [FXACertificate class]);
    XCTAssertNotNil(certificate.certificate);

    //
    
    NSString *assertion = [JSONWebTokenUtils createAssertionWithPrivateKeyToSignWith: keyPair.privateKey
        certificate: certificate.certificate audience: kTokenServerProductionAudience];

    //
    
    FXATokenClient *tokenClient = [[FXATokenClient new] initWithEndpoint: [NSURL URLWithString: kTokenServerProductionEndpoint]];
    XCTAssertNotNil(tokenClient);

    asyncTestHelper = [FXAAsyncTestHelper new];
    
    NSString *clientState = [FXAUtils computeClientState: keysData.b];
    
    [tokenClient getTokenForApplication: kSyncApplicationName version: kSyncApplicationVersion assertion: assertion clientState: clientState completionHandler:^(FXAToken *token, NSError *error) {
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

@end
