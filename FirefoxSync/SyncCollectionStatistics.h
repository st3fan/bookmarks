// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@interface SyncCollectionStatistics : NSObject

- (instancetype) initWithDeletes: (NSUInteger) deletes inserts: (NSUInteger) inserts updates: (NSUInteger) updates;

@property (readonly) NSUInteger deletes;
@property (readonly) NSUInteger inserts;
@property (readonly) NSUInteger updates;

@end
