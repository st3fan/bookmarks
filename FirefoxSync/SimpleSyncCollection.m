// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncRecord.h"
#import "SyncCollection.h"
#import "SimpleSyncCollection.h"


@implementation SimpleSyncCollection {
    NSMutableDictionary *_recordsById;
}

- (instancetype) initWithName: (NSString*) name storagePath: (NSString*) storagePath
{
    if ((self = [super initWithName:name storagePath:storagePath]) != nil) {
        _recordsById = [NSMutableDictionary new];
    }
    return self;
}

- (void) initialize
{
    NSString *path = [self.storagePath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@-records.json", self.name]];

    NSError *readError = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&readError];
    if (readError != nil) {
        NSLog(@"Could not read data from disk: %@", [readError localizedDescription]);
        return;
    }

    NSError *serializationError = nil;
    NSArray *objects = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
    if (serializationError != nil) {
        NSLog(@"Could not serialize records to JSON: %@", [serializationError localizedDescription]);
        return;
    }

    for (NSDictionary *object in objects) {
        [_recordsById setObject: object forKey: [object objectForKey: @"id"]];
    }
}

- (void) reset
{
    [_recordsById removeAllObjects];
}

- (void) processRecord: (SyncRecord*) record change: (SyncCollectionChangeType) changeType
{
    switch (changeType) {
        case SyncCollectionChangeTypeDelete: {
            NSLog(@"SimpleSyncCollection: Deleting record %@", record.identifier);
            [_recordsById removeObjectForKey: record.identifier];
            break;
        }
        case SyncCollectionChangeTypeInsert: {
            NSLog(@"SimpleSyncCollection: Inserting record %@", record.identifier);
            [_recordsById setObject: record.payload forKey: record.identifier];
            break;
        }
        case SyncCollectionChangeTypeUpdate: {
            NSLog(@"SimpleSyncCollection: Updating record %@", record.identifier);
            [_recordsById setObject: record.payload forKey: record.identifier];
            break;
        }
    }
}

- (void) shutdown
{
    NSString *path = [self.storagePath stringByAppendingPathComponent: [NSString stringWithFormat: @"%@-records.json", self.name]];
    NSLog(@"SimpleSyncCollection: Writing database to %@", path);
    
    NSError *serializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject: [_recordsById allValues] options:NSJSONWritingPrettyPrinted error:&serializationError];
    if (serializationError != nil) {
        NSLog(@"Could not serialize records to JSON: %@", [serializationError localizedDescription]);
        return;
    }
    
    NSError *writeError = nil;
    [data writeToFile: path options:NSDataWritingAtomic error: &writeError];
    if (writeError != nil) {
        NSLog(@"Could not write data to disk: %@", [writeError localizedDescription]);
    }
}

- (BOOL) containsRecordWithIdentifier: (NSString*) identifier
{
    return ([_recordsById objectForKey: identifier] != nil);
}

#pragma mark -

- (NSArray*) records
{
    return [NSArray arrayWithArray: [_recordsById allValues]];
}

@end
