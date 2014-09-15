// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@class SyncKeyBundle;


@interface SyncRecord : NSObject

- (instancetype) initWithJSONRepresentation: (NSDictionary*) dictionary;
- (instancetype) initWithJSONRepresentation: (NSDictionary*) dictionary keyBundle: (SyncKeyBundle*) keyBundle;

- (instancetype) initWithIdentifier: (NSString*) identifier modified: (double) modified payload: (NSDictionary*) payload;

@property (atomic, readonly) NSDictionary *payload;
@property (atomic, readonly) NSString *identifier;
@property (atomic, readonly) NSNumber *modified;

@end
