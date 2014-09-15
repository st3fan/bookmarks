// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@class SyncRecord;
@class SyncAuthorizer;


typedef void (^SyncStorageClientLoadRecordCompletionHandler)(NSDictionary* record, NSError* error);
typedef void (^SyncStorageClientLoadRecordsCompletionHandler)(NSArray* records, NSError* error);
typedef void (^SyncStorageClientDeleteCollectionCompletionHandler)(NSError* error);
typedef void (^SyncStorageClientDeleteRecordsCompletionHandler)(NSError* error);
typedef void (^SyncStorageClientDeleteRecordCompletionHandler)(NSError* error);
typedef void (^SyncStorageClientStoreRecordCompletionHandler)(NSError* error);
typedef void (^SyncStorageClientStoreRecordsCompletionHandler)(NSError* error);


@interface SyncStorageClient : NSObject

- (instancetype) initWithStorageEndpoint: (NSURL*) storageEndpoint authorizer: (SyncAuthorizer*) authorizer;

- (void) loadRecordWithIdentifier: (NSString*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientLoadRecordCompletionHandler) completionHandler;
- (void) loadRecordsFromCollection: (NSString*) collection completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler;
- (void) loadRecordsFromCollection: (NSString*) collection limit: (NSUInteger) limit completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler;
- (void) loadRecordsFromCollection: (NSString*) collection limit: (NSUInteger) limit newer: (NSNumber*) newer completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler;

- (void) storeRecord: (SyncRecord*) record inCollection: (NSString*) collection completionHandler: (SyncStorageClientStoreRecordCompletionHandler) completionHandler;
- (void) storeRecords: (NSArray*) records inCollection: (NSString*) collection completionHandler: (SyncStorageClientStoreRecordsCompletionHandler) completionHandler;

- (void) deleteCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteCollectionCompletionHandler) completionHandler;
- (void) deleteRecordsWithIdentifiers: (NSArray*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteRecordsCompletionHandler) completionHandler;
- (void) deleteRecordWithIdentifier: (NSString*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteRecordCompletionHandler) completionHandler;

- (void) loadInfoCollectionsWithCompletionHandler: (SyncStorageClientLoadRecordCompletionHandler) completionHandler;

@end
