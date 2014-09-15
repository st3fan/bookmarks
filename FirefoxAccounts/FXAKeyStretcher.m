// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#include "NSData+Utils.h"
#include "NSData+KeyDerivation.h"
#import "FXAKeyStretcher.h"

@implementation FXAKeyStretcher {
    NSDictionary *_parameters;
}

- (id) initWithJSONParameters: (NSDictionary*) parameters
{
    if ((self = [super init]) != nil) {
        _parameters = [parameters copy];
    }
    return self;
}

- (void) stretchUsername: (NSString*) username password: (NSString*) password completionHandler: (FXAKeyStretcherCompletionHandler) completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), ^{
        // K1 = pbkdf2_bin(passwordUTF8, KWE("first-PBKDF", emailUTF8), PBKDF2_rounds_1, keylen=1*32, hashfunc=sha256)
        NSData *salt = [[NSString stringWithFormat: @"identity.mozilla.com/picl/v1/first-PBKDF:%@", username] dataUsingEncoding: NSUTF8StringEncoding];
        NSData *K1 = [[password dataUsingEncoding: NSUTF8StringEncoding] derivePBKDF2HMACSHA256KeyWithSalt: salt
            iterations: [[_parameters objectForKey: @"PBKDF2_rounds_1"] integerValue] length: 32];
        
        // k2 = scrypt.hash(k1, KW("scrypt"), N=scrypt_N, r=scrypt_r, p=scrypt_p, buflen=1*32)
        salt = [@"identity.mozilla.com/picl/v1/scrypt" dataUsingEncoding: NSUTF8StringEncoding];
        NSData *K2 = [K1 deriveSCryptKeyWithSalt: salt n: [[_parameters objectForKey: @"scrypt_N"] integerValue]
            r: [[_parameters objectForKey: @"scrypt_r"] integerValue] p: [[_parameters objectForKey: @"scrypt_p"] integerValue] length: 32];
        
        // stretchedPW = pbkdf2_bin(k2+passwordUTF8, KWE("second-PBKDF", emailUTF8), PBKDF2_rounds_2, keylen=1*32, hashfunc=sha256)
        salt = [[NSString stringWithFormat: @"identity.mozilla.com/picl/v1/second-PBKDF:%@", username] dataUsingEncoding: NSUTF8StringEncoding];
        NSData *stretchedPassword = [[NSData dataByAppendingDatas: @[K2, [password dataUsingEncoding: NSUTF8StringEncoding]]] derivePBKDF2HMACSHA256KeyWithSalt: salt
            iterations: [[_parameters objectForKey: @"PBKDF2_rounds_2"] integerValue] length: 32];
        
        completionHandler(stretchedPassword, nil);
    });
}

@end
