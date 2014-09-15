// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncMetaGlobal.h"


// {
//    "username": "12410150",
//    "payload": "{
//        \"syncID\":\"fdJRVBcVCHh1\",
//        \"storageVersion\":5,
//        \"engines\":{
//            \"clients\":{\"version\":1,\"syncID\":\"ARV4P8Vb-_wQ\"},
//            \"bookmarks\":{\"version\":2,\"syncID\":\"qdA1iXgSXPgo\"},
//            \"forms\":{\"version\":1,\"syncID\":\"FccDJxey41C2\"},
//            \"history\":{\"version\":1,\"syncID\":\"pmh8oViljz8n\"},
//            \"passwords\":{\"version\":1,\"syncID\":\"nog7TsuxXXsz\"},
//            \"prefs\":{\"version\":2,\"syncID\":\"QtU7YyySM7cQ\"},
//            \"tabs\":{\"version\":1,\"syncID\":\"YthgvUxqTWNd\"},
//            \"addons\":{\"version\":1,\"syncID\":\"p3h5-W9-4wMK\"}
//         }
//    }",
//    "id": "global",
//    "modified": 1387311376.37
// }


@implementation SyncMetaGlobal {
    NSDictionary *_payload;
}

- (instancetype) initWithJSONRepresentation: (NSDictionary*) object
{
    if ((self = [super init]) != nil) {
        _payload = object;
    }
    return self;
}

- (NSDictionary*) metaGlobalForEngineWithName: (NSString*) engineName;
{
    return _payload[@"engines"][engineName];
}

@end
