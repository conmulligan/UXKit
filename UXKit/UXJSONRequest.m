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

@property (strong, nonatomic) NSMutableData *data;

- (NSString *)dictionaryAsParameterString:(NSDictionary *)dictionary;

- (void)loadJSON;
- (void)returnJSON;
- (void)returnError:(NSError *)error;

@end

@implementation UXJSONRequest

@synthesize connection = _connection;
@synthesize runLoop = _runLoop;
@synthesize baseURL = _baseURL;
@synthesize resource = _resource;
@synthesize method = _method;
@synthesize parameters = _parameters;
@synthesize encodeParametersAsJSON = _encodeParametersAsJSON;
@synthesize headerFields = _headerFields;
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
        self.method = @"GET";
        
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
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    request.timeoutInterval = 60;
    request.HTTPMethod = self.method;
    
    if (self.encodeParametersAsJSON) {
        NSError *error = NULL;
        NSData * data = [NSJSONSerialization dataWithJSONObject:self.parameters options:0 error:&error];
        
        if (!data) {
            NSLog(@"Error encoding JSON: %@", error);
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                [self.delegate request:self didFailWithError:error];
            }
        }
        
        [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:data];
        
        // Add custom header fields
        
        [self.headerFields enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL *stop) {
            [request addValue:value forHTTPHeaderField:key];
        }];
        
        request.URL = [NSURL URLWithString:[[NSArray arrayWithObjects:_baseURL, self.resource, nil] componentsJoinedByString:@"/"]];
    } else {
        NSString *parameters = [self dictionaryAsParameterString:self.parameters];
        
        if (parameters && ![parameters isEqualToString:@""]) {
            request.URL = [NSURL URLWithString:[[NSArray arrayWithObjects:_baseURL, self.resource, parameters, nil] componentsJoinedByString:@"/"]];
        } else {
            request.URL = [NSURL URLWithString:[[NSArray arrayWithObjects:_baseURL, self.resource, nil] componentsJoinedByString:@"/"]];
        }
    }
    
    NSLog(@"UXRESTRequest will load %@", request.URL);
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    if (self.runLoop) {
        [_connection scheduleInRunLoop:self.runLoop forMode:NSDefaultRunLoopMode];
    }
    
    [_connection start];
    
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
                                                                 persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    } else {
        [self returnError:[challenge error]];
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
    @autoreleasepool {
        NSError *error = NULL;
        
        _response = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
        if (error) {
            NSString *description = NSLocalizedString(@"The server returned an invalid response. Please try again later.", @"");
            
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: description,
                NSUnderlyingErrorKey: error
            };
            
            NSError *jsonError = [[NSError alloc] initWithDomain:@"UXJSONRequest" code:error.code userInfo:userInfo];
            
            [self performSelectorOnMainThread:@selector(returnError:) withObject:jsonError waitUntilDone:NO];
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