// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "BIDRemoteVerifier.h"


NSString * const BIDRemoteVerifierDefaultEndpoint = @"https://verifier.login.persona.org/verify";


@implementation BIDVerifierReceipt

- (instancetype) initWithJSONRepresentation: (NSDictionary*) object
{
    if ((self = [super init]) != nil) {
        _status = object[@"status"];
        _reason = object[@"reason"];
        _email = object[@"email"];
        _audience = object[@"audience"];
        _expires = object[@"expires"];
        _issuer = object[@"issuer"];
        _okay = [_status isEqualToString: @"okay"];
    }
    return self;
}

@end


@implementation BIDRemoteVerifier {
    NSURL *_endpoint;
    NSURLSession *_session;
}

+ (instancetype) defaultRemoteVerifier
{
    return [[self alloc] initWithEndpoint: [NSURL URLWithString: BIDRemoteVerifierDefaultEndpoint]];
}

- (id) initWithEndpoint: (NSURL*) endpoint
{
    if ((self = [super init]) != nil) {
        _endpoint = endpoint;

        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPAdditionalHeaders = @{@"User-Agent": @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:31.0) Gecko/20100101 Firefox/31.0"};
        _session = [NSURLSession sessionWithConfiguration: sessionConfiguration];
    }
    return self;
}

- (void) verifyAssertion: (NSString*) assertion audience: (NSString*) audience completionHandler: (BIDRemoteVerifierCompletionHandler) completionHandler
{
    NSString *bodyString = [NSString stringWithFormat: @"assertion=%@&audience=%@",
        [assertion stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
            [audience stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: _endpoint];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [bodyString dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
        }

        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200) {
            completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo: nil]);
            return;
        }

        NSError *serializationError = nil;
        NSDictionary *verifyResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            completionHandler(nil, serializationError);
            return;
        }

        BIDVerifierReceipt *receipt = [[BIDVerifierReceipt alloc] initWithJSONRepresentation: verifyResponse];
        if (receipt == nil) {
            completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo: nil]);
            return;
        }
        
        completionHandler(receipt, nil);
    }];
    
    [task resume];
}

@end
