// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncRecord.h"
#import "SyncKeyBundle.h"
#import "SyncUtils.h"


@implementation SyncRecord

- (instancetype) initWithJSONRepresentation: (NSDictionary*) object
{
    if (object == nil || [object count] == 0) {
        return nil;
    }
    
    for (NSString *field in @[@"id", @"modified", @"payload"]) {
        if (object[field] == nil) {
            return nil;
        }
    }

    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: [object[@"payload"] dataUsingEncoding: NSUTF8StringEncoding] options: 0 error: NULL];
    if (payload == nil) {
        return nil;
    }
    
    if (payload[@"ciphertext"] != nil) {
        return nil;
    }
    
    if ((self = [super init]) != nil) {
        _identifier = object[@"id"];
        _modified = object[@"modified"];
        _payload = payload;
    }
    return self;
}

- (instancetype) initWithJSONRepresentation: (NSDictionary*) object keyBundle: (SyncKeyBundle*) keyBundle
{
    if (object == nil || [object count] == 0) {
        return nil;
    }
    
    for (NSString *field in @[@"id", @"modified", @"payload"]) {
        if (object[field] == nil) {
            return nil;
        }
    }

    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: [object[@"payload"] dataUsingEncoding: NSUTF8StringEncoding] options: 0 error: NULL];
    if (payload == nil) {
        return nil;
    }
    
    for (NSString *field in @[@"ciphertext", @"hmac", @"IV"]) {
        if (payload[field] == nil) {
            return nil;
        }
    }
    
    NSDictionary *decryptedPayload = [SyncUtils decryptPayload: payload withKeyBundle: keyBundle];
    if (decryptedPayload == nil) {
        return nil;
    }
    
    if ((self = [super init]) != nil) {
        _identifier = object[@"id"];
        _payload = decryptedPayload;
        _modified = object[@"modified"];
    }

    return self;
}

- (instancetype) initWithIdentifier: (NSString*) identifier modified: (double) modified payload: (NSDictionary*) payload
{
    if ((self = [super init]) != nil) {
        _identifier = [identifier copy];
        _modified = [NSNumber numberWithDouble: modified];
        _payload = [payload copy];
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat: @"<SyncRecord id=%@ modified=%@ payload=%@>", _identifier, _modified, _payload];
}

@end
