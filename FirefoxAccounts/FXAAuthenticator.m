// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "RSAKeyPair.h"
#import "FXAClient.h"

#import "FXAAuthenticator.h"


// TODO: Make this configurable in the client?
static NSString *FXAAuthenticatorDefaultEndpoint = @"https://api.accounts.firefox.com/";
static NSString *FXAAuthenticatorDefaultIdentifier = @"Default";
static NSInteger FXAAuthenticatorDefaultRSAModulusSize = 512;


@implementation FXAAuthenticator {
    NSString *_identifier;
}

+ (instancetype) defaultAuthenticator
{
    return [[self alloc] initWithIdentifier: FXAAuthenticatorDefaultIdentifier];
}

- (instancetype) initWithIdentifier: (NSString*) identifier
{
    if ((self = [super init]) != nil) {
        _identifier = identifier;
    }
    return self;
}

- (void) authenticateWithEmail: (NSString*) email password: (NSString*) password completion: (FXAAuthenticatorCompletion) authenticatorCompletion
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: FXAAuthenticatorDefaultRSAModulusSize];
    FXACredentials *credentials = [[FXACredentials alloc] initWithEmail: email password: password];

    FXAClient *client = [[FXAClient alloc] initWithEndpoint: [NSURL URLWithString: FXAAuthenticatorDefaultEndpoint]];
    [client loginWithCredentials: credentials completionHandler:^(FXALoginResult *loginResult, NSError *error) {
        if (error) {
            authenticatorCompletion(nil, nil, nil, error);
        } else {
            [client fetchKeysWithKeyFetchToken: loginResult.keyFetchToken credentials: credentials completionHandler: ^(FXAKeysData *keysData, NSError *error) {
                if (error) {
                    authenticatorCompletion(nil, nil, nil, error);
                } else {
                    [client signCertificateWithKeyPair: keyPair duration: 86400 sessionToken: loginResult.sessionToken completionHandler: ^(FXACertificate *certificate, NSError *error) {
                        if (error) {
                            authenticatorCompletion(nil, nil, nil, error);
                        } else {
                            authenticatorCompletion(keyPair, keysData, certificate, nil);
                        }
                    }];
                }
            }];
        }
    }];
}

@end
