//
//  UXJSONRequest.m
//  UXKit
//
//  Copyright 2012 Conor Mulligan. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UXJSONRequest.h"

@interface UXJSONRequest ()

- (NSString *)dictionaryAsParameterString:(NSDictionary *)dictionary;

- (void)loadJSON;
- (void)returnJSON;
- (void)returnError:(NSError *)error;

@end

@implementation UXJSONRequest

@synthesize connection = _connection;
@synthesize baseURL = _baseURL;
@synthesize resource = _resource;
@synthesize parameters = _parameters;
@synthesize useBasicAuth = _useBasicAuth;
@synthesize username = _username;
@synthesize password = _password;
@synthesize response = _response;
@synthesize delegate = _delegate;
@synthesize loading = _loading;

#pragma mark - Initialization

- (id)init {
    return [self initWithBaseURL:@""];
}

- (id)initWithBaseURL:(NSString *)baseURL {
    if (self = [super init]) {
        self.baseURL = baseURL;
        self.resource = @"";
        
        _loading = NO;
    }
    return self;
}

#pragma mark - Utilities

- (NSString *)dictionaryAsParameterString:(NSDictionary *)dictionary {
    NSMutableString *parameters = [NSMutableString string];
    
    int i = 0;
    for (NSString *key in dictionary) {
        if (i > 0) {
            [parameters appendString:@"&"];
        } else {
            [parameters appendString:@"?"];
            i++;
        }
        
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [((NSString *)value) stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
        }
        
        [parameters appendFormat:@"%@=%@", key, value];
    }
    
    return parameters;
}

#pragma mark - Basic auth

- (void)useBasicAuthWithUsername:(NSString *)username andPassword:(NSString *)password {
    self.useBasicAuth = YES;
    self.username = username;
    self.password = password;
}

#pragma mark - Connection

- (void)openConnection {
    NSString *parameters = [self dictionaryAsParameterString:self.parameters];
    NSString *url = nil;
    if (parameters && ![parameters isEqualToString:@""]) {
        url = [[NSArray arrayWithObjects:_baseURL, self.resource, parameters, nil] componentsJoinedByString:@"/"];
    } else {
        url = [[NSArray arrayWithObjects:_baseURL, self.resource, nil] componentsJoinedByString:@"/"];
    }
    
    NSLog(@"UXRESTRequest will load %@", url);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (_connection) {
        _data = [[NSMutableData alloc] init];
        _loading = YES;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if (self.shouldUseBasicAuth && self.username && self.password && [challenge previousFailureCount] == 0) {
        NSLog(@"Received basic authentication challenge.");
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:self.username
                                                                    password:self.password
                                                                 persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        NSLog(@"Authentication failure.");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)connectionData {
    [_data appendData:connectionData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [NSThread detachNewThreadSelector:@selector(loadJSON) toTarget:self withObject:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self returnError:error];
}

- (void)startLoading {
    [self openConnection];
}

- (void)stopLoading {
    if (_connection != nil) {
        [_connection cancel];
    }
    _connection = nil;
}

- (void)reload {
    if (!self.isLoading) {
        [self clearData];
    }
    
    [self openConnection];
}

- (void)clearData {
    _data = nil;
}

#pragma mark - Parsing

- (void)loadJSON {
    NSString *string = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", string);
    
    @autoreleasepool {
        NSError *error = NULL;
        
        _response = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
        if (error) {
            [self performSelectorOnMainThread:@selector(returnError:) withObject:error waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(returnJSON) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)returnJSON {
    _loading = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
        [self.delegate requestDidFinishLoading:self];
    }
}

- (void)returnError:(NSError *)error {
    _loading = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.delegate request:self didFailWithError:error];
    }
}

#pragma mark - Memory management

- (void)dealloc {
    _delegate = nil;
    
    _data = nil;
    _response = nil;
    _resource = nil;
}

@end