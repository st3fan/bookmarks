// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@class SyncHawkCredentials;


typedef void (^SyncAuthenticatorCompletion)(NSURL *endpoint, SyncHawkCredentials *credentials, NSError* error);


@interface SyncAuthenticator : NSObject
+ (instancetype) defaultAuthenticator;
- (instancetype) initWithIdentifier: (NSString*) identifier;
- (void) authenticateWithEmail: (NSString*) email password: (NSString*) password completion: (SyncAuthenticatorCompletion) completion;
@end
