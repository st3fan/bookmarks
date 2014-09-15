// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "BIDAssertion.h"

@interface BIDAssertion ()
@property NSString *assertion;
@end

@implementation BIDAssertion

- (id) initWithCertificate: (FXACertificate*) certificate privateKey: (FXAPrivateKey*) privateKey
{
    if ((self = [super init]) != nil)
    {
//        long expiresAt = issuedAt + durationInMilliseconds;
//        String emptyAssertionPayloadString = "{}";
//        String payloadString = getPayloadString(emptyAssertionPayloadString, issuer, issuedAt, audience, expiresAt);
//        String signature = JSONWebTokenUtils.encode(payloadString, privateKeyToSignWith);
//        return certificate + "~" + signature;

        
    }
    return self;
}

- (NSString*) stringValue
{
    return self.assertion;
}

@end
