// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncKeyBundle.h"
#import "SyncBasicAuthorizer.h"
#import "SyncBasicCredentials.h"


@implementation SyncBasicCredentials

- (instancetype) initWithUsername: (NSString*) username password: (NSString*) password recoveryKey: (NSString*) recoveryKey
{
    SyncAuthorizer *authorizer = [[SyncBasicAuthorizer alloc] initWithUsername: username password: password];
    SyncKeyBundle *globalKeyBundle = [[SyncKeyBundle alloc] initWithEncodedRecoveryKey: recoveryKey username: username];

    if ((self = [super initWithAuthorizer: authorizer globalKeyBundle: globalKeyBundle]) != nil) {
        _username = username;
        _password = password;
        _recoveryKey = recoveryKey;
    }
    return self;
}

@end
