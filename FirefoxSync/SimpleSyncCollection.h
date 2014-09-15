// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncCollection.h"


@interface SimpleSyncCollection : SyncCollection

- (instancetype) initWithName: (NSString*) name storagePath: (NSString*) storagePath;

- (void) initialize;
- (void) reset;
- (void) processRecord: (SyncRecord*) record change: (SyncCollectionChangeType) changeType;
- (void) shutdown;

- (NSArray*) records;

@end
