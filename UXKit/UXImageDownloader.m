//
//  UXImageDownloader.m
//  UXKit
//
//  Copyright 2014 Conor Mulligan. All rights reserved.
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

#import "UXImageDownloader.h"

@interface UXImageDownloader ()

@property (copy, nonatomic) UIImage * (^transform)(UIImage *);
@property (copy, nonatomic) void (^completion)(UIImage *, BOOL);

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *data;

+ (NSCache *)imageCache;

@end

@implementation UXImageDownloader

@synthesize url = _url;
@synthesize transform = _transform;
@synthesize completion = _completion;
@synthesize connection = _connection;
@synthesize data = _data;

#pragma mark - Disk image

- (void)loadImageAtURL:(NSURL *)url completion:(void (^)(UIImage *image, BOOL cached))completion {
    [self loadImageAtURL:url transform:nil completion:completion];
}

- (void)loadImageAtURL:(NSURL *)url transform:(UIImage * (^)(UIImage *))transform completion:(void (^)(UIImage *image, BOOL cached))completion {
    _url = url;
    self.transform = transform;
    self.completion = completion;
    
    UIImage *image = [[UXImageDownloader imageCache] objectForKey:url];
    
    if (image) {
        if (self.transform) {
            image = self.transform(image);
        }
        if (self.completion) {
            self.completion(image, YES);
        }
    } else {
        self.data = [[NSMutableData alloc] init];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.connection start];
    }
}

#pragma mark - Cache

+ (NSCache *)imageCache {
    static NSCache *cache = nil;
    if (!cache) {
        cache = [[NSCache alloc] init];
    }
    return cache;
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:self.data];
    [[UXImageDownloader imageCache] setObject:image forKey:self.url];
    
    if (self.transform) {
        [self performSelectorInBackground:@selector(doTransform:) withObject:image];
    } else {
        [self doCompletion:image];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.completion(nil, NO);
}

#pragma mark - Blocks

- (void)doTransform:(UIImage *)image {
    image = self.transform(image);
    [self performSelectorOnMainThread:@selector(doCompletion:) withObject:image waitUntilDone:YES];
}

- (void)doCompletion:(UIImage *)image {
    self.completion(image, NO);
}

@end
