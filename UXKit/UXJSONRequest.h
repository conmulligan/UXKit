//
//  UXJSONRequest.h
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

#import <Foundation/Foundation.h>

@class UXJSONRequest;

@protocol UXJSONRequestDelegate <NSObject>

@optional
- (void)requestDidFinishLoading:(UXJSONRequest *)request;
- (void)request:(UXJSONRequest *)request didFailWithError:(NSError *)error;

@end

@interface UXJSONRequest : NSObject

// Connection

@property (strong, nonatomic, readonly) NSURLConnection *connection;
@property (nonatomic, readonly, getter = isLoading) BOOL loading;

@property (strong, nonatomic) NSRunLoop *runLoop;

// Request configuration

@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *resource;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSDictionary *parameters;
@property (assign, nonatomic) BOOL encodeParametersAsJSON;
@property (strong, nonatomic) NSDictionary *headerFields;

// Basic authentication

@property (assign, nonatomic, getter = shouldUseBasicAuth) BOOL useBasicAuth;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

// Response

@property (strong, nonatomic, readonly) NSObject *response;

@property (assign, nonatomic) id<UXJSONRequestDelegate> delegate;

@property (copy, nonatomic) void (^completion)(NSObject *response);
@property (copy, nonatomic) void (^error)(NSError *error);

// Methods

- (id)initWithBaseURL:(NSString *)baseURL;

- (void)startLoading;
- (void)startLoadingResource:(NSString *)resource completion:(void (^)(NSObject *response))completion error:(void (^)(NSError *error))error;
- (void)stopLoading;

- (void)useBasicAuthWithUsername:(NSString *)username andPassword:(NSString *)password;

@end
