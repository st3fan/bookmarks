// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "FXAToken.h"
#import "FXAClient.h"

#import "SyncKeyBundle.h"
#import "SyncHawkAuthorizer.h"
#import "SyncHawkCredentials.h"


@implementation SyncHawkCredentials

- (instancetype) initWithToken: (FXAToken*) token key: (NSData*) key
{
    SyncAuthorizer *authorizer = [[SyncHawkAuthorizer alloc] initWithKeyIdentifier: token.identifier key: [token.key dataUsingEncoding: NSUTF8StringEncoding]];
    if (authorizer == nil) {
        return nil;
    }
    
    SyncKeyBundle *globalKeyBundle = [[SyncKeyBundle alloc] initWithKey: key];
    if (globalKeyBundle == nil) {
        return nil;
    }

    return [super initWithAuthorizer: authorizer globalKeyBundle: globalKeyBundle];
}

@end
