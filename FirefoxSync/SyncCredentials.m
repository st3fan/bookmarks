// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncCredentials.h"
#import "SyncAuthorizer.h"
#import "SyncKeyBundle.h"


@implementation SyncCredentials

- (id) initWithAuthorizer: (SyncAuthorizer*) authorizer globalKeyBundle: (SyncKeyBundle*) globalKeyBundle
{
    if ((self = [super init]) != nil) {
        _authorizer = authorizer;
        _globalKeyBundle = globalKeyBundle;
    }
    return self;
}

@end
