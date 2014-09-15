// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>

#include <openssl/dsa.h>

#include "NSData+SHA.h"
#include "NSData+Utils.h"
#include "CHNumber.h"

#import "ASNUtils.h"
#import "DSAKeyPair.h"


@interface DSAKeyPairTest : XCTestCase

@end


@implementation DSAKeyPairTest

- (void)testGenerateKeyPair
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 512];
    XCTAssertNotNil(keyPair);

    DSAPublicKey *publicKey = keyPair.publicKey;
    XCTAssertNotNil(publicKey);

    DSAPrivateKey *privateKey = keyPair.privateKey;
    XCTAssertNotNil(privateKey);
}

- (void) testGenerateKeyPairWithBadModulusSize
{
    DSAKeyPair *keyPair;

    keyPair = [DSAKeyPair generateKeyPairWithSize: 0];
    XCTAssertNil(nil);

    keyPair = [DSAKeyPair generateKeyPairWithSize: 42];
    XCTAssertNil(nil);

    keyPair = [DSAKeyPair generateKeyPairWithSize: -3];
    XCTAssertNil(nil);
}

- (void) testBadSignature
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 512];
    XCTAssertNotNil(keyPair);

    NSData *badSignature = [NSData randomDataWithLength: 46];
    BOOL verified = [keyPair.publicKey verifySignature: badSignature againstMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertFalse(verified);
}

- (void) testSignAndVerifyString
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 512];
    XCTAssertNotNil(keyPair);
    
    NSData *signature = [keyPair.privateKey signMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertNotNil(signature);
    XCTAssertTrue([signature length] == 40);
    
    BOOL verified = [keyPair.publicKey verifySignature: signature againstMessageString: @"Hello, world!" encoding: NSUTF8StringEncoding];
    XCTAssertTrue(verified);
}

- (void) testSignAndVerifyData
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 512];
    XCTAssertNotNil(keyPair);
    
    NSData *signature = [keyPair.privateKey signMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertNotNil(signature);
    //XCTAssertTrue([signature length] == 40);

    BOOL verified = [keyPair.publicKey verifySignature: signature againstMessage: [@"Hello, world!" dataUsingEncoding: NSUTF8StringEncoding]];
    XCTAssertTrue(verified);
}

- (void) testJSONEncoding
{
    CHNumber *p = [CHNumber numberWithHexString: @"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17"];
    CHNumber *q = [CHNumber numberWithHexString: @"962eddcc369cba8ebb260ee6b6a126d9346e38c5"];
    CHNumber *g = [CHNumber numberWithHexString: @"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4"];

    CHNumber *x = [CHNumber numberWithHexString: @"9516d860392003db5a4f168444903265467614db"];
    CHNumber *y = [CHNumber numberWithHexString: @"455152a0e499f5c9d11f9f1868c8b868b1443ca853843226a5a9552dd909b4bdba879acc504acb690df0348d60e63ea37e8c7f075302e0df5bcdc76a383888a0"];
    
    DSAParameters *parameters = [DSAParameters new];
    parameters.p = p;
    parameters.q = q;
    parameters.g = g;
    
    DSAPrivateKey *privateKey = [[DSAPrivateKey alloc] initWithPrivateKey: x parameters: parameters];
    XCTAssertNotNil(privateKey);

    DSAPublicKey *publicKey = [[DSAPublicKey alloc] initWithPublicKey: y parameters: parameters];
    XCTAssertNotNil(publicKey);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithPublicKey: publicKey privateKey: privateKey];
    XCTAssertNotNil(keyPair);
    
    NSData *json = [@"{\"publicKey\":{\"g\":\"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4\",\"q\":\"962eddcc369cba8ebb260ee6b6a126d9346e38c5\",\"p\":\"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17\",\"y\":\"455152a0e499f5c9d11f9f1868c8b868b1443ca853843226a5a9552dd909b4bdba879acc504acb690df0348d60e63ea37e8c7f075302e0df5bcdc76a383888a0\",\"algorithm\":\"DS\"},\"privateKey\":{\"g\":\"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4\",\"q\":\"962eddcc369cba8ebb260ee6b6a126d9346e38c5\",\"p\":\"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17\",\"x\":\"9516d860392003db5a4f168444903265467614db\",\"algorithm\":\"DS\"}}" dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *o = [NSJSONSerialization JSONObjectWithData: json options: 0 error: NULL];
    XCTAssertNotNil(o);

    XCTAssertEqualObjects(o[@"privateKey"], [privateKey JSONRepresentation]);
    XCTAssertEqualObjects(o[@"publicKey"], [publicKey JSONRepresentation]);
}

- (void) testJSONDecoding
{
    CHNumber *p = [CHNumber numberWithHexString: @"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17"];
    CHNumber *q = [CHNumber numberWithHexString: @"962eddcc369cba8ebb260ee6b6a126d9346e38c5"];
    CHNumber *g = [CHNumber numberWithHexString: @"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4"];

    CHNumber *x = [CHNumber numberWithHexString: @"9516d860392003db5a4f168444903265467614db"];
    CHNumber *y = [CHNumber numberWithHexString: @"455152a0e499f5c9d11f9f1868c8b868b1443ca853843226a5a9552dd909b4bdba879acc504acb690df0348d60e63ea37e8c7f075302e0df5bcdc76a383888a0"];
    
    DSAParameters *parameters = [DSAParameters new];
    parameters.p = p;
    parameters.q = q;
    parameters.g = g;
    
    DSAPrivateKey *privateKey = [[DSAPrivateKey alloc] initWithPrivateKey: x parameters: parameters];
    XCTAssertNotNil(privateKey);

    DSAPublicKey *publicKey = [[DSAPublicKey alloc] initWithPublicKey: y parameters: parameters];
    XCTAssertNotNil(publicKey);
    
    KeyPair *keyPair = [[KeyPair alloc] initWithPublicKey: publicKey privateKey: privateKey];
    XCTAssertNotNil(keyPair);

    NSData *json = [@"{\"publicKey\":{\"g\":\"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4\",\"q\":\"962eddcc369cba8ebb260ee6b6a126d9346e38c5\",\"p\":\"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17\",\"y\":\"455152a0e499f5c9d11f9f1868c8b868b1443ca853843226a5a9552dd909b4bdba879acc504acb690df0348d60e63ea37e8c7f075302e0df5bcdc76a383888a0\",\"algorithm\":\"DS\"},\"privateKey\":{\"g\":\"678471b27a9cf44ee91a49c5147db1a9aaf244f05a434d6486931d2d14271b9e35030b71fd73da179069b32e2935630e1c2062354d0da20a6c416e50be794ca4\",\"q\":\"962eddcc369cba8ebb260ee6b6a126d9346e38c5\",\"p\":\"fca682ce8e12caba26efccf7110e526db078b05edecbcd1eb4a208f3ae1617ae01f35b91a47e6df63413c5e12ed0899bcd132acd50d99151bdc43ee737592e17\",\"x\":\"9516d860392003db5a4f168444903265467614db\",\"algorithm\":\"DS\"}}" dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *o = [NSJSONSerialization JSONObjectWithData: json options: 0 error: NULL];
    XCTAssertNotNil(o);

    XCTAssertEqualObjects([keyPair.publicKey JSONRepresentation],
        [[[DSAPublicKey alloc] initWithJSONRepresentation: o[@"publicKey"]] JSONRepresentation]);
    XCTAssertEqualObjects([keyPair.privateKey JSONRepresentation],
        [[[DSAPrivateKey alloc] initWithJSONRepresentation: o[@"privateKey"]] JSONRepresentation]);
}

- (void) testJSONRepresentationRoundTrip
{
    DSAKeyPair *keyPair1 = [DSAKeyPair generateKeyPairWithSize: 512];
    XCTAssertNotNil(keyPair1);

    NSDictionary *o1 = [keyPair1 JSONRepresentation];
    XCTAssertNotNil(o1);
    
    DSAKeyPair *keyPair2 = [[DSAKeyPair alloc] initWithJSONRepresentation: o1];
    XCTAssertNotNil(keyPair2);

    NSDictionary *o2 = [keyPair1 JSONRepresentation];
    XCTAssertNotNil(o2);
    
    XCTAssertEqualObjects(o1, o2);
}

@end
