// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "CHMath.h"
#import "NSData+SHA.h"
#import "NSData+Utils.h"
#import "SRPClient.h"

@implementation SRPClient {
    NSData *_username;
    NSData *_password;
    NSData *_salt;
    
    CHNumber *_a;
    CHNumber *_N;
    CHNumber *_g;
    CHNumber *_A;
    
    CHNumber *_B;
    CHNumber *_u;
    CHNumber *_x;
    CHNumber *_v;
    CHNumber *_k;
    CHNumber *_S;
    
    NSData *_K;
    NSData *_M1;
    NSData *_M2;
}

- (id) initWithUsername: (NSData*) username password: (NSData*) password salt: (NSData*) salt
{
    if ((self = [super init]) != nil) {
        _username = username;
        _password = password;
        _salt = salt;
    }
    return self;
}

- (NSData*) oneWithA: (NSData*) a
{
    if (a != nil) {
        _a = [CHNumber numberWithData: a];
    } else {
        _a = [CHNumber numberWithData: [NSData randomDataWithLength: 32]]; // TODO: Why 32?
    }

    // n = AC6B...
    NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
    _N = [CHNumber numberWithHexString: Ns];
    
    // g = 2
    _g = [CHNumber numberWithInt: 2];
    
    // A = pow(g, self.a, N)
    _A = [_g numberByRaisingToPower: _a mod: _N];
    
    // return long_to_padded_bytes(A)
    return [[_A dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2];
}

- (NSData*) twoWithB: (NSData*) bd
{
    // assert self.A_bytes, "must call Client.one() before Client.two()"

    _B = [CHNumber numberWithData: bd];
    
    // if b % n == 0: raise ValueError("SRP-6a safety check failed: B is zero-ish")
    
    // u = number(sha256(A_bytes+B_bytes))
    NSData *ud = [[NSData dataByAppendingDatas: @[[_A dataValue], [_B dataValue]]] SHA256Hash];
    _u = [CHNumber numberWithData: ud];
    
    // if u == 0: raise ValueError("SRP-6a safety check failed: u is zero")
    
    // x = number(gen_x_bytes(salt, usernameUTF8, passwordUTF8))
    NSData *inner = [[NSData dataByAppendingDatas: @[_username, [@":" dataUsingEncoding: NSUTF8StringEncoding], _password]] SHA256Hash];
    NSData *xd = [[NSData dataByAppendingDatas: @[_salt, inner]] SHA256Hash];
    _x = [CHNumber numberWithData: xd];
    
    // v = pow(g, x, N)
    _v = [_g numberByRaisingToPower: _x mod: _N];

    NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";

    // k = sha256(long_to_padded_bytes(N)+long_to_padded_bytes(g)).digest()
    NSData *kd = [[NSData dataByAppendingDatas: @[[[_N dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2], [[_g dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2]]] SHA256Hash];
    _k = [CHNumber numberWithData: kd];

    // S = pow((B - k*v) % N,   (self.a + u*x),   N)
    CHNumber *t = [_B numberBySubtracting: [_k numberByMultiplyingBy: _v] mod: _N];
    _S = [t numberByRaisingToPower: [_a numberByAdding: [_u numberByMultiplyingBy: _x]] mod: _N];
    
    // K = sha256(S_bytes).digest()
    _K = [[_S dataValue] SHA256Hash];
    
    // M1_bytes = sha256(self.A_bytes + B_bytes + S_bytes).digest()
    _M1 = [[NSData dataByAppendingDatas: @[[_A dataValue], [_B dataValue], [_S dataValue]]] SHA256Hash];
    
    // (expected) M2 = sha256(self.A_bytes + M1_bytes + S_bytes).digest()
    _M2 = [[NSData dataByAppendingDatas: @[[_A dataValue], _M1, [_S dataValue]]] SHA256Hash];
    
    return _M1;
}

- (BOOL) threeWithM2: (NSData*) M2
{
    return [M2 isEqualToData: _M2];
}

- (NSData*) key
{
    return _K;
}

@end
