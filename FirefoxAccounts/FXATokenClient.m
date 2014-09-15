// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/


#import "FXAToken.h"
#import "FXAUtils.h"
#import "FXATokenClient.h"


static NSString *FXATokenClientDefaultEndpoint = @"https://fxa-token-server.sateh.com";


@implementation FXATokenClient {
    NSURL *_endpoint;
    NSURLSession *_session;
}

+ (instancetype) defaultTokenClient
{
    return [[self alloc] initWithEndpoint: [NSURL URLWithString: FXATokenClientDefaultEndpoint]];
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

- (void) getTokenForApplication: (NSString*) application version: (NSString*) version assertion: (NSString*) assertion clientState: (NSString*) clientState completionHandler: (FXATokenClientGetTokenCompletionHandler) completionHandler
{
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/1.0/%@/%@", [_endpoint absoluteString], application, version]];
    NSString *s = [url absoluteString];
    NSLog(@"%@", s);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue: [NSString stringWithFormat: @"BrowserID %@", assertion] forHTTPHeaderField: @"Authorization"];
    [request addValue: clientState forHTTPHeaderField: @"X-Client-State"];
    
    NSURLSessionTask *task = [_session dataTaskWithRequest: request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
        if ([r statusCode] != 200)
        {
            NSError *serializationError = nil;
            NSDictionary *errorResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
            if (serializationError != nil) {
                completionHandler(nil, serializationError);
                return;
            }

            NSError *validationError = nil;
            if (![FXAUtils validateErrorResponse: errorResponse error: &validationError]) {
                completionHandler(nil, validationError);
                return;
            }
        
            completionHandler(nil, [NSError errorWithDomain: @"" code:-1 userInfo: errorResponse]);
            return;
        }

        NSError *serializationError = nil;
        NSDictionary *getTokenResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error: &serializationError];
        if (serializationError != nil) {
            //dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, serializationError);
            //});
            return;
        }

// TODO: Implement this
//        NSError *validationError = nil;
//        if (![FXAUtils validateStartAuthResponse: authStartResponse error: &validationError]) {
//            //dispatch_async(dispatch_get_main_queue(), ^{
//                completionHandler(nil, validationError);
//            //});
//            return;
//        }

        FXAToken *token = [[FXAToken alloc] initWithJSONObject: getTokenResponse];
        completionHandler(token, nil);
    }];
    
    [task resume];
}

@end
