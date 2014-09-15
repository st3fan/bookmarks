// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "NSData+SHA.h"
#import "NSData+Base16.h"
#import "NSData+KeyDerivation.h"

#import "FXAClient.h"
#import "FXAUtils.h"


static NSString* const kFXAv1PasswordStretchingType = @"PBKDF2/scrypt/PBKDF2/v1";
static NSString* const kFXAv1SRPType = @"SRP-6a/SHA256/2048/v1";


@implementation FXARequestTokenTriplet
@end


@implementation FXAUtils

+ (NSData*) quickStretchPassword: (NSString*) password email: (NSString*) email
{
    NSData *salt = [[NSString stringWithFormat: @"identity.mozilla.com/picl/v1/quickStretch:%@", email] dataUsingEncoding: NSUTF8StringEncoding];
    return [[password dataUsingEncoding: NSUTF8StringEncoding] derivePBKDF2HMACSHA256KeyWithSalt: salt iterations:1000 length: 32];
}

+ (NSData*) deriveAuthPWFromQuickStretchedPassword: (NSData*) quickStretchedPassword
{
    NSData *ctx = [@"identity.mozilla.com/picl/v1/authPW" dataUsingEncoding: NSUTF8StringEncoding];
    return [quickStretchedPassword deriveHKDFSHA256KeyWithSalt: [NSData data] contextInfo: ctx length: 32];
}

+ (NSData*) deriveUnwrapBKeyFromQuickStretchedPassword: (NSData*) quickStretchedPassword
{
    NSData *ctx = [@"identity.mozilla.com/picl/v1/unwrapBkey" dataUsingEncoding: NSUTF8StringEncoding];
    return [quickStretchedPassword deriveHKDFSHA256KeyWithSalt: [NSData data] contextInfo: ctx length: 32];
}

+ (FXARequestTokenTriplet*) deriveRequestTokenTripletFromToken: (NSData*) token name: (NSString*) name
{
    NSData *ctx = [[NSString stringWithFormat: @"identity.mozilla.com/picl/v1/%@", name] dataUsingEncoding: NSUTF8StringEncoding];
    NSData *t = [token deriveHKDFSHA256KeyWithSalt: nil contextInfo: ctx length: 3*32];
    
    FXARequestTokenTriplet *tokenTriplet = [FXARequestTokenTriplet new];
    tokenTriplet.tokenId = [t subdataWithRange: NSMakeRange(0, 32)];
    tokenTriplet.requestHMACKey = [t subdataWithRange: NSMakeRange(32, 32)];
    tokenTriplet.requestKey = [t subdataWithRange: NSMakeRange(64, 32)];
    
    return tokenTriplet;
}


+ (BOOL) validateAccountCreateResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

//
// {
//   passwordStretching: {
//        PBKDF2_rounds_1: 20000,
//        PBKDF2_rounds_2: 20000,
//        salt: "d8f159adc6d4e2e65bb97d7b8acee11c00000000000000000000000000000000",
//        scrypt_N: 65536,
//        scrypt_p: 1,
//        scrypt_r: 8,
//        type: "PBKDF2/scrypt/PBKDF2/v1"
//    },
//    srp: {
//        B: "68166c0d171e7cc4010143cf7e48d3243a601911723a590f2fb94315a252ffbb00eedc6691384021d0ed012d57459c442875fa089d8e586c233a49b061bc90ed5c10186e7ddefdd1f90d0a38aea54a54f40376bd49177cd6ecf56ab42fb6c8f055eb4020edfd35309175dbd7626c880de2762426e113dce819f23e72843360e0f2d58c80fdae74832eaa67a4bbc3ca09963e5491d87b339487565e83f5968e761aa69ba449c077186bc63cb59c58db98f131e2acf88b58d749f5eb7bf41a8fdb1c11dcf1c59547e8b1bcc6ccd478d347a2acee89d2ff3d2bf5e6159964bf77e9a33ad5c969b5ecc8d3df54ee7a5d84efc909545b88b0b1b2ef58f4d1754c8cf8",
//        salt: "7d2cdcbeef65e6d279d53cd40383542300000000000000000000000000000000",
//        type: "SRP-6a/SHA256/2048/v1";
//    },
//    srpToken: "cbfedfebd3f399b8a85677e4ae9a14f0347bda9bccbcebb2965f8a647f14adc5";
// }
//

+ (BOOL) validateAccountLoginResponse: (id) response error: (NSError**) error
{
//    if ([response isKindOfClass: [NSDictionary class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 1 userInfo: nil];
//        return NO;
//    }
//    
//    //
//    
//    NSDictionary *passwordStretching = [response objectForKey: @"passwordStretching"];
//    if (passwordStretching == nil || [passwordStretching isKindOfClass: [NSDictionary class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 2 userInfo: nil];
//        return NO;
//    }
//    
//    NSString *passwordStretchingType = [passwordStretching objectForKey: @"type"];
//    if (passwordStretchingType == nil || [passwordStretchingType isKindOfClass: [NSString class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 3 userInfo: nil];
//        return NO;
//    }
//    
//    if ([passwordStretchingType isEqualToString: kFXAv1PasswordStretchingType] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 4 userInfo: nil];
//        return NO;
//    }
//    
//    for (NSString *key in @[@"PBKDF2_rounds_1", @"PBKDF2_rounds_2", @"scrypt_N", @"scrypt_p", @"scrypt_r"]) {
//        NSNumber *value = [passwordStretching objectForKey: key];
//        if (value == nil || [value isKindOfClass: [NSNumber class]] == NO) {
//            *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 5 userInfo: nil];
//            return NO;
//        }
//    }
//
//    for (NSString *key in @[@"salt"]) {
//        NSString *value = [passwordStretching objectForKey: key];
//        if (value == nil || [value isKindOfClass: [NSString class]] == NO) {
//            *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 6 userInfo: nil];
//            return NO;
//        }
//        NSData *decodedValue = [[NSData alloc] initWithBase16EncodedString: value];
//        if (decodedValue == nil || [decodedValue length] == 0) {
//            *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 7 userInfo: nil];
//            return NO;
//        }
//    }
//    
//    //
//
//    NSDictionary *srp = [response objectForKey: @"srp"];
//    if (srp == nil || [srp isKindOfClass: [NSDictionary class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 8 userInfo: nil];
//        return NO;
//    }
//
//    NSString *srpType = [srp objectForKey: @"type"];
//    if (srpType == nil || [srpType isKindOfClass: [NSString class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 9 userInfo: nil];
//        return NO;
//    }
//
//    if ([srpType isEqualToString: kFXAv1SRPType] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 10 userInfo: nil];
//        return NO;
//    }
//
//    for (NSString *key in @[@"B", @"salt"]) {
//        NSString *value = [srp objectForKey: key];
//        if (value == nil || [value isKindOfClass: [NSString class]] == NO) {
//            *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 11 userInfo: nil];
//            return NO;
//        }
//        NSData *decodedValue = [[NSData alloc] initWithBase16EncodedString: value];
//        if (decodedValue == nil || [decodedValue length] == 0) {
//            *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 12 userInfo: nil];
//            return NO;
//        }
//    }
//    
//    //
//    
//    NSString *srpToken = [response objectForKey: @"srpToken"];
//    if (srpToken == nil || [srpToken isKindOfClass: [NSString class]] == NO) {
//        *error = [NSError errorWithDomain: @"ca.arentz.FirefoxAccounts" code: 13 userInfo: nil];
//        return NO;
//    }
//
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

+ (BOOL) validateFinishAuthResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

+ (BOOL) validateCreateSessionResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

+ (BOOL) validateFetchKeysResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

+ (BOOL) validateErrorResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    if (error != NULL) {
        *error = nil;
    }
    return YES;
}

+ (NSError*) errorFromErrorResponse: (NSDictionary*) errorResponse
{
    NSInteger code = [[errorResponse objectForKey: @"errno"] integerValue];
    return [NSError errorWithDomain: FXAErrorDomain code: code userInfo: @{@"FXAErrorResponse": errorResponse}];
}

+ (BOOL) validateSignCertificateResponse: (id) response error: (NSError**) error
{
    // TODO: Implement this
    *error = nil;
    return YES;
}

+ (NSString*) computeClientState: (NSData*) key
{
    if (key == nil || [key length] == 0) {
        return nil;
    }
    
    return [[[key SHA256Hash] subdataWithRange: NSMakeRange(0, 16)] base16EncodedStringWithOptions: NSDataBase16EncodingOptionsLowerCase];
}

@end
