// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface SRPServer : NSObject
- (id) initWithUsername: (NSData*) username password: (NSData*) password salt: (NSData*) salt;
- (NSData*) one;
- (NSData*) twoWithA: (NSData*) A M1: (NSData*) M1;
- (NSData*) key;

+ (NSData*) verifierValueForData: (NSData*) data salt: (NSData*) salt;
+ (NSData*) verifierValueForUsername: (NSData*) username password: (NSData*) password salt: (NSData*) salt;
@end
