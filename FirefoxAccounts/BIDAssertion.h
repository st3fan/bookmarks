// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@class FXACertificate;
@class FXAPrivateKey;

@interface BIDAssertion : NSObject
- (id) initWithCertificate: (FXACertificate*) certificate privateKey: (FXAPrivateKey*) privateKey;
- (NSString*) stringValue;
@end
