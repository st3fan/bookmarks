// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface HawkCredentials : NSObject

@property (nonatomic,copy) NSString *keyIdentifier;
@property (nonatomic,copy) NSData *key;

- (id) initWithKeyIdentifier: (NSString*) keyIdentifier key: (NSData*) key;
- (NSString*) authorizationHeaderForRequest: (NSURLRequest*) request ext: (NSString*) ext;

+ (NSString*) payloadHashFromRequest: (NSURLRequest*) request;
+ (NSString*) hashFromRequest: (NSURLRequest*) request withPayloadHash: (NSString*) payloadHash key: (NSData*) key timeStamp: (NSString*) timestamp nonce: (NSString*) nonce ext: (NSString*) ext;

@end
