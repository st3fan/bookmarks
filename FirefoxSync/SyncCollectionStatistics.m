// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncCollectionStatistics.h"


@implementation SyncCollectionStatistics

- (instancetype) initWithDeletes: (NSUInteger) deletes inserts: (NSUInteger) inserts updates: (NSUInteger) updates
{
    if ((self = [super init]) != nil) {
        _deletes = deletes;
        _inserts = inserts;
        _updates = updates;
    }
    return self;
}

@end
