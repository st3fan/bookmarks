// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncRecord.h"
#import "SyncCollection.h"


@implementation SyncCollection

- (instancetype) initWithName: (NSString*) name storagePath: (NSString*) storagePath
{
    if ((self = [super init]) != nil) {
        _name = [name copy];
        _storagePath = [storagePath copy];
    }
    return self;
}

- (void) startup
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) reset
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) startSyncSession
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) beginBatch
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) processRecord: (SyncRecord*) record change: (SyncCollectionChangeType) changeType
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) commitBatch
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) finishSyncSession
{
    [self doesNotRecognizeSelector: _cmd];
}

- (void) shutdown
{
    [self doesNotRecognizeSelector: _cmd];
}

- (BOOL) containsRecordWithIdentifier: (NSString*) identifier
{
    [self doesNotRecognizeSelector: _cmd];
    return NO;
}

@end