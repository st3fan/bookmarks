// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "HawkCredentials.h"
#import "SyncHawkAuthorizer.h"


@implementation SyncHawkAuthorizer {
    HawkCredentials *_hawkCredentials;
}

- (instancetype) initWithKeyIdentifier: (NSString*) keyIdentifier key: (NSData*) key
{
    if (keyIdentifier == nil || [keyIdentifier length] == 0 || key == nil || [key length] == 0) {
        return nil;
    }
    
    if ((self = [super init]) != nil) {
        _hawkCredentials = [[HawkCredentials alloc] initWithKeyIdentifier: keyIdentifier key: key];
    }
    return self;
}

- (NSString*) authorizeSyncRequest: (NSURLRequest*) request
{
    return [_hawkCredentials authorizationHeaderForRequest: request ext: nil];
}

@end
