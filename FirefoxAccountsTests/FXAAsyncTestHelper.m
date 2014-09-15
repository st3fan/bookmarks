// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "FXAAsyncTestHelper.h"

@implementation FXAAsyncTestHelper

- (void) finishWithError: (NSError*) error
{
    @synchronized (self) {
        self.error = error;
    }
}

- (void) finishWithResult: (id) result
{
    @synchronized (self) {
        self.result = result;
    }
}

- (void) waitForTimeout: (NSTimeInterval) timeInterval
{
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow: timeInterval];
    
    NSDate *dt = [NSDate dateWithTimeIntervalSinceNow: 0.1];
    while (true) {
        BOOL ok = YES;
        @synchronized (self) {
            ok = self.error == nil && self.result == nil && [loopUntil timeIntervalSinceNow] > 0;
        }
        if (!ok) {
            break;
        }
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: dt];
        dt = [NSDate dateWithTimeIntervalSinceNow: 0.1];
    }
    
    self.timedOut = ([loopUntil timeIntervalSinceNow] <= 0);
}

@end
