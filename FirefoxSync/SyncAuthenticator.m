// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "FXAClient.h"
#import "FXACertificate.h"
#import "RSAKeyPair.h"
#import "JSONWebTokenUtils.h"
#import "FXAUtils.h"
#import "FXAToken.h"
#import "FXATokenClient.h"
#import "SyncHawkCredentials.h"

#import "FXAAuthenticator.h"
#import "SyncAuthenticator.h"


// TODO: Make this public
static NSString *SyncAuthenticatorDefaultIdentifier = @"Default";

// TODO: These should be parameters and the audience can be derived by parsing the endpoint
static NSString *kTokenServerProductionEndpoint = @"https://token.services.mozilla.com";
static NSString *kTokenServerProductionAudience = @"https://token.services.mozilla.com";

static NSString *kSyncApplicationName = @"sync";
static NSString *kSyncApplicationVersion = @"1.5";


@implementation SyncAuthenticator {
    NSString *_identifier;
}

+ (instancetype) defaultAuthenticator
{
    return [[self alloc] initWithIdentifier: SyncAuthenticatorDefaultIdentifier];
}

- (instancetype) initWithIdentifier: (NSString*) identifier
{
    if ((self = [super init]) != nil) {
        _identifier = identifier;
    }
    return self;
}

- (void) authenticateWithEmail: (NSString*) email password: (NSString*) password completion: (SyncAuthenticatorCompletion) authenticatorCompletionHandler
{
    FXAAuthenticator *accountAuthenticator = [[FXAAuthenticator alloc] initWithIdentifier: _identifier];
    [accountAuthenticator authenticateWithEmail: email password:password completion:^(RSAKeyPair *keyPair, FXAKeysData *keys, FXACertificate *certificate, NSError *error) {
        if (error != nil) {
            authenticatorCompletionHandler(nil, nil, error);
        } else {
            // Create an assertion
            unsigned long long issuedAt = ([[NSDate date] timeIntervalSince1970] * 1000) - (60 * 1000);
            unsigned long long duration = JSONWebTokenUtilsDefaultAssertionDuration;
            
            NSString *assertion = [JSONWebTokenUtils createAssertionWithPrivateKeyToSignWith: keyPair.privateKey
                certificate: certificate.certificate audience: kTokenServerProductionAudience issuer: JSONWebTokenUtilsDefaultAssertionIssuer
                    issuedAt: issuedAt duration: duration];

            // Convert the assertion to a token
            FXATokenClient *tokenClient = [[FXATokenClient new] initWithEndpoint: [NSURL URLWithString: kTokenServerProductionEndpoint]];
            NSString *clientState = [FXAUtils computeClientState: keys.b];
            
            [tokenClient getTokenForApplication: kSyncApplicationName version: kSyncApplicationVersion assertion: assertion clientState: clientState completionHandler:^(FXAToken *token, NSError *error) {
                if (error) {
                    authenticatorCompletionHandler(nil, nil, error);
                } else {
                    // TODO: Can the FXAToken be invalid? Anything in there that we need to check?
                    authenticatorCompletionHandler([NSURL URLWithString: token.endpoint], [[SyncHawkCredentials alloc] initWithToken: token key: keys.b], nil);
                }
            }];
        }
    }];
}

@end
