// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface SRPClient : NSObject
- (id) initWithUsername: (NSData*) username password: (NSData*) password salt: (NSData*) salt;
- (NSData*) oneWithA: (NSData*) a;
- (NSData*) twoWithB: (NSData*) bd;
- (BOOL) threeWithM2: (NSData*) M2;
- (NSData*) key;
@end
