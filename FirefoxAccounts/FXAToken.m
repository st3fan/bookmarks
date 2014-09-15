// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "FXAToken.h"


@implementation FXAToken

- (id) initWithJSONObject: (NSDictionary*) object
{
    if ((self = [super init]) != nil) {
        _identifier = object[@"id"];
        _key = object[@"key"];
        _uid = object[@"uid"];
        _endpoint = object[@"api_endpoint"];
        _duration = [object[@"duration"] unsignedIntegerValue];
    }
    return self;
}

@end
