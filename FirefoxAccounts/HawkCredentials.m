// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "NSString+Utils.h"
#import "NSData+Utils.h"
#import "NSData+SHA.h"
#import "HawkCredentials.h"

@implementation HawkCredentials

- (id) initWithKeyIdentifier: (NSString*) keyIdentifier key: (NSData*) key
{
    if ((self = [super init]) != nil) {
        _keyIdentifier = keyIdentifier;
        _key = key;
    }
    return self;
}

// Authorization: Hawk id="dh37fgj492je", ts="1353832234", nonce="j4h3g2", hash="Yi9LfIIFRtBEPt74PVmbTF/xVAwPn7ub15ePICfgnuY=", ext="some-app-ext-data", mac="aSe1DERmZuRl3pI36/9BdZmnErTw3sNzOOAUlfeKjVw="


- (NSString*) authorizationHeaderForRequest: (NSURLRequest*) request ext: (NSString*) ext
{
    NSString *ts = [NSString stringWithFormat: @"%lu", (unsigned long) [[NSDate date] timeIntervalSince1970]];
    NSString *nonce = [NSString randomAlphanumericStringWithLength: 6];
    NSString *payloadHash = [[self class] payloadHashFromRequest: request];
    NSString *hash = [[self class] hashFromRequest: request withPayloadHash: payloadHash key: self.key timeStamp: ts nonce: nonce ext: nil];
    
    // TODO: This is stupid code
    
    if (payloadHash != nil) {
        if (ext != nil) {
            return [NSString stringWithFormat: @"Hawk id=\"%@\", ts=\"%@\", nonce=\"%@\", hash=\"%@\", ext=\"%@\", mac=\"%@\"",
                self.keyIdentifier, ts, nonce, payloadHash, ext, hash];
        } else {
            return [NSString stringWithFormat: @"Hawk id=\"%@\", ts=\"%@\", nonce=\"%@\", hash=\"%@\", mac=\"%@\"",
                self.keyIdentifier, ts, nonce, payloadHash, hash];
        }
    } else {
        if (ext != nil) {
            return [NSString stringWithFormat: @"Hawk id=\"%@\", ts=\"%@\", nonce=\"%@\", ext=\"%@\", mac=\"%@\"",
                self.keyIdentifier, ts, nonce, ext, hash];
        } else {
            return [NSString stringWithFormat: @"Hawk id=\"%@\", ts=\"%@\", nonce=\"%@\", mac=\"%@\"",
                self.keyIdentifier, ts, nonce, hash];
        }
    }
}

// These are public because it makes unit testing this code easier

//
// hawk.1.payload\n
// text/plain\n
// Thank you for flying Hawk\n
//

+ (NSString*) payloadHashFromRequest: (NSURLRequest*) request
{
    if ([request HTTPBody] == nil) {
        return nil;
    }

    // This is not terribly efficient because it copies the body. It would be nice to have a streaming hash implementation.

    NSData *hash = [[NSData dataByAppendingDatas: @[
        [@"hawk.1.payload\n" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", [request valueForHTTPHeaderField: @"Content-Type"]] dataUsingEncoding: NSUTF8StringEncoding],
        request.HTTPBody,
        [@"\n" dataUsingEncoding: NSUTF8StringEncoding]
    ]] SHA256Hash];
    
    return [hash base64EncodedStringWithOptions: 0];
}

//
// GET /resource/1?b=1&a=2 HTTP/1.1
// Host: example.com:8000
// Authorization: Hawk id="dh37fgj492je", ts="1353832234", nonce="j4h3g2", ext="some-app-ext-data", mac="6R4rV5iE+NPoym+WwjeHzjAGXUtLNIxmo1vpMofpLAE="
//
// hawk.1.header
// 1353832234
// j4h3g2
// GET
// /resource/1?b=1&a=2
// example.com
// 8000
//
// some-app-ext-data
//

+ (NSString*) hashFromRequest: (NSURLRequest*) request withPayloadHash: (NSString*) payloadHash key: (NSData*) key timeStamp: (NSString*) timestamp nonce: (NSString*) nonce ext: (NSString*) ext;
{
    if (ext == nil) {
        ext = @"";
    }

    if (payloadHash == nil) {
        payloadHash = @"";
    }
    
    NSMutableString *path = [NSMutableString stringWithString: @"/"];
    if ([[request URL] path] != nil) {
        [path setString: [[request URL] path]];
    }
    if ([[request URL] query] != nil) {
        [path appendString: @"?"];
        [path appendString: [[request URL] query]];
    }
    
    NSNumber *port = [[request URL] port];
    if (port == nil) {
        if ([[[request URL] scheme] isEqualToString: @"http"]) {
            port = [NSNumber numberWithInteger: 80];
        }
        if ([[[request URL] scheme] isEqualToString: @"https"]) {
            port = [NSNumber numberWithInteger: 443];
        }
    }

    NSData *hash = [[NSData dataByAppendingDatas: @[
        [@"hawk.1.header\n" dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", timestamp] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", nonce] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", [request HTTPMethod]] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", path] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", [[request URL] host]] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", port] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", payloadHash] dataUsingEncoding: NSUTF8StringEncoding],
        [[NSString stringWithFormat: @"%@\n", ext] dataUsingEncoding: NSUTF8StringEncoding]
    ]] HMACSHA256WithKey: key];
    
    return [hash base64EncodedStringWithOptions: 0];
}

@end
