// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import <XCTest/XCTest.h>
#include "CHNumber.h"
#import "RSAKeyPair.h"
#import "DSAKeyPair.h"
#import "JSONWebTokenUtils.h"

@interface JSONWebTokenUtilsTest : XCTestCase

@end

@implementation JSONWebTokenUtilsTest

- (void) testEncodeRSA
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    NSString *payload = @"{\"breakfast\":[\"eggs\",\"bacon\"]}";

    NSString *token = [JSONWebTokenUtils encodePayloadString: payload withPrivateKeyToSign: keyPair.privateKey];
    XCTAssertNotNil(token);
    
    NSArray *components = [token componentsSeparatedByString: @"."];
    XCTAssertNotNil(components);
    XCTAssertTrue([components count] == 3);
    NSLog(@"%@", components);
}

- (void) testEncodeDSA
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 1024];
    NSString *payload = @"{\"breakfast\":[\"eggs\",\"bacon\"]}";

    NSString *token = [JSONWebTokenUtils encodePayloadString: payload withPrivateKeyToSign: keyPair.privateKey];
    XCTAssertNotNil(token);
    
    NSArray *components = [token componentsSeparatedByString: @"."];
    XCTAssertNotNil(components);
    XCTAssertTrue([components count] == 3);
    NSLog(@"%@", components);
}

- (void) testEncodeDecodeWithRSA
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    NSString *payload = @"{\"breakfast\":[\"eggs\",\"bacon\"]}";

    NSString *token = [JSONWebTokenUtils encodePayloadString: payload withPrivateKeyToSign: keyPair.privateKey];
    XCTAssertNotNil(token);
    
    NSString *decodedPayload = [JSONWebTokenUtils decodePayloadStringFromToken: token withPublicKeyToVerify: keyPair.publicKey];
    XCTAssertEqualObjects(payload, decodedPayload);
}

- (void) testEncodeDecodeWithDSA
{
    DSAKeyPair *keyPair = [DSAKeyPair generateKeyPairWithSize: 1024];
    NSString *payload = @"{\"breakfast\":[\"eggs\",\"bacon\"]}";

    NSString *token = [JSONWebTokenUtils encodePayloadString: payload withPrivateKeyToSign: keyPair.privateKey];
    XCTAssertNotNil(token);
    
    NSString *decodedPayload = [JSONWebTokenUtils decodePayloadStringFromToken: token withPublicKeyToVerify: keyPair.publicKey];
    XCTAssertEqualObjects(payload, decodedPayload);
}

- (void) testCertificatePayloadString
{
    RSAKeyPair *keyPair = [RSAKeyPair generateKeyPairWithModulusSize: 512];
    NSString *payload = [JSONWebTokenUtils certificatePayloadStringWithPublicKeyToSign: keyPair.publicKey email: @"test@example.com"];
    XCTAssertNotNil(payload);
}

- (void) testRSAGeneration
{
    CHNumber *n = [CHNumber numberWithString: @"15498874758090276039465094105837231567265546373975960480941122651107772824121527483107402353899846252489837024870191707394743196399582959425513904762996756672089693541009892030848825079649783086005554442490232900875792851786203948088457942416978976455297428077460890650409549242124655536986141363719589882160081480785048965686285142002320767066674879737238012064156675899512503143225481933864507793118457805792064445502834162315532113963746801770187685650408560424682654937744713813773896962263709692724630650952159596951348264005004375017610441835956073275708740239518011400991972811669493356682993446554779893834303"];
    CHNumber *e = [CHNumber numberWithString: @"65537"];
    CHNumber *d = [CHNumber numberWithString: @"6539906961872354450087244036236367269804254381890095841127085551577495913426869112377010004955160417265879626558436936025363204803913318582680951558904318308893730033158178650549970379367915856087364428530828396795995781364659413467784853435450762392157026962694408807947047846891301466649598749901605789115278274397848888140105306063608217776127549926721544215720872305194645129403056801987422794114703255989202755511523434098625000826968430077091984351410839837395828971692109391386427709263149504336916566097901771762648090880994773325283207496645630792248007805177873532441314470502254528486411726581424522838833"];
    RSAKeyPair *mockMyIdKeyPair = [[RSAKeyPair alloc] initWithModulus: n privateExponent:d publicExponent:e];
    
    n = [CHNumber numberWithString: @"20332459213245328760269530796942625317006933400814022542511832260333163206808672913301254872114045771215470352093046136365629411384688395020388553744886954869033696089099714200452682590914843971683468562019706059388121176435204818734091361033445697933682779095713376909412972373727850278295874361806633955236862180792787906413536305117030045164276955491725646610368132167655556353974515423042221261732084368978523747789654468953860772774078384556028728800902433401131226904244661160767916883680495122225202542023841606998867411022088440946301191503335932960267228470933599974787151449279465703844493353175088719018221"];
    e = [CHNumber numberWithString: @"65537"];
    d = [CHNumber numberWithString: @"9362542596354998418106014928820888151984912891492829581578681873633736656469965533631464203894863562319612803232737938923691416707617473868582415657005943574434271946791143554652502483003923911339605326222297167404896789026986450703532494518628015811567189641735787240372075015553947628033216297520493759267733018808392882741098489889488442349031883643894014316243251108104684754879103107764521172490019661792943030921873284592436328217485953770574054344056638447333651425231219150676837203185544359148474983670261712939626697233692596362322419559401320065488125670905499610998631622562652935873085671353890279911361"];
    RSAKeyPair *keyPair = [[RSAKeyPair alloc] initWithModulus: n privateExponent: d publicExponent: e];
    
    unsigned long long issuedAt = 1352995809210;
    unsigned long long duration  = 60 * 60 * 1000;
    unsigned long long expiresAt = issuedAt + duration;

    NSString *certificate = [JSONWebTokenUtils certificateWithPublicKeyToSign: keyPair.publicKey email: @"test@mockmyid.com" issuer: @"mockmyid.com" issuedAt: issuedAt expiresAt: expiresAt signingPrivateKey: mockMyIdKeyPair.privateKey];
    XCTAssertNotNil(certificate);
    
    NSString *assertion = [JSONWebTokenUtils createAssertionWithPrivateKeyToSignWith:keyPair.privateKey certificate:certificate audience: @"http://localhost:8080" issuer: @"127.0.0.1" issuedAt:issuedAt duration:duration];
    XCTAssertNotNil(assertion);

    NSString *payloadString = [JSONWebTokenUtils decodePayloadStringFromToken: certificate withPublicKeyToVerify: mockMyIdKeyPair.publicKey];
    XCTAssertNotNil(payloadString);

    // Verify payload string

    NSString *expectedPayloadString = @"{\"exp\":1352999409210,\"principal\":{\"email\":\"test@mockmyid.com\"},\"public-key\":{\"e\":\"65537\",\"n\":\"20332459213245328760269530796942625317006933400814022542511832260333163206808672913301254872114045771215470352093046136365629411384688395020388553744886954869033696089099714200452682590914843971683468562019706059388121176435204818734091361033445697933682779095713376909412972373727850278295874361806633955236862180792787906413536305117030045164276955491725646610368132167655556353974515423042221261732084368978523747789654468953860772774078384556028728800902433401131226904244661160767916883680495122225202542023841606998867411022088440946301191503335932960267228470933599974787151449279465703844493353175088719018221\",\"algorithm\":\"RS\"},\"iss\":\"mockmyid.com\",\"iat\":1352995809210}";

    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData: [payloadString dataUsingEncoding: NSUTF8StringEncoding] options:0 error:NULL];
    XCTAssertNotNil(payload);

    NSDictionary *expectedPayload = [NSJSONSerialization JSONObjectWithData: [expectedPayloadString dataUsingEncoding: NSUTF8StringEncoding] options:0 error:NULL];
    XCTAssertNotNil(expectedPayload);
    
    XCTAssertEqualObjects([expectedPayload objectForKey: @"iss"], [payload objectForKey: @"iss"]);
    XCTAssertEqualObjects([expectedPayload objectForKey: @"principal"], [payload objectForKey: @"principal"]);
    XCTAssertEqualObjects([expectedPayload objectForKey: @"exp"], [payload objectForKey: @"exp"]);
    XCTAssertEqualObjects([[expectedPayload objectForKey: @"public-key"] objectForKey: @"n"], [[payload objectForKey: @"public-key"] objectForKey: @"n"]);
    XCTAssertEqualObjects([[expectedPayload objectForKey: @"public-key"] objectForKey: @"e"], [[payload objectForKey: @"public-key"] objectForKey: @"e"]);

// TODO: This fails because JSON dict ordering differences
//    NSString *expectedCertificate = @"eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjEzNTI5OTk0MDkyMTAsInByaW5jaXBhbCI6eyJlbWFpbCI6InRlc3RAbW9ja215aWQuY29tIn0sInB1YmxpYy1rZXkiOnsiZSI6IjY1NTM3IiwibiI6IjIwMzMyNDU5MjEzMjQ1MzI4NzYwMjY5NTMwNzk2OTQyNjI1MzE3MDA2OTMzNDAwODE0MDIyNTQyNTExODMyMjYwMzMzMTYzMjA2ODA4NjcyOTEzMzAxMjU0ODcyMTE0MDQ1NzcxMjE1NDcwMzUyMDkzMDQ2MTM2MzY1NjI5NDExMzg0Njg4Mzk1MDIwMzg4NTUzNzQ0ODg2OTU0ODY5MDMzNjk2MDg5MDk5NzE0MjAwNDUyNjgyNTkwOTE0ODQzOTcxNjgzNDY4NTYyMDE5NzA2MDU5Mzg4MTIxMTc2NDM1MjA0ODE4NzM0MDkxMzYxMDMzNDQ1Njk3OTMzNjgyNzc5MDk1NzEzMzc2OTA5NDEyOTcyMzczNzI3ODUwMjc4Mjk1ODc0MzYxODA2NjMzOTU1MjM2ODYyMTgwNzkyNzg3OTA2NDEzNTM2MzA1MTE3MDMwMDQ1MTY0Mjc2OTU1NDkxNzI1NjQ2NjEwMzY4MTMyMTY3NjU1NTU2MzUzOTc0NTE1NDIzMDQyMjIxMjYxNzMyMDg0MzY4OTc4NTIzNzQ3Nzg5NjU0NDY4OTUzODYwNzcyNzc0MDc4Mzg0NTU2MDI4NzI4ODAwOTAyNDMzNDAxMTMxMjI2OTA0MjQ0NjYxMTYwNzY3OTE2ODgzNjgwNDk1MTIyMjI1MjAyNTQyMDIzODQxNjA2OTk4ODY3NDExMDIyMDg4NDQwOTQ2MzAxMTkxNTAzMzM1OTMyOTYwMjY3MjI4NDcwOTMzNTk5OTc0Nzg3MTUxNDQ5Mjc5NDY1NzAzODQ0NDkzMzUzMTc1MDg4NzE5MDE4MjIxIiwiYWxnb3JpdGhtIjoiUlMifSwiaXNzIjoibW9ja215aWQuY29tIiwiaWF0IjoxMzUyOTk1ODA5MjEwfQ.FVLlQXJrTjvjAeCbANHk42_W_WqCgODkPD5q_hMfSoSCEMR0ZhdZdn_wnUkYnV9i4oMTKSla4TXYmIXGjvyI1tpaEi7bVcGghr0d2BQ-OonQOrDKVmpnUXYPCjJATGMtJjo-tyObR-p-J7E1ov8i2ZPPjeYZidcCOuWh_kjsMwkUTKVVlAyYjSUaTINylJ258DXso4KO0QRGU9-PP7C1KI_uCX9088ZelL4w3SR1XuOZvHsvWz1aUP9xZDAEQWY1cCyRrUXgGg0-bfzFy2M5DDHXpUuNJf9ST2kZIJl1_MuEU0CIwGe7qSZabbofnzprtiiXF1hTGQU4jB3za8CaeA";
//    XCTAssertEqualObjects(expectedCertificate, certificate);
    

// TODO: This fails because JSON dict ordering differences
//    NSString *expectedAssertion = @"eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjEzNTI5OTk0MDkyMTAsInByaW5jaXBhbCI6eyJlbWFpbCI6InRlc3RAbW9ja215aWQuY29tIn0sInB1YmxpYy1rZXkiOnsiZSI6IjY1NTM3IiwibiI6IjIwMzMyNDU5MjEzMjQ1MzI4NzYwMjY5NTMwNzk2OTQyNjI1MzE3MDA2OTMzNDAwODE0MDIyNTQyNTExODMyMjYwMzMzMTYzMjA2ODA4NjcyOTEzMzAxMjU0ODcyMTE0MDQ1NzcxMjE1NDcwMzUyMDkzMDQ2MTM2MzY1NjI5NDExMzg0Njg4Mzk1MDIwMzg4NTUzNzQ0ODg2OTU0ODY5MDMzNjk2MDg5MDk5NzE0MjAwNDUyNjgyNTkwOTE0ODQzOTcxNjgzNDY4NTYyMDE5NzA2MDU5Mzg4MTIxMTc2NDM1MjA0ODE4NzM0MDkxMzYxMDMzNDQ1Njk3OTMzNjgyNzc5MDk1NzEzMzc2OTA5NDEyOTcyMzczNzI3ODUwMjc4Mjk1ODc0MzYxODA2NjMzOTU1MjM2ODYyMTgwNzkyNzg3OTA2NDEzNTM2MzA1MTE3MDMwMDQ1MTY0Mjc2OTU1NDkxNzI1NjQ2NjEwMzY4MTMyMTY3NjU1NTU2MzUzOTc0NTE1NDIzMDQyMjIxMjYxNzMyMDg0MzY4OTc4NTIzNzQ3Nzg5NjU0NDY4OTUzODYwNzcyNzc0MDc4Mzg0NTU2MDI4NzI4ODAwOTAyNDMzNDAxMTMxMjI2OTA0MjQ0NjYxMTYwNzY3OTE2ODgzNjgwNDk1MTIyMjI1MjAyNTQyMDIzODQxNjA2OTk4ODY3NDExMDIyMDg4NDQwOTQ2MzAxMTkxNTAzMzM1OTMyOTYwMjY3MjI4NDcwOTMzNTk5OTc0Nzg3MTUxNDQ5Mjc5NDY1NzAzODQ0NDkzMzUzMTc1MDg4NzE5MDE4MjIxIiwiYWxnb3JpdGhtIjoiUlMifSwiaXNzIjoibW9ja215aWQuY29tIiwiaWF0IjoxMzUyOTk1ODA5MjEwfQ.FVLlQXJrTjvjAeCbANHk42_W_WqCgODkPD5q_hMfSoSCEMR0ZhdZdn_wnUkYnV9i4oMTKSla4TXYmIXGjvyI1tpaEi7bVcGghr0d2BQ-OonQOrDKVmpnUXYPCjJATGMtJjo-tyObR-p-J7E1ov8i2ZPPjeYZidcCOuWh_kjsMwkUTKVVlAyYjSUaTINylJ258DXso4KO0QRGU9-PP7C1KI_uCX9088ZelL4w3SR1XuOZvHsvWz1aUP9xZDAEQWY1cCyRrUXgGg0-bfzFy2M5DDHXpUuNJf9ST2kZIJl1_MuEU0CIwGe7qSZabbofnzprtiiXF1hTGQU4jB3za8CaeA~eyJhbGciOiJSUzI1NiJ9.eyJleHAiOjEzNTI5OTk0MDkyMTAsImF1ZCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDgwIiwiaXNzIjoiMTI3LjAuMC4xIiwiaWF0IjoxMzUyOTk1ODA5MjEwfQ.QShvRa8iZfcuoApnOPZeJc_Mfv5W_ewV16XSrUuCxheMsC25G6ofvXA75wFVIqFuhi7zal_07MVR2aE2Da3BL8jknOOtHSWTKLNbzf1WPpLfVt7_xLEdKY7ZMGSlvB2WhQ5Cc1RxehKXOGmP25OuRBs5oimbpYMiGUFg4igbKSN1Y5AJLyVL_KKaHKfVlNlop8cWAqvvHUbkmYKxp9UFVmz-hCOmbgIlwxHpedBvrTeYzlAxraNngCgiGHIBMMoRpA7PZmw_pHJDJ7jnUA7sqyaxthU-_2FsQyv1y70wUH5pEfCfVGPbxIPW6ZXCPrRpbYYppUnWQkZKn-Dhv_P5wg";
//    XCTAssertEqualObjects(expectedAssertion, assertion);
}

@end
