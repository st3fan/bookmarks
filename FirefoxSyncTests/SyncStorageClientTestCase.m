// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#import "NSString+Utils.h"

#import "RSAKeyPair.h"
#import "FXAToken.h"
#import "FXATokenClient.h"
#import "FXACertificate.h"
#import "FXAClient.h"
#import "FXAUtils.h"

#import "JSONWebTokenUtils.h"

#import "FXAAsyncTestHelper.h"

#import "SyncBasicAuthorizer.h"
#import "SyncHawkCredentials.h"
#import "SyncHawkAuthorizer.h"
#import "SyncStorageClient.h"
#import "SyncRecord.h"


static NSString *kFirefoxAccountsProductionEndpoint = @"https://api.accounts.firefox.com/";
static NSString *kFirefoxAccountsProductionEndpointUsername = @"TODO";
static NSString *kFirefoxAccountsProductionEndpointPassword = @"TODO";

static NSString *kTokenServerProductionEndpoint = @"https://token.services.mozilla.com";
static NSString *kTokenServerProductionAudience = @"https://token.services.mozilla.com";

static NSString *kSyncApplicationName = @"sync";
static NSString *kSyncApplicationVersion = @"1.5";


@interface SyncStorageClientTestCase : XCTestCase
@end


@implementation SyncStorageClientTestCase {
    FXAKeysData *_keysData;
    FXAToken *_token;
    SyncHawkCredentials *_credentials;
    SyncStorageClient *_storageClient;
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

    _storageClient = [[SyncStorageClient alloc] initWithStorageEndpoint: [NSURL URLWithString: token.endpoint] authorizer: _credentials.authorizer];
}

- (void) testLoadMetaGlobal
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    [_storageClient loadRecordWithIdentifier: @"global" fromCollection: @"meta" completionHandler:^(NSDictionary *record, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: record];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    
    XCTAssertNil(asyncTestHelper.error);
    XCTAssertNotNil(asyncTestHelper.result);
}

- (void) testLoadRecordsFromCollectionWithSomeRecords
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    [_storageClient loadRecordsFromCollection: @"tabs" completionHandler:^(NSArray *records, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: records];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    
    XCTAssertNil(asyncTestHelper.error);
    XCTAssertNotNil(asyncTestHelper.result);
    
    NSArray *records = asyncTestHelper.result;
    XCTAssertTrue([records count] > 0);
}

//- (void) testLoadRecordsFromCollectionWithNoRecords
//{
//    // Create an empty collection
//
//    SyncRecord *record = [[SyncRecord alloc] initWithIdentifier: [NSString randomAlphanumericStringWithLength:10] modified:0 payload:@{}];
//
//    [self deleteCollection: @"things"];
//    sleep(3);
//    [self storeRecord: record inCollection: @"things"];
//    sleep(3);
//    [self deleteRecordWithIdentifier: record.identifier fromCollection: @"things"];
//    sleep(3);
//
//    // Try load all the records from the empty collection
//
//    {
//        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
//
//        [_storageClient loadRecordsFromCollection: @"things" completionHandler:^(NSArray *records, NSError *error) {
//            if (error) {
//                [asyncTestHelper finishWithError: error];
//            } else {
//                [asyncTestHelper finishWithResult: records];
//            }
//        }];
//        
//        [asyncTestHelper waitForTimeout: 15];
//        XCTAssertFalse(asyncTestHelper.timedOut);
//        
//        XCTAssertNil(asyncTestHelper.error);
//        XCTAssertNotNil(asyncTestHelper.result);
//        
//        NSArray *records = asyncTestHelper.result;
//        XCTAssertEqualObjects(@([records count]), @0);
//    }
//}

- (void) testLoadRecordsFromCollectionWithUnknownCollection
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    [_storageClient loadRecordsFromCollection: @"doesnotexist" completionHandler:^(NSArray *records, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: records];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 300];
    XCTAssertFalse(asyncTestHelper.timedOut);
    
    XCTAssertNil(asyncTestHelper.error);
    XCTAssertNotNil(asyncTestHelper.result);
    
    NSArray *records = asyncTestHelper.result;
    XCTAssertEqualObjects(@([records count]), @0);
}

- (void) testLoadRecordsFromCollectionWithOneRecord
{
    SyncRecord *record = [[SyncRecord alloc] initWithIdentifier: [NSString randomAlphanumericStringWithLength:10] modified:0 payload:@{}];
    [self deleteCollection: @"things"];
    sleep(3);
    [self storeRecord: record inCollection: @"things"];
    sleep(3);

    {
        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

        [_storageClient loadRecordsFromCollection: @"things" completionHandler:^(NSArray *records, NSError *error) {
            if (error) {
                [asyncTestHelper finishWithError: error];
            } else {
                [asyncTestHelper finishWithResult: records];
            }
        }];
        
        [asyncTestHelper waitForTimeout: 15];
        XCTAssertFalse(asyncTestHelper.timedOut);
        
        XCTAssertNil(asyncTestHelper.error);
        XCTAssertNotNil(asyncTestHelper.result);
        
        NSArray *records = asyncTestHelper.result;
        XCTAssertEqualObjects(@([records count]), @1);
    }
}

#pragma mark -

- (void) testStoreRecord
{
    // Store a record with some unique data
    
    NSString *recordIdentifier = [NSString randomAlphanumericStringWithLength: 12];
    NSDictionary *recordPayload = @{@"value": [NSString randomAlphanumericStringWithLength: 8]};
    
    {
        SyncRecord *record = [[SyncRecord alloc] initWithIdentifier: recordIdentifier modified: [[NSDate date] timeIntervalSince1970] payload: recordPayload];
        
        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

        [_storageClient storeRecord: record inCollection: @"things" completionHandler:^(NSError *error) {
            if (error) {
                [asyncTestHelper finishWithError:error];
            } else {
                [asyncTestHelper finishWithResult: @""];
            }
        }];

        [asyncTestHelper waitForTimeout: 15];
        XCTAssertFalse(asyncTestHelper.timedOut);
        
        XCTAssertNil(asyncTestHelper.error);
        XCTAssertNotNil(asyncTestHelper.result);
    }
    
    // Retrieve the record, see if it is the same
    
    {
        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

        [_storageClient loadRecordWithIdentifier: recordIdentifier fromCollection: @"things" completionHandler:^(NSDictionary *record, NSError *error) {
            if (error) {
                [asyncTestHelper finishWithError:error];
            } else {
                [asyncTestHelper finishWithResult: record];
            }
        }];

        [asyncTestHelper waitForTimeout: 15];
        XCTAssertFalse(asyncTestHelper.timedOut);
        
        XCTAssertNil(asyncTestHelper.error);
        XCTAssertNotNil(asyncTestHelper.result);

        SyncRecord *record = [[SyncRecord alloc] initWithJSONRepresentation: asyncTestHelper.result];
        XCTAssertNotNil(record);
        
        XCTAssertEqualObjects(record.identifier, recordIdentifier);
        XCTAssertEqualObjects(record.payload, recordPayload);
    }
}

- (void) testStoreRecords
{
    NSMutableArray *records = [NSMutableArray new];
    for (int i = 0; i < 10; i++) {
        SyncRecord *record = [[SyncRecord alloc] initWithIdentifier: [NSString randomAlphanumericStringWithLength:10]
            modified: [[NSDate date] timeIntervalSince1970] payload: @{@"value": [NSString randomAlphanumericStringWithLength:10]}];
        [records addObject: record];
    }
    
    {
        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

        [_storageClient storeRecords: records inCollection: @"things" completionHandler:^(NSError *error) {
            if (error) {
                [asyncTestHelper finishWithError:error];
            } else {
                [asyncTestHelper finishWithResult: @""];
            }
        }];

        [asyncTestHelper waitForTimeout: 15];
        XCTAssertFalse(asyncTestHelper.timedOut);
        
        XCTAssertNil(asyncTestHelper.error);
        XCTAssertNotNil(asyncTestHelper.result);
    }
    
    // Retrieve them
    
    for (SyncRecord *record in records)
    {
        FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

        [_storageClient loadRecordWithIdentifier: record.identifier fromCollection: @"things" completionHandler:^(NSDictionary *record, NSError *error) {
            if (error) {
                [asyncTestHelper finishWithError:error];
            } else {
                [asyncTestHelper finishWithResult: record];
            }
        }];

        [asyncTestHelper waitForTimeout: 15];
        XCTAssertFalse(asyncTestHelper.timedOut);
        
        XCTAssertNil(asyncTestHelper.error);
        XCTAssertNotNil(asyncTestHelper.result);

        SyncRecord *retrievedRecord = [[SyncRecord alloc] initWithJSONRepresentation: asyncTestHelper.result];
        XCTAssertNotNil(retrievedRecord);
        
        XCTAssertEqualObjects(retrievedRecord.identifier, record.identifier);
        XCTAssertEqualObjects(retrievedRecord.payload, record.payload);
    }
}

#pragma mark -

- (void) testDeleteCollection
{
    SyncRecord *record = [[SyncRecord alloc] initWithIdentifier: [NSString randomAlphanumericStringWithLength:10] modified:0 payload:@{}];

    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    // TODO: Crazy code. Needs a simpler solution.

    [_storageClient deleteCollection: @"things" completionHandler:^(NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [_storageClient loadInfoCollectionsWithCompletionHandler:^(NSDictionary *infoCollections, NSError *error) {
                if (error) {
                    [asyncTestHelper finishWithError: error];
                } else {
                    XCTAssertNil([infoCollections objectForKey: @"things"]);
                    [_storageClient storeRecord: record inCollection: @"things" completionHandler:^(NSError *error) {
                        if (error) {
                            [asyncTestHelper finishWithError: error];
                        } else {
                            [_storageClient loadInfoCollectionsWithCompletionHandler:^(NSDictionary *infoCollections, NSError *error) {
                                if (error) {
                                    [asyncTestHelper finishWithError: error];
                                } else {
                                    XCTAssertNotNil([infoCollections objectForKey: @"things"]);
                                    [_storageClient deleteCollection: @"things" completionHandler:^(NSError *error) {
                                        if (error) {
                                            [asyncTestHelper finishWithError: error];
                                        } else {
                                            [_storageClient loadInfoCollectionsWithCompletionHandler:^(NSDictionary *infoCollections, NSError *error) {
                                                if (error) {
                                                    [asyncTestHelper finishWithError: error];
                                                } else {
                                                    XCTAssertNil([infoCollections objectForKey: @"things"]);
                                                    [asyncTestHelper finishWithResult: @"Cheese"];
                                                }
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];

    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    
    XCTAssertNil(asyncTestHelper.error);
    XCTAssertNotNil(asyncTestHelper.result);
}

#pragma mark -

- (void) deleteCollection: (NSString*) collection
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    [asyncTestHelper waitForTimeout: 15];
    
    [_storageClient deleteCollection: collection completionHandler:^(NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError:error];
        } else {
            [asyncTestHelper finishWithResult:@"Something"];
        }
    }];

    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.error);
}

- (void) storeRecord: (SyncRecord*) record inCollection: (NSString*) collection
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    [asyncTestHelper waitForTimeout: 15];
    
    [_storageClient storeRecord:record inCollection:collection completionHandler:^(NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError:error];
        } else {
            [asyncTestHelper finishWithResult:@"Something"];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.error);
}

- (void) deleteRecordWithIdentifier: (NSString*) identifier fromCollection: (NSString*) collection
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    [asyncTestHelper waitForTimeout: 15];

    [_storageClient deleteRecordWithIdentifier:identifier fromCollection:collection completionHandler:^(NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError:error];
        } else {
            [asyncTestHelper finishWithResult:@"Something"];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15];
    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNil(asyncTestHelper.error);
}

@end
