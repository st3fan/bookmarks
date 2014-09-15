// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "NSData+KeyDerivation.h"
#import "NSData+SHA.h"
#import "NSData+Utils.h"
#import "SyncUtils.h"
#import "SyncKeyBundle.h"


@implementation SyncKeyBundle

- (instancetype) initWithEncryptionKey: (NSData*) encryptionKey validationKey: (NSData*) validationKey
{
    if ((self = [super init]) != nil) {
        _encryptionKey = encryptionKey;
        _validationKey = validationKey;
    }
    return self;
}

- (instancetype) initWithEncodedRecoveryKey: (NSString*) recoveryKey username: (NSString*) username
{
    NSData *decodedRecoveryKey = [SyncUtils decodeRecoveryKey: recoveryKey];

    if ((self = [super init]) != nil) {
        // TODO: Why does NSData#deriveHKDF not work?
        NSData* contextInfo = [[@"Sync-AES_256_CBC-HMAC256" stringByAppendingString: [SyncUtils encodeUsername: username]] dataUsingEncoding: NSUTF8StringEncoding];

        char c1 = 0x01;
        NSData *t1 = [NSData dataByAppendingDatas: @[contextInfo, [NSData dataWithBytes: &c1 length: 1]]];
        _encryptionKey = [t1 HMACSHA256WithKey: decodedRecoveryKey];
        
        char c2 = 0x02;
        NSData *t2 = [NSData dataByAppendingDatas: @[_encryptionKey, contextInfo, [NSData dataWithBytes: &c2 length: 1]]];
        _validationKey = [t2 HMACSHA256WithKey: decodedRecoveryKey];
    }
    return self;
}

- (instancetype) initWithKey: (NSData*) key // TODO: Maybe WithFXAKeyData is better?
{
    if ((self = [super init]) != nil) {
        NSData *t = [key deriveHKDFSHA256KeyWithSalt: [NSData data]
            contextInfo: [@"identity.mozilla.com/picl/v1/oldsync" dataUsingEncoding: NSUTF8StringEncoding] length: 2*32];
        _encryptionKey = [t subdataWithRange: NSMakeRange( 0, 32)];
        _validationKey = [t subdataWithRange: NSMakeRange(32, 32)];
    }
    return self;
}

@end
