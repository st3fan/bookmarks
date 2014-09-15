// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>
#import "SyncCredentials.h"


@interface SyncBasicCredentials : SyncCredentials

- (instancetype) initWithUsername: (NSString*) username password: (NSString*) password recoveryKey: (NSString*) recoveryKey;

@property (readonly) NSString *username;
@property (readonly) NSString *password;
@property (readonly) NSString *recoveryKey;

@end
