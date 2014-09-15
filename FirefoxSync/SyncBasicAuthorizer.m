// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncUtils.h"
#import "SyncBasicAuthorizer.h"


@implementation SyncBasicAuthorizer {
    NSString *_username;
    NSString *_password;
}

- (instancetype) initWithUsername: (NSString*) username password: (NSString*) password
{
    if ((self = [super init]) != nil) {
        _username = username;
        _password = password;
    }
    return self;
}

- (NSString*) authorizeSyncRequest: (NSURLRequest*) request
{
    NSString *credentials = [NSString stringWithFormat: @"%@:%@", [SyncUtils encodeUsername: _username], _password];
    NSString *encodedCredentials = [[credentials dataUsingEncoding: NSUTF8StringEncoding] base64EncodedStringWithOptions: 0];
    return [NSString stringWithFormat: @"Basic %@", encodedCredentials];
}

@end
