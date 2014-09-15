// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

#import "CHMath.h"
#import "NSData+Utils.h"
#import "NSData+SHA.h"
#import "SRPServer.h"

@implementation SRPServer {
    NSData *_username;
    NSData *_password;
    NSData *_verifier;

    CHNumber *_v;
    CHNumber *_N;
    CHNumber *_g;
    CHNumber *_k;
    CHNumber *_b;
    CHNumber *_B;
    
    CHNumber *_A;
    CHNumber *_u;
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
        _v = [[CHNumber alloc] initWithData: [[self class] verifierValueForUsername: username password: password salt: salt]];
    }
    return self;
}

- (NSData*) one
{
    _b = [CHNumber numberWithData: [NSData randomDataWithLength: 32]]; // TODO: Why 32?
    
    // n = AC6B...
    NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
    _N = [CHNumber numberWithHexString: Ns];

    // g = 2
    _g = [CHNumber numberWithInt: 2];

    // k = sha256(long_to_padded_bytes(N)+long_to_padded_bytes(g)).digest()
    NSData *kd = [[NSData dataByAppendingDatas: @[[[_N dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2], [[_g dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2]]] SHA256Hash];
    _k = [CHNumber numberWithData: kd];

    // B = (k*v + pow(g, b, N)) % N
    _B = [[[_k numberByMultiplyingBy: _v] numberByAdding: [_g numberByRaisingToPower: _b mod: _N]] numberByModding: _N];
    
    return [[_B dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2];
}

- (NSData*) twoWithA: (NSData*) A M1: (NSData*) M1
{
    _A = [CHNumber numberWithData: A];
    // TODO: if A % N == 0: raise ValueError("SRP-6a safety check failed: A is zero-ish")

    NSData *ud = [[NSData dataByAppendingDatas: @[[_A dataValue], [_B dataValue]]] SHA256Hash];
    _u = [CHNumber numberWithData: ud];
    // TODO: if u == 0: raise ValueError("SRP-6a safety check failed: u is zero")
    
    // S = pow((A * pow(self.v, u, N)) % N, self.b, N)
    CHNumber *t = [_A numberByMultiplyingBy: [_v numberByRaisingToPower: _u mod: _N] mod: _N];
    _S = [t numberByRaisingToPower: _b mod: _N];

    // S_bytes = long_to_padded_bytes(S)
    NSString *Ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
    NSData *Sd = [[_S dataValue] dataLeftZeroPaddedToLength: [Ns length] / 2];
    
    // (Expected) M1 = sha256(A_bytes + self.B_bytes + S_bytes).digest()
    _M1 = [[NSData dataByAppendingDatas: @[[_A dataValue], [_B dataValue], [_S dataValue]]] SHA256Hash];

    // TODO: if M1_bytes != expected_M1_bytes: raise ValueError("SRP error: received M1 does not match, client does not know password")
    if ([M1 isEqualToData: _M1] == NO) {
        return nil;
    }
    
    // self.K = sha256(S_bytes).digest()
    _K = [Sd SHA256Hash];
    
    // M2 = sha256(A_bytes + M1_bytes + S_bytes)
    _M2 = [[NSData dataByAppendingDatas: @[[_A dataValue], _M1, Sd]] SHA256Hash];

    return _M2;
}

- (NSData*) key
{
    return _K;
}

#pragma mark - Verifier Methods

+ (NSData*) verifierValueForData: (NSData*) data salt: (NSData*) salt
{
    if (salt == nil) {
        salt = [NSData randomDataWithLength: 4];
    }

    // n = AC6BD...
    NSString *ns = @"AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73";
    CHNumber *n = [CHNumber numberWithHexString: ns];
    
    // x = SHA256(salt + SHA256(data))
    NSData *xd = [[NSData dataByAppendingDatas: @[salt, [data SHA256Hash]]] SHA256Hash];
    CHNumber *x = [CHNumber numberWithData: xd];

    // v = g^x % n
    CHNumber *g = [CHNumber numberWithInt: 2];
    CHNumber *v = [g numberByRaisingToPower: x mod: n];
    
    return [[v dataValue] dataLeftZeroPaddedToLength: [ns length] / 2];
}

+ (NSData*) verifierValueForUsername: (NSData*) username password: (NSData*) password salt: (NSData*) salt
{
    NSData *data = [NSData dataByAppendingDatas: @[username, [@":" dataUsingEncoding: NSUTF8StringEncoding], password]];
    return [self verifierValueForData: data salt: salt];
}

@end
