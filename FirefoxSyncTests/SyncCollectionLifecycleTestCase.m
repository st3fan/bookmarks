// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncClient.h"
#import "SyncCollection.h"
#import "SyncCollection.h"
#import "BaseSyncTestCase.h"
#import "FXAAsyncTestHelper.h"
#import <XCTest/XCTest.h>


@interface LifecycleLoggingCollection : SyncCollection

@property NSMutableArray *log;

@end

@implementation LifecycleLoggingCollection

- (instancetype) initWithName:(NSString *)name storagePath:(NSString *)storagePath
{
    if ((self = [super initWithName:name storagePath:storagePath]) != nil) {
        _log = [NSMutableArray new];
    }
    return self;
}

- (void) startup
{
    [_log addObject: @"startup"];
}

- (void) reset
{
    [_log addObject: @"reset"];
}

- (void) startSyncSession
{
    [_log addObject: @"startSyncSession"];
}

- (void) beginBatch
{
    [_log addObject: @"beginBatch"];
}

- (void) processRecord: (SyncRecord*) record change: (SyncCollectionChangeType) changeType
{
    [_log addObject: @"processRecord"];
}

- (void) commitBatch
{
    [_log addObject: @"commitBatch"];
}

- (void) finishSyncSession
{
    [_log addObject: @"finishSyncSession"];
}

- (void) shutdown
{
    [_log addObject: @"shutdown"];
}

- (BOOL) containsRecordWithIdentifier: (NSString*) identifier
{
    return NO;
}

@end


@interface SyncCollectionLifecycleTestCase : BaseSyncTestCase

@end

@implementation SyncCollectionLifecycleTestCase

- (void) testSyncCollectionLifecycle
{
    // Create a sync client

    SyncClient *syncClient = [[SyncClient alloc] initWithIdentifier: [self uniqueSyncClientIdentifier] storageEndpoint: _endpoint];
    XCTAssertNotNil(syncClient);
    
    // Create and register collections
    
    LifecycleLoggingCollection *lifecycleLoggingCollection = [[LifecycleLoggingCollection alloc] initWithName: @"tabs" storagePath: syncClient.localStoragePath];
    XCTAssertNotNil(lifecycleLoggingCollection);

    NSError *error = nil;
    BOOL ok = [syncClient registerCollection: lifecycleLoggingCollection error: &error];
    XCTAssertTrue(ok);

    // Run sync
    
    FXAAsyncTestHelper *asyncTestHelper = [FXAAsyncTestHelper new];

    [syncClient performSyncWithCredentials: _credentials completionHandler:^(SyncStatus *status, NSError *error) {
        if (error) {
            [asyncTestHelper finishWithError: error];
        } else {
            [asyncTestHelper finishWithResult: status];
        }
    }];

    [asyncTestHelper waitForTimeout: 3600];

    XCTAssertFalse(asyncTestHelper.timedOut);
    XCTAssertNotNil(asyncTestHelper.result);
    XCTAssertNil(asyncTestHelper.error);
    
    // Check if the lifecycle log is correct
    
    XCTAssertEqual(10, [lifecycleLoggingCollection.log count]);
}

@end
