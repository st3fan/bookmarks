// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncKeyBundle.h"
#import "SyncCollectionKeys.h"


@implementation SyncCollectionKeys {
    SyncKeyBundle *_defaultKeyBundle;
    NSMutableDictionary *_keyBundlesByCollection;
}

- (instancetype) initWithJSONRepresentation: (NSDictionary*) object
{
    for (NSString *field in @[@"collection", @"id", @"collections", @"default"]) {
        if (object[field] == nil) {
            return nil;
        }
    }

    if ((self = [super init]) != nil)
    {
        NSData *defaultEncryptionKey = [[NSData alloc] initWithBase64EncodedString: object[@"default"][0] options:0];
        NSData *defaultValidationKey = [[NSData alloc] initWithBase64EncodedString: object[@"default"][1] options:0];
        _defaultKeyBundle = [[SyncKeyBundle alloc] initWithEncryptionKey: defaultEncryptionKey validationKey: defaultValidationKey];
        
        _keyBundlesByCollection = [NSMutableDictionary new];
        for (NSString *collectionName in object[@"collections"]) {
            NSData *encryptionKey = [[NSData alloc] initWithBase64EncodedString: object[@"collections"][collectionName][0] options:0];
            NSData *validationKey = [[NSData alloc] initWithBase64EncodedString: object[@"collections"][collectionName][1] options:0];
            _keyBundlesByCollection[collectionName] = [[SyncKeyBundle alloc] initWithEncryptionKey: encryptionKey validationKey: validationKey];
        }
    }
    
    return self;
}

- (SyncKeyBundle*) keyBundleForCollection: (NSString*) collectionName
{
    SyncKeyBundle *keyBundle = _keyBundlesByCollection[collectionName];
    if (keyBundle == nil) {
        keyBundle = _defaultKeyBundle;
    }
    return keyBundle;
}

@end
