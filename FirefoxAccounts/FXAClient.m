// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "HawkCredentials.h"
#import "CHNumber.h"
#import "NSData+SHA.h"
#import "NSData+Base16.h"
#import "NSData+KeyDerivation.h"
#import "NSData+Utils.h"
#import "SRPClient.h"
#import "SRPServer.h"
#import "FXAUtils.h"
#import "FXAKeyStretcher.h"
#import "RSAKeyPair.h"
#import "FXACertificate.h"
#import "FXAClient.h"


NSString* const FXAErrorDomain = @"FXAErrorDomain";

const NSInteger FXAErrorCodeAccountAlreadyExists = 101;
const NSInteger FXAErrorCodeAccountDoesNotExist = 102;
const NSInteger FXAErrorCodeIncorrectPassword = 103;
const NSInteger FXAErrorCodeUnverifiedAccount = 104;
const NSInteger FXAErrorCodeInvalidVerificationCode = 105;
const NSInteger FXAErrorCodeInvalidRequestBodyFormat = 106;
const NSInteger FXAErrorCodeInvalidRequestBodyParameters = 107;
const NSInteger FXAErrorCodeMissingRequestBodyParameters = 108;
const NSInteger FXAErrorCodeInvalidRequestSignature = 109;
const NSInteger FXAErrorCodeInvalidAuthenticationToken = 110;
const NSInteger FXAErrorCodeInvalidAuthenticationTimestamp = 111;

const NSInteger FXAErrorCodeServiceTemporarilyUnvailable = 201;

const NSInteger FXAErrorCodeUnknownError = 999;


static NSString* const kFXAv1PasswordStretchingType = @"PBKDF2/scrypt/PBKDF2/v1";
static NSString* const kFXAv1SRPType = @"SRP-6a/SHA256/2048/v1";

@implementation FXACredentials
- (id) initWithEmail: (NSString*) email password: (NSString*) password
{
    if ((self = [super init]) != nil) {
        _email = [email copy];
        _password = [password copy];
        NSData *quickStretchedPassword = [FXAUtils quickStretchPassword: password email: email];
        _authPW = [FXAUtils deriveAuthPWFromQuickStretchedPassword: quickStretchedPassword];
        _unwrapBKey = [FXAUtils deriveUnwrapBKeyFromQuickStretchedPassword: quickStretchedPassword];
    }
    return self;
}
@end

@implementation FXACreateAccountResult
@end

@implementation FXALoginResult
@end


@implementation FXASessionData
@end


@implementation FXAKeysData
@end


@implementation FXAClient {
    NSURL *_endpoint;
    NSURLSession *_session;
}

- (id) initWithEndpoint: (NSURL*) endpoint
{
    if ((self = [super init]) != nil) {
        _endpoint = endpoint;

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = @{@"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:31.0) Gecko/20100101 Firefox/31.0"};
        _session = [NSURLSession sessionWithConfiguration: sessionConfiguration];
    }
    return self;
}

- (NSMutableURLRequest*) requestWithURL: (NSURL*) url method: (NSString*) method object: (id) object
{
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject: object options:0 error: &error];
    if (body == nil) {
        return nil;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPBody = body;
    request.HTTPMethod = method;
    
    return request;
}

- (NSMutableURLRequest*) requestWithURL: (NSURL*) url method: (NSString*) method hawkCredentials: (HawkCredentials*) hawkCredentials object: (id) object
{
    NSMutableURLRequest *request = [self requestWithURL: url method: method object: object];
    [request addValue: [hawkCredentials authorizationHeaderForRequest: request ext: nil] forHTTPHeaderField: @"Authorization"];
    return request;
}

- (NSMutableURLRequest*) requestWithURL: (NSURL*) url method: (NSString*) method
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    request.HTTPMethod = method;
    
    return request;
}

- (NSMutableURLRequest*) requestWithURL: (NSURL*) url method: (NSString*) method hawkCredentials: (HawkCredentials*) hawkCredentials
{
    NSMutableURLRequest *request = [self requestWithURL: url method: method];
    [request addValue: [hawkCredentials authorizationHeaderForRequest: request ext: nil] forHTTPHeaderField: @"Authorization"];
    return request;
}

- (NSDictionary*) generateSRPConfigurationWithUsername: (NSString*) username password: (NSData*) password
{
    NSData *salt = [NSData randomDataWithLength: 32];
    NSData *verifier = [SRPServer verifierValueForUsername: [username dataUsingEncoding: NSUTF8StringEncoding] password: password salt: salt];

    return @{
        @"type": kFXAv1SRPType,
        @"verifier": [verifier base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault],
        @"salt": [salt base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault]
    };
}

- (NSDictionary*) generatePasswordStretchingConfiguration
{
    return @{
        @"type": kFXAv1PasswordStretchingType,
        @"PBKDF2_rounds_1": @20000,
        @"scrypt_N": @65536,
        @"scrypt_r": @8,
        @"scrypt_p": @1,
        @"PBKDF2_rounds_2": @20000,
        @"salt": [[NSData randomDataWithLength: 32] base16EncodedStringWithOptions:NSDataBase16EncodingOptionsDefault]
    };
}

#pragma mark - API Methods

- (void) createAccountWithEmail: (NSString*) email password: (NSString*) password completionHandler: (FXACreateAccountCompletionHandler) completionHandler
{
    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: email password: password];

    NSDictionary *object = @{
         @"email": credentials.email
        ,@"authPW": [credentials.authPW base16EncodedStringWithOptions:NSDataBase16EncodingOptionsDefault]
        ,@"preVerified": @YES
    };
    

    NSURLRequest *request = [self requestWithURL: [NSURL URLWithString: @"/v1/account/create" relativeToURL: _endpoint] method: @"POST" object: object];
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, nil, error);
            return;
        }

        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                completionHandler(nil, nil, serializationError);
                return;
            }
            
            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                completionHandler(nil, nil, validationError);
                return;
            }
        
            completionHandler(nil, nil, [FXAUtils errorFromErrorResponse: errorResponse]);
            return;
        }

        NSError *serializationError = nil;
        NSDictionary *accountCreateResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            completionHandler(nil, nil, serializationError);
            return;
        }
        
        NSError *validationError = nil;
        if (![FXAUtils validateAccountCreateResponse: accountCreateResponse error: &validationError]) {
            completionHandler(nil, nil, validationError);
            return;
        }
        
        FXACreateAccountResult *result = [FXACreateAccountResult new];
        result.uid = accountCreateResponse[@"uid"];
        
        completionHandler(result, credentials, nil);
    }];
    
    [task resume];
}

- (void) loginWithCredentials: (FXACredentials*) credentials completionHandler: (FXAClientLoginCompletionHandler) completionHandler
{
    NSDictionary *object = @{
        @"email": credentials.email,
        @"authPW": [credentials.authPW base16EncodedStringWithOptions:NSDataBase16EncodingOptionsDefault]
    };
    
    NSURLRequest *request = [self requestWithURL: [NSURL URLWithString: @"/v1/account/login?keys=true" relativeToURL: _endpoint] method: @"POST" object: object];
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            //});
            return;
        }

        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                completionHandler(nil, serializationError);
                return;
            }
            
            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                completionHandler(nil, validationError);
                return;
            }
        
            completionHandler(nil, [FXAUtils errorFromErrorResponse: errorResponse]);
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *accountLoginResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            completionHandler(nil, serializationError);
            return;
        }
        
        NSError *validationError = nil;
        if (![FXAUtils validateAccountLoginResponse: accountLoginResponse error: &validationError]) {
            completionHandler(nil, validationError);
            return;
        }
        
        FXALoginResult *result = [FXALoginResult new];
        result.uid = accountLoginResponse[@"uid"];
        result.keyFetchToken = [[NSData alloc] initWithBase16EncodedString: accountLoginResponse[@"keyFetchToken"] options: NSDataBase16DecodingOptionsDefault];
        result.sessionToken = [[NSData alloc] initWithBase16EncodedString: accountLoginResponse[@"sessionToken"] options: NSDataBase16DecodingOptionsDefault];
        result.verified = [accountLoginResponse[@"verified"] boolValue];
        
        completionHandler(result, nil);
    }];
    
    [task resume];
}

- (void) destroySessionWithToken: (NSData*) sessionToken completionHandler: (FXAClientDestroySessionCompletionHandler) completionHandler
{
    FXARequestTokenTriplet *tokenTriplet = [FXAUtils deriveRequestTokenTripletFromToken: sessionToken name: @"sessionToken"];
    HawkCredentials *credentials = [[HawkCredentials alloc] initWithKeyIdentifier: [tokenTriplet.tokenId base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault] key: tokenTriplet.requestHMACKey];

    NSURLRequest *request = [self requestWithURL: [NSURL URLWithString: @"/v1/session/destroy" relativeToURL: _endpoint] method: @"POST" hawkCredentials: credentials object: @{}];

    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(error);
            //});
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(serializationError);
                //});
                return;
            }
            
            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(validationError);
                //});
                return;
            }
        
            completionHandler([FXAUtils errorFromErrorResponse: errorResponse]);
            return;
        }
        
        completionHandler(nil);
    }];
    [task resume];
}

- (void) fetchKeysWithKeyFetchToken: (NSData*) keyFetchToken credentials: (FXACredentials*) credentials completionHandler: (FXAClientFetchKeysCompletionHandler) completionHandler
{
    FXARequestTokenTriplet *tokenTriplet = [FXAUtils deriveRequestTokenTripletFromToken: keyFetchToken name: @"keyFetchToken"];
    HawkCredentials *hawkCredentials = [[HawkCredentials alloc] initWithKeyIdentifier: [tokenTriplet.tokenId base16EncodedStringWithOptions: NSDataBase16EncodingOptionsDefault] key: tokenTriplet.requestHMACKey];

    NSURLRequest *request = [self requestWithURL: [NSURL URLWithString: @"/v1/account/keys" relativeToURL: _endpoint] method: @"GET" hawkCredentials: hawkCredentials];
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            //});
            return;
        }

        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, serializationError);
                //});
                return;
            }
            
            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, validationError);
                //});
                return;
            }
        
            completionHandler(nil, [FXAUtils errorFromErrorResponse: errorResponse]);
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *fetchKeysResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, serializationError);
            //});
            return;
        }
        
        NSError *validationError = nil;
        if (![FXAUtils validateFetchKeysResponse: fetchKeysResponse error: &validationError]) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, validationError);
            //});
            return;
        }

        //
        
        NSData *t = [tokenTriplet.requestKey deriveHKDFSHA256KeyWithSalt: nil contextInfo: [@"identity.mozilla.com/picl/v1/account/keys" dataUsingEncoding: NSASCIIStringEncoding] length:3*32];
        NSData *respHMACKey = [t subdataWithRange: NSMakeRange(0, 32)];
        NSData *respXORKey = [t subdataWithRange: NSMakeRange(32, 64)];

        //

        NSData *bundle = [[NSData alloc] initWithBase16EncodedString: [fetchKeysResponse objectForKey: @"bundle"] options: NSDataBase16DecodingOptionsDefault];

        NSData *ct = [bundle subdataWithRange: NSMakeRange(0, 64)];
        NSData *respMAC = [bundle subdataWithRange: NSMakeRange(64, 32)];
        NSData *respMAC2 = [ct HMACSHA256WithKey: respHMACKey];
        
        if ([respMAC2 isEqualToData: respMAC] == NO) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, [NSError errorWithDomain: @"" code: -123 userInfo: nil]);
            //});
            return;
        }

        //

        t = [ct exclusiveOrWithKey: respXORKey];
        NSData *kA = [t subdataWithRange: NSMakeRange(0, 32)];
        NSData *wrapKB = [t subdataWithRange: NSMakeRange(32, 32)];
        NSData *kB = [credentials.unwrapBKey exclusiveOrWithKey: wrapKB];

        FXAKeysData *keysData = [FXAKeysData new];
        keysData.a = kA;
        keysData.b = kB;
        
        completionHandler(keysData, nil);
    }];
    
    [task resume];
}

- (void) signCertificateWithKeyPair: (RSAKeyPair*) keyPair duration: (NSUInteger) duration sessionToken: (NSData*) sessionToken completionHandler: (FXAClientSignCertificateCompletionHandler) completionHandler
{
    NSData *t = [sessionToken deriveHKDFSHA256KeyWithSalt: nil contextInfo: [@"identity.mozilla.com/picl/v1/sessionToken" dataUsingEncoding: NSASCIIStringEncoding] length: 3*32];
    NSData *tokenId = [t subdataWithRange: NSMakeRange(0, 32)];
    NSData *reqHMACkey = [t subdataWithRange: NSMakeRange(32, 32)];
    //NSData *requestKey = [t subdataWithRange: NSMakeRange(64, 32)];
    
    HawkCredentials *credentials = [[HawkCredentials alloc] initWithKeyIdentifier: [tokenId base16EncodedStringWithOptions:NSDataBase16EncodingOptionsDefault] key: reqHMACkey];

    NSDictionary *object = @{
        @"publicKey": [keyPair.publicKey JSONRepresentation],
        @"duration": [NSNumber numberWithUnsignedInteger: duration]
    };
    
    NSURLRequest *request = [self requestWithURL: [NSURL URLWithString: @"/v1/certificate/sign" relativeToURL: _endpoint] method: @"POST" hawkCredentials: credentials object: object];

    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            //});
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, serializationError);
                //});
                return;
            }
            
            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                //dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, validationError);
                //});
                return;
            }
        
            completionHandler(nil, [FXAUtils errorFromErrorResponse: errorResponse]);
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *signCertificateResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, serializationError);
            //});
            return;
        }
        
        NSError *validationError = nil;
        if (![FXAUtils validateSignCertificateResponse: signCertificateResponse error: &validationError]) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, validationError);
            //});
            return;
        }

        FXACertificate *certificate = [[FXACertificate alloc] initWithCertificate: [signCertificateResponse objectForKey: @"cert"]];
        completionHandler(certificate, nil);
    }];
    [task resume];
}

@end
