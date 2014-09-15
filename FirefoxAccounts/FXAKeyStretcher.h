// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

typedef void (^FXAKeyStretcherCompletionHandler)(NSData *stretchedKey, NSError* error);

@interface FXAKeyStretcher : NSObject

- (id) initWithJSONParameters: (NSDictionary*) parameters;
- (void) stretchUsername: (NSString*) username password: (NSString*) password completionHandler: (FXAKeyStretcherCompletionHandler) completionHandler;

@end
