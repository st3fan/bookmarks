// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "SyncRecord.h"
#import "SyncAuthorizer.h"
#import "SyncStorageClient.h"


@implementation SyncStorageClient {
    NSURL *_storageEndpoint;
    NSURLSession *_session;
    SyncAuthorizer* _authorizer;
}

/**
 * Initialize a new Sync Storage Client with the specified endpoint. The endpoint is what
 * the token server returns and includes the storage server host plus a partial path to
 * the user's resources. The authorizer is used to generate the Authorization header, which
 * can be either Basic Auth (old sync) or Hawk (new sync).
 */

- (instancetype) initWithStorageEndpoint: (NSURL*) storageEndpoint authorizer: (SyncAuthorizer*) authorizer
{
    if ((self = [super init]) != nil) {
        _storageEndpoint = storageEndpoint;
        _authorizer = authorizer;

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = @{@"User-Agent": @"Firefox/31.0 FxSync/1.33.0.20140716183446.desktop"};
        _session = [NSURLSession sessionWithConfiguration: sessionConfiguration];
    }
    return self;
}

#pragma mark -

/**
 * Load a record from the server. The record is specified with an identifier (id) and a collection name. The
 * record is returned as is. Its payload is not decrypted.
 */

- (void) loadRecordWithIdentifier: (NSString*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientLoadRecordCompletionHandler) completionHandler
{
    NSURL *url = [_storageEndpoint URLByAppendingPathComponent: [NSString stringWithFormat: @"/storage/%@/%@", collection, identifier]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler(nil, [NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *record = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            completionHandler(nil, serializationError);
            return;
        }
        
        completionHandler(record, nil);
    }];
    
    [task resume];
}

/**
 * Load multiple records from the server.
 */

- (void) loadRecordsFromCollection: (NSString*) collection completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler
{
    [self loadRecordsFromCollection:collection limit:0 completionHandler:completionHandler];
}

- (void) loadRecordsFromCollection: (NSString*) collection limit: (NSUInteger) limit completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/storage/%@?full=1&limit=%d", [_storageEndpoint absoluteString], collection, limit]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/newlines" forHTTPHeaderField:@"Accept"];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler(nil, [NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO
            return;
        }
        
        // The Storage Server does not return a 404 when the collection does not exist. It simply returns a 200 with
        // no content.
        
        NSMutableArray *records = [NSMutableArray new];
        
        if ([data length] != 0)
        {
            NSString *dataAsString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            __block NSError *serializationError = nil;

            [dataAsString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                serializationError = nil;
                NSDictionary *record = [NSJSONSerialization JSONObjectWithData: [line dataUsingEncoding: NSUTF8StringEncoding] options:0 error: &serializationError];
                if (serializationError != nil) {
                    *stop = YES;
                } else {
                    [records addObject: record];
                }
            }];
            
            if (serializationError != nil) {
                completionHandler(nil, serializationError);
            }
        }
        
        completionHandler([NSArray arrayWithArray: records], nil);
    }];
    
    [task resume];
}

/**
 * Load multiple records from the server.
 */

- (void) loadRecordsFromCollection: (NSString*) collection limit: (NSUInteger) limit newer: (NSNumber*) newer completionHandler: (SyncStorageClientLoadRecordsCompletionHandler) completionHandler
{
    NSString *url = [NSString stringWithFormat: @"%@/storage/%@?full=1&newer=%.2f", [_storageEndpoint absoluteString], collection, [newer floatValue]];
    if (limit != 0) {
        url = [url stringByAppendingFormat: @"&limit=%d", limit];
    }
    if (newer != 0) {
        url = [url stringByAppendingFormat: @"&newer=%.2f", newer];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]];
    [request addValue:@"application/newlines" forHTTPHeaderField:@"Accept"];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler(nil, [NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO
            return;
        }
        
        // The Storage Server does not return a 404 when the collection does not exist. It simply returns a 200 with
        // no content.
        
        NSMutableArray *records = [NSMutableArray new];
        
        if ([data length] != 0)
        {
            NSString *dataAsString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            __block NSError *serializationError = nil;

            [dataAsString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                serializationError = nil;
                NSDictionary *record = [NSJSONSerialization JSONObjectWithData: [line dataUsingEncoding: NSUTF8StringEncoding] options:0 error: &serializationError];
                if (serializationError != nil) {
                    *stop = YES;
                } else {
                    [records addObject: record];
                }
            }];
            
            if (serializationError != nil) {
                completionHandler(nil, serializationError);
            }
        }
        
        completionHandler([NSArray arrayWithArray: records], nil);
    }];
    
    [task resume];
}

#pragma mark -

- (void) storeRecord: (SyncRecord*) record inCollection: (NSString*) collection completionHandler: (SyncStorageClientStoreRecordCompletionHandler) completionHandler
{
    // Turn each record into an object. We assume the payload is a dictionary or array that needs JSON
    // serialization. I don't think there are any sync collections that use primitives.

    NSError *serializingError = nil;
    NSData *serializedPayload = [NSJSONSerialization dataWithJSONObject: record.payload options:0 error:&serializingError];
    if (serializingError != nil) {
        completionHandler(serializingError); // TODO: Need specialized errors
        return;
    }

    NSDictionary *object = @{
        @"id": record.identifier,
        @"ttl": [NSNumber numberWithInt: 86400], // TODO: This needs to come from the method arguments
        @"payload": [[NSString alloc] initWithData: serializedPayload encoding:NSUTF8StringEncoding]
    };

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject: object options:0 error: &error];
    if (body == nil) {
        completionHandler(error); // TODO: Need specialized errors
    }

    // PUT it to the server.
    // TODO: The server returns a lastmodified timestamp that we need to return to the completionHandler

    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/storage/%@/%@", [_storageEndpoint absoluteString], collection, record.identifier]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"PUT"];
    [request setHTTPBody: body];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(error); // TODO: Need specialized errors
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler([NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO: Need specialized errors
            return;
        }
        
        completionHandler(nil);
    }];
    
    [task resume];
}

- (void) storeRecords: (NSArray*) records inCollection: (NSString*) collection completionHandler: (SyncStorageClientStoreRecordsCompletionHandler) completionHandler
{
    // Turn each record into an object. We assume the payload is a dictionary or array that needs JSON
    // serialization. I don't think there are any sync collections that use primitives.

    NSMutableArray *objects = [NSMutableArray new];
    
    __block NSError *serializingError = nil;
    [records enumerateObjectsUsingBlock:^(SyncRecord *record, NSUInteger idx, BOOL *stop) {
        NSData *serializedPayload = [NSJSONSerialization dataWithJSONObject: record.payload options:0 error:&serializingError];
        if (serializingError != nil) {
            *stop = YES;
        } else {
            [objects addObject: @{
                @"id": record.identifier,
                @"ttl": [NSNumber numberWithInt: 86400], // TODO: This needs to come from the method arguments
                @"payload": [[NSString alloc] initWithData: serializedPayload encoding:NSUTF8StringEncoding]
            }];
        }
    }];

    if (serializingError != nil) {
        completionHandler(serializingError); // TODO: Need specialized errors
        return;
    }

    // Serialize the array of objects

    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject: objects options:0 error: &error];
    if (body == nil) {
        completionHandler(error); // TODO: Need specialized errors
        return;
    }

    // Finally POST it to the server.
    // TODO: The server will return a list of things that we do not process yet.

    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/storage/%@", [_storageEndpoint absoluteString], collection]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: body];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(error); // TODO: Need specialized errors
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler([NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO: Need specialized errors
            return;
        }
        
        completionHandler(nil);
    }];
    
    [task resume];
}

#pragma mark -

- (void) deleteCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteCollectionCompletionHandler) completionHandler
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/storage/%@", [_storageEndpoint absoluteString], collection]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: @"DELETE"];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        
        // We only fail if the response is not a 200 or 404
        if ([r statusCode] != 200 && [r statusCode] != 404) {
            completionHandler([NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO
            return;
        }
        
        completionHandler(nil);
    }];
    
    [task resume];
}

- (void) deleteRecordsWithIdentifiers: (NSArray*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteRecordsCompletionHandler) completionHandler
{
    // TODO: Implement
}

- (void) deleteRecordWithIdentifier: (NSString*) identifier fromCollection: (NSString*) collection completionHandler: (SyncStorageClientDeleteRecordCompletionHandler) completionHandler
{
    // TODO: Implement
}

#pragma mark -

/**
 * Load info/collections. Returns raw response as a dictionary.
 */

- (void) loadInfoCollectionsWithCompletionHandler: (SyncStorageClientLoadRecordCompletionHandler) completionHandler
{
    NSURL *url = [_storageEndpoint URLByAppendingPathComponent: @"/info/collections"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue: [_authorizer authorizeSyncRequest: request] forHTTPHeaderField: @"Authorization"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler(nil, [NSError errorWithDomain: @"" code: -1 userInfo: nil]); // TODO
            return;
        }
        
        NSError *serializationError = nil;
        NSDictionary *record = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            completionHandler(nil, serializationError);
            return;
        }
        
        completionHandler(record, nil);
    }];
    
    [task resume];
}

@end
