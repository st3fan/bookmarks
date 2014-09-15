// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface FXARequestTokenTriplet : NSObject
@property (atomic,copy) NSData *tokenId;
@property (atomic,copy) NSData *requestHMACKey;
@property (atomic,copy) NSData *requestKey;
@end

@interface FXAUtils : NSObject

+ (NSData*) quickStretchPassword: (NSString*) password email: (NSString*) email;
+ (NSData*) deriveAuthPWFromQuickStretchedPassword: (NSData*) quickStretchedPassword;
+ (NSData*) deriveUnwrapBKeyFromQuickStretchedPassword: (NSData*) quickStretchedPassword;

+ (FXARequestTokenTriplet*) deriveRequestTokenTripletFromToken: (NSData*) token name: (NSString*) name;

+ (BOOL) validateAccountCreateResponse: (id) response error: (NSError**) error;
+ (BOOL) validateAccountLoginResponse: (id) response error: (NSError**) error;
+ (BOOL) validateFinishAuthResponse: (id) response error: (NSError**) error;
+ (BOOL) validateCreateSessionResponse: (id) response error: (NSError**) error;
+ (BOOL) validateFetchKeysResponse: (id) response error: (NSError**) error;
+ (BOOL) validateSignCertificateResponse: (id) response error: (NSError**) error;

+ (BOOL) validateErrorResponse: (id) response error: (NSError**) error;
+ (NSError*) errorFromErrorResponse: (NSDictionary*) errorResponse;

+ (NSString*) computeClientState: (NSData*) key;

@end
