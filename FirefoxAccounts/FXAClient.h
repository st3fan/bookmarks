// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


extern NSString* const FXAErrorDomain;

extern const NSInteger FXAErrorCodeAccountAlreadyExists;
extern const NSInteger FXAErrorCodeAccountDoesNotExist;
extern const NSInteger FXAErrorCodeIncorrectPassword;
extern const NSInteger FXAErrorCodeUnverifiedAccount;
extern const NSInteger FXAErrorCodeInvalidVerificationCode;
extern const NSInteger FXAErrorCodeInvalidRequestBodyFormat;
extern const NSInteger FXAErrorCodeInvalidRequestBodyParameters;
extern const NSInteger FXAErrorCodeMissingRequestBodyParameters;
extern const NSInteger FXAErrorCodeInvalidRequestSignature;
extern const NSInteger FXAErrorCodeInvalidAuthenticationToken;
extern const NSInteger FXAErrorCodeInvalidAuthenticationTimestamp;

extern const NSInteger FXAErrorCodeServiceTemporarilyUnvailable;

extern const NSInteger FXAErrorCodeUnknownError;


@class RSAKeyPair;
@class FXACertificate;


@interface FXACredentials : NSObject
- (id) initWithEmail: (NSString*) email password: (NSString*) password;
@property (readonly) NSString *email;
@property (readonly) NSString *password;
@property (readonly) NSData *authPW;
@property (readonly) NSData *unwrapBKey;
@end

@interface FXACreateAccountResult : NSObject
@property (atomic,copy) NSString *uid;
@end

@interface FXALoginResult : NSObject
@property (atomic,copy) NSString *uid;
@property (atomic,copy) NSData *sessionToken;
@property (atomic,copy) NSData *keyFetchToken;
@property BOOL verified;
@end

@interface FXASessionData : NSObject
@property BOOL verified;
@property (atomic,copy) NSString *uid;
@property (atomic,copy) NSData *sessionToken;
@property (atomic,copy) NSData *keyFetchToken;
@end

@interface FXAKeysData : NSObject
@property (atomic,copy) NSData *a;
@property (atomic,copy) NSData *b;
@end

typedef void (^FXACreateAccountCompletionHandler)(FXACreateAccountResult *createAccountResult, FXACredentials *credentials, NSError* error);
typedef void (^FXAClientLoginCompletionHandler)(FXALoginResult *loginResult, NSError* error);
typedef void (^FXAClientDestroySessionCompletionHandler)(NSError* error);
typedef void (^FXAClientFetchKeysCompletionHandler)(FXAKeysData *keysData, NSError* error);
typedef void (^FXAClientSignCertificateCompletionHandler)(FXACertificate *certificate, NSError* error);

@interface FXAClient : NSObject

- (id) initWithEndpoint: (NSURL*) endpoint;

- (void) createAccountWithEmail: (NSString*) email password: (NSString*) password completionHandler: (FXACreateAccountCompletionHandler) completionHandler;
- (void) loginWithCredentials: (FXACredentials*) credentials completionHandler: (FXAClientLoginCompletionHandler) completionHandler;
- (void) destroySessionWithToken: (NSData*) sessionToken completionHandler: (FXAClientDestroySessionCompletionHandler) completionHandler;
- (void) fetchKeysWithKeyFetchToken: (NSData*) keyFetchToken credentials: (FXACredentials*) credentials completionHandler: (FXAClientFetchKeysCompletionHandler) completionHandler;
- (void) signCertificateWithKeyPair: (RSAKeyPair*) keyPair duration: (NSUInteger) duration sessionToken: (NSData*) sessionToken completionHandler: (FXAClientSignCertificateCompletionHandler) completionHandler;

@end
