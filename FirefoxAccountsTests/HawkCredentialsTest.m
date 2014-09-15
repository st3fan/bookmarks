// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#import "NSData+Base16.h"
#import "HawkCredentials.h"

@interface HawkCredentialsTest : XCTestCase

@end

@implementation HawkCredentialsTest

- (void) testPayloadHashFromPOSTRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://url.does.not.matter/for-this-test"]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [@"Thank you for flying Hawk" dataUsingEncoding: NSUTF8StringEncoding]];
    [request addValue: @"text/plain" forHTTPHeaderField: @"Content-Type"];
    
    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    XCTAssertEqualObjects(payloadHash, @"Yi9LfIIFRtBEPt74PVmbTF/xVAwPn7ub15ePICfgnuY=");
}

- (void) testPayloadHashFromGETRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://url.does.not.matter/for-this-test"]];
    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    XCTAssertNil(payloadHash);
}

- (void) testHashFromGETRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://example.com:8000/resource/1?b=1&a=2"]];

    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    NSString *hash = [HawkCredentials hashFromRequest: request withPayloadHash: payloadHash key: [@"werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn" dataUsingEncoding: NSASCIIStringEncoding] timeStamp: @"1353832234" nonce: @"j4h3g2" ext: @"some-app-ext-data"];
    XCTAssertEqualObjects(hash, @"6R4rV5iE+NPoym+WwjeHzjAGXUtLNIxmo1vpMofpLAE=");
}

- (void) testHashFromGETRequest2
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://127.0.0.1:9000/v1/recovery_email/status"]];

    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    NSString *hash = [HawkCredentials hashFromRequest: request withPayloadHash: payloadHash key: [[NSData alloc] initWithBase16EncodedString: @"f04b833a032fef30737e4a8f459d2a0be94df5da7ffac9120ff05c5f1b590346" options: NSDataBase16DecodingOptionsDefault] timeStamp: @"1389236727" nonce: @"0wbIQk" ext: nil];
    XCTAssertEqualObjects(hash, @"Ajg80Rjm/fiM7Iqr2cUUQxlRgcr782dRaTA5hQ/+DB0=");
}

- (void) testHashFromPOSTRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"http://example.com:8000/resource/1?b=1&a=2"]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [@"Thank you for flying Hawk" dataUsingEncoding: NSUTF8StringEncoding]];
    [request addValue: @"text/plain" forHTTPHeaderField: @"Content-Type"];
    
    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    NSString *hash = [HawkCredentials hashFromRequest: request withPayloadHash: payloadHash key: [@"werxhqb98rpaxn39848xrunpaw3489ruxnpa98w4rxn" dataUsingEncoding: NSASCIIStringEncoding] timeStamp: @"1353832234" nonce: @"j4h3g2" ext: @"some-app-ext-data"];
    XCTAssertEqualObjects(hash, @"aSe1DERmZuRl3pI36/9BdZmnErTw3sNzOOAUlfeKjVw=");
}

- (void) testHashFromPOSTRequestWithoutPortNumber
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"https://fxa.sateh.com/v1/session/create"]];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [@"{}" dataUsingEncoding: NSUTF8StringEncoding]];
    [request addValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    
    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    XCTAssertEqualObjects(payloadHash, @"vNZvU+y3rJKqH4hu1yxrNuaijNPgIJ2Rgj/sHzsQhXY=");
    
    NSString *hash = [HawkCredentials hashFromRequest: request withPayloadHash: payloadHash key: [[NSData alloc] initWithBase16EncodedString: @"612e410a6144b21fedc32ad78d8b45a2e1900a0eaa2b3aea0adb712176998e00" options: NSDataBase16DecodingOptionsDefault] timeStamp: @"1386613993" nonce: @"WU8XG0" ext: @""];
    XCTAssertEqualObjects(hash, @"VoJhM+3SRqKcljfD1NbqsgbYLkPJDYfXXspXhgYl18c=");
}

- (void) testHashFromGETRequestWithoutPortNumber
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: @"https://fxa.sateh.com/v1/account/keys"]];
    NSString *payloadHash = [HawkCredentials payloadHashFromRequest: request];
    
    NSString *mac = [HawkCredentials hashFromRequest: request withPayloadHash: payloadHash key: [[NSData alloc] initWithBase16EncodedString: @"2314df5079cc2ece70fb2c7a2e22beffa894b83ee0c881c1dc0ea5343f4c6902" options: NSDataBase16DecodingOptionsDefault] timeStamp: @"1386632422" nonce: @"axArOA" ext: @""];
    XCTAssertEqualObjects(mac, @"bCErRbozBzrmnnpUjVazQOeOq5dgZ/MOA6IYhObTqWM=");
}

@end
