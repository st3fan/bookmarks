// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#include "NSData+Utils.h"
#include "CHNumber.h"
#import "RSAKeyPair.h"


@interface RSAKeyPairTest : XCTestCase

@end


@implementation RSAKeyPairTest

- (void)testGenerateKeyPair
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);

    RSAPublicKey *publicKey = keyPair.publicKey;
    XCTAssertNotNil(publicKey);

    RSAPrivateKey *privateKey = keyPair.privateKey;
    XCTAssertNotNil(privateKey);
}

- (void) testGenerateKeyPairWithBadModulusSize
{
    RSAKeyPair *keyPair;

    keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 0];
    XCTAssertNil(nil);

    keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 42];
    XCTAssertNil(nil);

    keyPair = [RSAKeyPair generateKeyPairWithModulusSize: -3];
    XCTAssertNil(nil);
}

- (void) testBadSignature
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);

    NSData *badSignature = [NSData randomDataWithLength: 64];
    BOOL verified = [keyPair.publicKey verifySignature: badSignature againstMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertFalse(verified);
}

- (void) testSignString
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);
    
    NSData *signature = [keyPair.privateKey signMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertNotNil(signature);
    XCTAssertTrue([signature length] == 64);
    
    BOOL verified = [keyPair.publicKey verifySignature: signature againstMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertTrue(verified);
}

- (void) testSignData
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair);
    
    NSData *signature = [keyPair.privateKey signMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertNotNil(signature);
    XCTAssertTrue([signature length] == 64);

    BOOL verified = [keyPair.publicKey verifySignature: signature againstMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertTrue(verified);
}

- (void) testCreateRSAKeyPair
{
    CHNumber *n = [CHNumber numberWithString: @"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577"];
    CHNumber *e = [CHNumber numberWithString: @"65537"];
    CHNumber *d = [CHNumber numberWithString: @"2050102629239206449128199335463237235732683202345308155771672920433658970744825199440426256856862541525088288448769859770132714705204296375901885294992205"];
    
    RSAPublicKey *publicKey = [[RSAPublicKey alloc] initWithModulus: n publicExponent: e];
    XCTAssertNotNil(publicKey);

    RSAPrivateKey *privateKey = [[RSAPrivateKey alloc] initWithModulus: n privateExponent: d];
    XCTAssertNotNil(privateKey);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithPublicKey: publicKey privateKey: privateKey];
    XCTAssertNotNil(keyPair);
    
    NSData *signature = [keyPair.privateKey signMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertNotNil(signature);
    XCTAssertTrue([signature length] == 64);

    BOOL verified = [keyPair.publicKey verifySignature: signature againstMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertTrue(verified);
}

- (void) testJSONEncoding
{
    CHNumber *n = [CHNumber numberWithString: @"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577"];
    CHNumber *e = [CHNumber numberWithString: @"65537"];
    CHNumber *d = [CHNumber numberWithString: @"2050102629239206449128199335463237235732683202345308155771672920433658970744825199440426256856862541525088288448769859770132714705204296375901885294992205"];
    
    RSAPublicKey *publicKey = [[RSAPublicKey alloc] initWithModulus: n publicExponent: e];
    XCTAssertNotNil(publicKey);

    RSAPrivateKey *privateKey = [[RSAPrivateKey alloc] initWithModulus: n privateExponent: d];
    XCTAssertNotNil(privateKey);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithPublicKey: publicKey privateKey: privateKey];
    XCTAssertNotNil(keyPair);
    
    NSData *json = [@"{\"publicKey\":{\"e\":\"65537\",\"n\":\"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577\",\"algorithm\":\"RS\"},\"privateKey\":{\"d\":\"2050102629239206449128199335463237235732683202345308155771672920433658970744825199440426256856862541525088288448769859770132714705204296375901885294992205\",\"n\":\"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577\",\"algorithm\":\"RS\"}}" dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *o = [NSJSONSerialization JSONObjectWithData: json options: 0 error: NULL];
    XCTAssertNotNil(o);

    XCTAssertEqualObjects(o[@"privateKey"], [privateKey JSONRepresentation]);
    XCTAssertEqualObjects(o[@"publicKey"], [publicKey JSONRepresentation]);
}

- (void) testJSONDecoding
{
    CHNumber *n = [CHNumber numberWithString: @"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577"];
    CHNumber *e = [CHNumber numberWithString: @"65537"];
    CHNumber *d = [CHNumber numberWithString: @"2050102629239206449128199335463237235732683202345308155771672920433658970744825199440426256856862541525088288448769859770132714705204296375901885294992205"];
    
    RSAPublicKey *publicKey = [[RSAPublicKey alloc] initWithModulus: n publicExponent: e];
    XCTAssertNotNil(publicKey);

    RSAPrivateKey *privateKey = [[RSAPrivateKey alloc] initWithModulus: n privateExponent: d];
    XCTAssertNotNil(privateKey);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithPublicKey: publicKey privateKey: privateKey];
    XCTAssertNotNil(keyPair);

    NSData *json = [@"{\"publicKey\":{\"e\":\"65537\",\"n\":\"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577\",\"algorithm\":\"RS\"},\"privateKey\":{\"d\":\"2050102629239206449128199335463237235732683202345308155771672920433658970744825199440426256856862541525088288448769859770132714705204296375901885294992205\",\"n\":\"7042170764319402120473546823641395184140303948430445023576085129538272863656735924617881022040465877164076593767104512065359975488480629290310209335113577\",\"algorithm\":\"RS\"}}" dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *o = [NSJSONSerialization JSONObjectWithData: json options: 0 error: NULL];
    XCTAssertNotNil(o);

    XCTAssertEqualObjects([keyPair.publicKey JSONRepresentation],
        [[[RSAPublicKey alloc] initWithJSONRepresentation: o[@"publicKey"]] JSONRepresentation]);
    XCTAssertEqualObjects([keyPair.privateKey JSONRepresentation],
        [[[RSAPrivateKey alloc] initWithJSONRepresentation: o[@"privateKey"]] JSONRepresentation]);
}

- (void) testRoundTrip
{
    RSAKeyPair *keyPair1 = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    XCTAssertNotNil(keyPair1);

    NSDictionary *o1 = [keyPair1 JSONRepresentation];
    XCTAssertNotNil(o1);
    
    RSAKeyPair *keyPair2 = [[RSAKeyPair alloc] initWithJSONRepresentation: o1];
    XCTAssertNotNil(keyPair2);

    NSDictionary *o2 = [keyPair1 JSONRepresentation];
    XCTAssertNotNil(o2);
    
    XCTAssertEqualObjects(o1, o2);
}

@end
