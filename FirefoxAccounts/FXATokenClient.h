// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <Foundation/Foundation.h>


@class FXAToken;


typedef void (^FXATokenClientGetTokenCompletionHandler)(FXAToken *token, NSError* error);


@interface FXATokenClient : NSObject

+ (instancetype) defaultTokenClient;

- (id) initWithEndpoint: (NSURL*) endpoint;
- (void) getTokenForApplication: (NSString*) application version: (NSString*) version assertion: (NSString*) assertion clientState: (NSString*) clientState completionHandler: (FXATokenClientGetTokenCompletionHandler) completionHandler;

@end
