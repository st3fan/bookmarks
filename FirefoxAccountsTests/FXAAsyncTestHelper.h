// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import <Foundation/Foundation.h>

@interface FXAAsyncTestHelper : NSObject
@property (strong,atomic) NSError *error;
@property (strong,atomic) id result;
@property (atomic) BOOL timedOut;
- (void) finishWithError: (NSError*) error;
- (void) finishWithResult: (id) result;
- (void) waitForTimeout: (NSTimeInterval) timeInterval;
@end
