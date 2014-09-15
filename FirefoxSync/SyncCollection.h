// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SyncCollectionChangeType) {
    SyncCollectionChangeTypeInsert,
    SyncCollectionChangeTypeDelete,
    SyncCollectionChangeTypeUpdate
};


@class SyncRecord;


//
// A SyncCollection maintains a local copy of a collection of records. It is
// managed/controlled by the SyncClient, which tells it when to initialize, reset
// and process record changes like inserts, deletes and updates.
//
// By default this class does not do anything. A simple example of an implementation
// can be found in SimpleSyncCollection, which stores all its data in an archived array
// list that simply contains the records.
//

@interface SyncCollection : NSObject

@property (readonly) NSString *name;
@property (readonly) NSString* storagePath;

- (instancetype) initWithName: (NSString*) name storagePath: (NSString*) storagePath;

// Lifcycle

- (void) startup;
- (void) reset;
- (void) startSyncSession;
- (void) beginBatch;
- (void) processRecord: (SyncRecord*) record change: (SyncCollectionChangeType) changeType;
- (void) commitBatch;
- (void) finishSyncSession;
- (void) shutdown;

// Utility

- (BOOL) containsRecordWithIdentifier: (NSString*) identifier;

@end
