// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "FXACertificate.h"

@implementation FXACertificate

- (id) initWithCertificate: (NSString*) certificate
{
    if ((self = [super init]) != nil) {
        _certificate = certificate;
    }
    return self;
}

@end
