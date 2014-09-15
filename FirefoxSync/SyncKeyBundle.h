// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface SyncKeyBundle : NSObject

- (instancetype) initWithEncryptionKey: (NSData*) encryptionKey validationKey: (NSData*) validationKey;
- (instancetype) initWithEncodedRecoveryKey: (NSString*) recoveryKey username: (NSString*) username;
- (instancetype) initWithKey: (NSData*) key;

@property (readonly) NSData *encryptionKey;
@property (readonly) NSData *validationKey;

@end
