// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

//
//#import "SyncClient.h"
//#import "SyncCollection.h"
//#import "SyncCredentials.h"
//#import "SyncHawkCredentials.h"
//#import "SyncAuthenticator.h"
//
//#import "TabsSyncEngine.h"
//
//#import "FXAAsyncTestHelper.h"
//#import <XCTest/XCTest.h>
//
//
//static NSString *SyncClientIdentifier = @"TabsSyncEngineTestCase";
//static NSString *SyncClientStorageEndpoint = @"";
//static NSString *Email = @"TODO";
//static NSString *Password = @"TODO";
//
//
//@interface TabsSyncEngineTestCase : XCTestCase
//
//@end
//
//
//@implementation TabsSyncEngineTestCase {
//    NSURL *_endpoint;
//    SyncHawkCredentials *_credentials;
//}
//
//- (void) setUp
//{
//    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
//    
//    SyncAuthenticator *authenticator = [SyncAuthenticator defaultAuthenticator];
//    [authenticator authenticateWithEmail: Email password: Password completion:^(NSURL *endpoint, SyncHawkCredentials *credentials, NSError *error) {
//        if (error) {
//            [asyncTestHelper finishWithError: error];
//        } else {
//            [asyncTestHelper finishWithResult: @{@"endpoint":endpoint, @"credentials":credentials}];
//        }
//    }];
//    
//    [asyncTestHelper waitForTimeout: 15.0];
//
//    XCTAssertFalse(asyncTestHelper.timedOut);
//    XCTAssertNotNil(asyncTestHelper.result);
//    XCTAssertNil(asyncTestHelper.error);
//    
//    SyncHawkCredentials *credentials = [asyncTestHelper.result objectForKey: @"credentials"];
//    XCTAssertNotNil(credentials);
//    
//    NSURL *endpoint = [asyncTestHelper.result objectForKey: @"endpoint"];
//    XCTAssertNotNil(endpoint);
//    
//    _credentials = credentials;
//    _endpoint = endpoint;
//}
//
//- (void) testSyncTabs
//{
//    // Create a sync client
//
//    SyncClient *syncClient = [[SyncClient alloc] initWithIdentifier: SyncClientIdentifier storageEndpoint: _endpoint];
//    XCTAssertNotNil(syncClient);
//    
//    // Create and register a tabs sync engine
//    
//    TabsSyncEngine *tabsSyncEngine = [TabsSyncEngine new];
//    XCTAssertNotNil(tabsSyncEngine);
//
//    NSError *error = nil;
//    BOOL ok = [syncClient registerEngine: tabsSyncEngine forCollection: @"tabs" error: &error];
//    XCTAssertTrue(ok);
//
//    // Run sync
//    
//    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
//
//    [syncClient performSyncWithCredentials: _credentials completionHandler:^(SyncStatus *status, NSError *error) {
//        if (error) {
//            [asyncTestHelper finishWithError: error];
//        } else {
//            [asyncTestHelper finishWithResult: status];
//        }
//    }];
//
//    [asyncTestHelper waitForTimeout: 15.0];
//
//    XCTAssertFalse(asyncTestHelper.timedOut);
//    XCTAssertNotNil(asyncTestHelper.result);
//    XCTAssertNil(asyncTestHelper.error);
//}
//
//@end
