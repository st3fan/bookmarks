// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <CommonCrypto/CommonCrypto.h>

#import "NSData+SHA.h"
#import "NSData+Base16.h"
#import "NSData+Base32.h"

#import "SyncKeyBundle.h"
#import "SyncUtils.h"


@implementation SyncUtils

+ (NSString*) encodeUsername: (NSString*) username
{
    NSData *hashedUsername = [[[username lowercaseString] dataUsingEncoding: NSUTF8StringEncoding] SHA1Hash];
    return [[hashedUsername base32EncodedStringWithOptions: NSDataBase32EncodingOptionsDefault] lowercaseString];
}

+ (NSString*) encodeRecoveryKey: (NSData*) recoveryKey
{
    return [recoveryKey base32EncodedStringWithOptions:NSDataBase32EncodingOptionsUserFriendly];
}

+ (NSData*) decodeRecoveryKey: (NSString*) encodedRecoveryKey
{
    encodedRecoveryKey = [encodedRecoveryKey stringByReplacingOccurrencesOfString: @"-" withString: @""];
    return [[NSData alloc] initWithBase32EncodedString: encodedRecoveryKey options:NSDataBase32DecodingOptionsUserFriendly];
}

+ (NSDictionary*) decryptPayload: (NSDictionary*) encryptedPayload withKeyBundle: (SyncKeyBundle*) keyBundle
{
    NSData *ciphertext = [[NSData alloc] initWithBase64EncodedString: encryptedPayload[@"ciphertext"] options: 0];
    if (ciphertext == nil) {
        return nil;
    }
    
    NSData *hmac = [[NSData alloc] initWithBase16EncodedString: encryptedPayload[@"hmac"] options: NSDataBase16DecodingOptionsDefault];
    if (hmac == nil) {
        return nil;
    }
    
    NSData *iv = [[NSData alloc] initWithBase64EncodedString: encryptedPayload[@"IV"] options: 0];
    if (iv == nil) {
        return nil;
    }
    
    // Check the HMAC
    
    NSData *calculatedHMAC = [[encryptedPayload[@"ciphertext"] dataUsingEncoding: NSASCIIStringEncoding] HMACSHA256WithKey: keyBundle.validationKey];
    if (![calculatedHMAC isEqualToData: hmac]) {
        return nil;
    }
    
    // Decrypt the data

    void *buffer = calloc([ciphertext length], sizeof(uint8_t));
    if (buffer == nil) {
        return nil;
    }
    
    size_t dataOutMoved = 0;
    
    CCCryptorStatus status = CCCrypt(
        kCCDecrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        [keyBundle.encryptionKey bytes],
        kCCKeySizeAES256,
        [iv bytes],
        [ciphertext bytes],
        [ciphertext length],
        buffer,
        [ciphertext length],
        &dataOutMoved
    );
    
    if (status != kCCSuccess) {
        return nil;
    }
    
    NSData *decryptedPayloadData = [NSData dataWithBytesNoCopy: buffer length: dataOutMoved freeWhenDone: YES];

    // JSON Decode
    
    return [NSJSONSerialization JSONObjectWithData: decryptedPayloadData options:0 error: NULL];
}

@end
