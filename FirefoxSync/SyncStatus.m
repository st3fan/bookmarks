// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncStatus.h"


@implementation SyncStatus

- (instancetype) initWithCollectionStatistics: (NSDictionary*) collectionStatistics
{
    if ((self = [super init]) != nil) {
        _collectionStatistics = [collectionStatistics copy];
    }
    return self;
}

@end
