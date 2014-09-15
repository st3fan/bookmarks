// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@interface BIDVerifierReceipt : NSObject
- (instancetype) initWithJSONRepresentation: (NSDictionary*) object;
@property (readonly) NSString *status;
@property (readonly) NSString *reason;
@property (readonly) NSString *email;
@property (readonly) NSString *audience;
@property (readonly) NSNumber *expires;
@property (readonly) NSString *issuer;
@property (readonly) BOOL okay;
@end


typedef void (^BIDRemoteVerifierCompletionHandler)(BIDVerifierReceipt *verifierReceipt, NSError* error);


@interface BIDRemoteVerifier : NSObject
+ (instancetype) defaultRemoteVerifier;
- (instancetype) initWithEndpoint: (NSURL*) endpoint;
- (void) verifyAssertion: (NSString*) assertion audience: (NSString*) audience completionHandler: (BIDRemoteVerifierCompletionHandler) completionHandler;
@end
