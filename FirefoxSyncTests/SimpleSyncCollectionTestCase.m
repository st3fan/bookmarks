// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "SyncClient.h"
#import "SyncStatus.h"
#import "SyncCollectionStatistics.h"
#import "SyncCollection.h"
#import "SyncCredentials.h"
#import "SyncHawkCredentials.h"
#import "SyncAuthenticator.h"

#import "SimpleSyncCollection.h"

#import "FXAAsyncTestHelper.h"
#import <XCTest/XCTest.h>


static NSString *SyncClientIdentifier = @"TabsSyncEngineTestCase";
static NSString *SyncClientStorageEndpoint = @"";
static NSString *Email = @"TODO";
static NSString *Password = @"TODO";


@interface SimpleSyncCollectionTestCase : XCTestCase

@end


@implementation SimpleSyncCollectionTestCase {
    NSURL *_endpoint;
    SyncHawkCredentials *_credentials;
}

- (void) setUp
{
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];
    
    SyncAuthenticator *authenticator = [SyncAuthenticator defaultAuthenticator];
    [authenticator authenticateWithEmail: Email password: Password completion:^(NSURL *endpoint, SyncHawkCredentials *credentials, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: @{@"endpoint":endpoint, @"credentials":credentials}];
        }
    }];
    
    [asyncTestHelper waitForTimeout: 15.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    SyncHawkCredentials *credentials = [asyncTestHelper.result objectForKey: @"credentials"];
    XCTAssertNotNil(credentials);
    
    NSURL *endpoint = [asyncTestHelper.result objectForKey: @"endpoint"];
    XCTAssertNotNil(endpoint);
    
    _credentials = credentials;
    _endpoint = endpoint;
}

- (void) testSyncCollections
{
    SyncStatus *syncStatus = [self syncCollections: @[@"bookmarks", @"tabs", @"clients", @"forms", @"passwords", @"history"]];
    for (NSString *collection in syncStatus.collectionStatistics) {
        SyncCollectionStatistics* collectionStatistics = [syncStatus.collectionStatistics objectForKey: collection];
        NSLog(@"Collection: %@", collection);
        NSLog(@"  Updates: %d", collectionStatistics.updates);
        NSLog(@"  Deletes: %d", collectionStatistics.deletes);
        NSLog(@"  Inserts: %d", collectionStatistics.inserts);
    }
}

// TODO: Write tests that deal with inserts, updates, deletes

// TODO: Write tests that deal with loading a large number of records (paging)

#pragma mark -

- (SyncStatus*) syncCollections: (NSArray*) collections
{
    // Create a sync client

    SyncClient *syncClient = [[SyncClient alloc] initWithIdentifier: SyncClientIdentifier storageEndpoint: _endpoint];
    XCTAssertNotNil(syncClient);
    
    // Create and register collections
    
    for (NSString *collection in collections) {
        SimpleSyncCollection *simpleSyncCollection = [[SimpleSyncCollection alloc] initWithName: collection storagePath: syncClient.localStoragePath];
        XCTAssertNotNil(simpleSyncCollection);
        NSError *error = nil;
        BOOL ok = [syncClient registerCollection: simpleSyncCollection error: &error];
        XCTAssertTrue(ok);
    }

    // Run sync
    
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    [syncClient performSyncWithCredentials: _credentials completionHandler:^(SyncStatus *status, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: status];
        }
    }];

    [asyncTestHelper waitForTimeout: 1500.0];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    return asyncTestHelper.result;
}

@end
