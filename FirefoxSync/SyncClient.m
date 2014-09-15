// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncCollection.h"
#import "SyncCollectionStatistics.h"
#import "SyncCollectionState.h"
#import "SyncStorageClient.h"
#import "SyncCredentials.h"
#import "SyncKeyBundle.h"
#import "SyncStatus.h"
#import "SyncRecord.h"
#import "SyncCollectionKeys.h"
#import "SyncMetaGlobal.h"
#import "SyncClient.h"


static NSString *SyncClientAPIVersion = @"1.1";


#pragma mark -


@implementation SyncClient  {
    NSString *_identifier;
    NSURL *_storageEndpoint;
    NSMutableDictionary *_collectionsByName;

    // Below is all sync state. Maybe move to a separate object so that we can easily reset it in bulk?
    SyncCredentials *_credentials;
    SyncStorageClient *_storageClient;
    dispatch_queue_t _queue;
    NSError *_error;
    SyncCollectionKeys *_collectionKeys;
    NSMutableSet *_collectionsToSync;
    SyncMetaGlobal *_metaGlobal;
    NSMutableSet *_collectionsToReset;
    NSMutableDictionary *_collectionStatistics;
}

- (instancetype) initWithIdentifier: (NSString*) identifier storageEndpoint: (NSURL*) storageEndpoint;
{
    if ((self = [super init]) != nil) {
        _identifier = identifier;
        _storageEndpoint = storageEndpoint;
        _collectionsByName = [NSMutableDictionary new];

        _localStoragePath = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject]
            stringByAppendingPathComponent: [NSString stringWithFormat: @"SyncClient-%@", _identifier]];
    }
    
    return self;
}

- (BOOL) registerCollection: (SyncCollection*) collection error: (NSError**) error;
{
    if (error != NULL) {
        *error = nil;
    }

    if (_collectionsByName[collection.name] != nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain: @"" code: -1 userInfo: @{@"Reason": @"Engine already registered"}];
        }
        return FALSE;
    }
    
    _collectionsByName[collection.name] = collection;
    
    return YES;
}

- (void) performSyncWithCredentials: (SyncCredentials*) credentials completionHandler: (SyncClientCompletionHandler) completionHandler
{
    //
    // Make sure there is not already a sync session running for this user
    //

    if (_credentials != nil) {
        completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason": @"Sync already in progress"}]);
        return;
    }
    
    _credentials = credentials;
    _storageClient = [[SyncStorageClient alloc] initWithStorageEndpoint: _storageEndpoint authorizer: credentials.authorizer];
    
    //
    // Check if we are syncing with the same account. If not then the user has switched accounts and we need to raise an error.
    //
    
    if (false) { // TODO: Implement email check
        completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason": @"Sync needs to be reset before using a different account"}]);
        return;
    }
    
    //
    // Create our local storage directory. We do that here because then we can return an error code in case it fails. Not sure
    // if it actually can fail.
    //
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: _localStoragePath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:_localStoragePath withIntermediateDirectories: YES attributes:nil error:NULL];
    }
    
    //
    // First thing we do is grab info/collections. We can compare the timestamps for collections and will
    // immediately know if we need to do anything for this sync. If any of the timestamps differ, or if
    // any of our local timestamps are nil, we have work to do.
    //

    [_storageClient loadInfoCollectionsWithCompletionHandler:^(NSDictionary *record, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSLog(@"SyncClient: Grabbed info/collections: %@", record);

        NSDictionary *infoCollections = record;

        //
        // Loop over all locally registered collections. We will only sync those that have a lastSyncDate that is nil or
        // older than what we have in info/collections. If info/collections does not list the engine's collection then
        // there is also nothing to sync.
        //
        
        _collectionsToSync = [NSMutableSet new];
        
        for (NSString *collectionName in [_collectionsByName keyEnumerator])
        {
            SyncCollection *collection = _collectionsByName[collectionName];
            
            SyncCollectionState *collectionState = [self loadStateForCollection: collection];
            if (collectionState == nil) {
                completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason": @"Cannot load local collection state"}]);
                return;
            }
            
            // Check if the collection exists on the server. Skip if not.
            NSNumber *lastModificationDate = [infoCollections objectForKey: collectionName];
            if (lastModificationDate == nil) {
                NSLog(@"SyncClient: Collection %@ does not exist on the server. Skipping.", collectionName);
                continue;
            }
            
            // Check if the collection is newer than what we have locally.
            if (collectionState.lastSyncDate == nil || [collectionState.lastSyncDate integerValue] < [lastModificationDate integerValue]) {
                NSLog(@"SyncClient: We are going to sync collection '%@'", collectionName);
                [_collectionsToSync addObject: collection];
                [_collectionStatistics setObject: [SyncCollectionStatistics new] forKey: collectionName];
            }
        }
        
        if ([_collectionsToSync count] == 0)
        {
            NSLog(@"SyncClient: no engines to sync. Done.");
            completionHandler([[SyncStatus alloc] initWithCollectionStatistics: _collectionStatistics], nil); // TODO: Create proper SyncStatus result codes
            return;
        }
        
        //
        // The next thing we do is grab storage/meta/global. For each collection we can compare the syncID with
        // the ID that we have locally. If they differ then the collection was reset and we need to reset our
        // local copy and do a full sync.
        //
    
        [_storageClient loadRecordWithIdentifier: @"global" fromCollection: @"meta" completionHandler:^(NSDictionary *record, NSError *error) {
            if (error) {
                completionHandler(nil, error);
                return;
            }

            SyncRecord *syncRecord = [[SyncRecord alloc] initWithJSONRepresentation: record];
            if (syncRecord == nil) {
                completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason":@"Cannot parse meta/global"}]);
                return;
            }

            _metaGlobal = [[SyncMetaGlobal alloc] initWithJSONRepresentation: syncRecord.payload];
            
            //
            // Now loop over collections that need to sync and see if the syncID has changed. If it has then
            // that collection has been reset and we need to do a full reset and fully sync it. We also need to
            // check the version.
            //
            
            _collectionsToReset = [NSMutableSet new];
            
            for (SyncCollection *collection in _collectionsToSync)
            {
                SyncCollectionState *collectionState = [self loadStateForCollection: collection];
                
                // If we have never synced this collection before then we dont need to reset.
                if (collectionState.lastSyncID == nil) {
                    continue;
                }
                
                // Get the meta/global for this collection. If it does not exist then there is nothing to do?
                NSDictionary *collectionMetaGlobal = [_metaGlobal metaGlobalForEngineWithName: collection.name];
                if (collectionMetaGlobal == nil) {
                    continue; // TODO: Should we remove this from the list of collections to sync then?
                }
                
                // Compare the syncID. If it is different then we need to reset our local collection.
                if ([collectionState.lastSyncID isEqualToString: collectionMetaGlobal[@"syncID"]] == NO) {
                    NSLog(@"SyncClient: Adding %@ to enginesToReset (because the syncID is different)", collection.name);
                    [_collectionsToReset addObject: collection];
                }
            }
            
            //
            // Grabs the keys.
            //
            
            [_storageClient loadRecordWithIdentifier: @"keys" fromCollection: @"crypto" completionHandler:^(NSDictionary *record, NSError *error) {
                if (error) {
                    completionHandler(nil, error);
                    return;
                }
                
                SyncRecord *syncRecord = [[SyncRecord alloc] initWithJSONRepresentation: record keyBundle: _credentials.globalKeyBundle];
                if (syncRecord == nil) {
                    completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason":@"Cannot decrypt crypto/keys"}]);
                    return;
                }
                
                NSLog(@"SyncClient: Grabbed crypto/keys: %@", syncRecord);
                
                _collectionKeys = [[SyncCollectionKeys alloc] initWithJSONRepresentation: syncRecord.payload];
                if (_collectionKeys == nil) {
                    completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo:@{@"Reason":@"Cannot parse crypto/keys payload"}]);
                    return;
                }
                
                //
                // Now we are ready to sync. We know what to sync, which collections to reset and we have the keys.
                //
                
                for (SyncCollection *collection in _collectionsToSync) {
                    NSLog(@"SyncClient: We need to sync collection %@", collection.name);
                }

                for (SyncCollection *collection in _collectionsToReset) {
                    NSLog(@"SyncClient: We need to reset collection %@", collection.name);
                }
                
                //
                // Put a sync block on our queue for every engine that needs to sync. We queue everything that needs to
                // be done and then suspend at the end.
                //
                
                
                for (SyncCollection *collection in _collectionsToSync)
                {
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

                    NSError *error = [self syncCollection: collection];
                    if (error) {
                        // TODO: Mark this collection sync as failed. If it is a network or crypto error we should stop now. Otherwise try next collection.
                    }

                    if (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) > 0) { // TODO: Set actual timeout value
                        completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}]);
                        return;
                    }
                    
                    if (error != nil) {
                        completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}]);
                        return;
                    }
                }
            }];
            
        }];
    }];
}


- (NSError*) syncCollection: (SyncCollection*) collection
{
    __block NSNumber *highestModifiedDate = [NSNumber numberWithDouble: 0.0];
    __block NSUInteger deletes = 0;
    __block NSUInteger inserts = 0;
    __block NSUInteger updates = 0;

    // Grab our local state for this collection

    SyncCollectionState *collectionState = [self loadStateForCollection: collection];
    if (collectionState == nil) {
        //completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Cannot get local collection state"}]);
        return [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Cannot get local collection state"}];
    }

    // Optionally reset the collection

    if ([_collectionsToReset containsObject: collection]) {
        [collection reset];
        [collectionState reset];
        [self saveState: collectionState forCollection:collection]; // TODO: ...WithError:
    }

    // Start the sync session. This gives

    [collection startSyncSession];
    {
        __block NSError *error = nil;
        __block NSArray *records = nil;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        if (collectionState.lastSyncDate == nil) {
            [_storageClient loadRecordsFromCollection: collection.name completionHandler:^(NSArray *aRecords, NSError *aError) {
                error = aError;
                records = aRecords;
                dispatch_semaphore_signal(semaphore);
            }];
        } else {
            [_storageClient loadRecordsFromCollection: collection.name limit: 0 newer: collectionState.lastSyncDate completionHandler:^(NSArray *aRecords, NSError *aError) {
                error = aError;
                records = aRecords;
                dispatch_semaphore_signal(semaphore);
            }];
        }
        
        if (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) > 0) { // TODO: Set actual timeout value
            //completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}]);
            return [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}];
        }
        
        if (error != nil) {
            //completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}]);
            return [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Timeout"}];
        }
        
        //
        
        _collectionStatistics = [NSMutableDictionary new];

        [collection beginBatch];
        {
            // Now walk over all the records, decrypt them and then pass them to the collection

            __block NSError *error = nil;

            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SyncRecord *record = [[SyncRecord alloc] initWithJSONRepresentation: obj keyBundle: [_collectionKeys keyBundleForCollection: collection.name]];
                if (record == nil) {
                    dispatch_suspend(_queue);
                    //completionHandler(nil, [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Decryption failure"}]);
                    error = [NSError errorWithDomain: @""  code:-1 userInfo: @{@"Reason": @"Decryption failure"}];
                    *stop = YES;
                }
                
                if ([record.modified doubleValue] > [highestModifiedDate doubleValue]) {
                    highestModifiedDate = record.modified;
                }

                if ([record.payload objectForKey: @"deleted"]) {
                    [collection processRecord: record change: SyncCollectionChangeTypeDelete];
                    deletes++;
                } else {
                    if (collectionState.lastSyncDate == nil) {
                        [collection processRecord: record change: SyncCollectionChangeTypeInsert];
                        inserts++;
                    } else {
                        if ([collection containsRecordWithIdentifier: record.identifier]) {
                            [collection processRecord: record change: SyncCollectionChangeTypeUpdate];
                            updates++;
                        } else {
                            [collection processRecord: record change: SyncCollectionChangeTypeInsert];
                            inserts++;
                        }
                    }
                }
            }];
            
            if (error) {
                return error;
            }
        }
        [collection commitBatch];
    }
    [collection finishSyncSession];

    // Update our local state for this collection

    NSDictionary *collectionMetaGlobal = [_metaGlobal metaGlobalForEngineWithName: collection.name];
    if (collectionMetaGlobal == nil) {
        // TODO: Can this actually happen!?
    }

    collectionState.lastSyncDate = highestModifiedDate;
    collectionState.lastSyncID = collectionMetaGlobal[@"syncID"];
    [self saveState: collectionState forCollection: collection];

    // Update the statistics

    SyncCollectionStatistics *statistics = [[SyncCollectionStatistics alloc] initWithDeletes:deletes inserts:inserts updates:updates];
    [_collectionStatistics setObject:statistics forKey:collection.name];
    
    return nil;
}


//
// When we reset the client, we wipe the data directory. This removes all state and all databases.
//

// TODO: Make this call async. It can call a completion handler with an error.

- (void) reset
{
    if ([[NSFileManager defaultManager] fileExistsAtPath: _localStoragePath]) {
        [[NSFileManager defaultManager] removeItemAtPath: _localStoragePath error: NULL];
    }
}

#pragma mark -

//
// Load ~/Library/Application Support/SyncClient-$IDENTIFIER/$COLLECTIONNAME-state.json
//

- (SyncCollectionState*) loadStateForCollection: (SyncCollection*) collection
{
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *syncClientDataPath = [applicationSupportPath stringByAppendingPathComponent: [NSString stringWithFormat: @"SyncClient-%@", _identifier]];
    NSString *engineStatePath = [syncClientDataPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@-state.plist", collection.name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:syncClientDataPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:syncClientDataPath withIntermediateDirectories: YES attributes:nil error:NULL];
    }
    
    SyncCollectionState *collectionState = [SyncCollectionState new];
    if ([[NSFileManager defaultManager] fileExistsAtPath: engineStatePath isDirectory:NO]) {
        NSDictionary *state = [NSDictionary dictionaryWithContentsOfFile: engineStatePath];
        collectionState.lastSyncDate = [state objectForKey: @"lastSyncDate"];
        collectionState.lastSyncID = [state objectForKey: @"lastSyncID"];
    }
    
    return collectionState;
}

- (void) saveState: (SyncCollectionState*) collectionState forCollection: (SyncCollection*) collection
{
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *syncClientDataPath = [applicationSupportPath stringByAppendingPathComponent: [NSString stringWithFormat: @"SyncClient-%@", _identifier]];
    NSString *engineStatePath = [syncClientDataPath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@-state.plist", collection.name]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:syncClientDataPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:syncClientDataPath withIntermediateDirectories: YES attributes:nil error:NULL];
    }
    
    NSDictionary *state = @{
        @"lastSyncDate": collectionState.lastSyncDate,
        @"lastSyncID": collectionState.lastSyncID
    };
    
    [state writeToFile:engineStatePath atomically:YES];
}

@end
