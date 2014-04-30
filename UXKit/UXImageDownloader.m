//
//  UXImageDownloader.m
//  UXKit
//
//  Created by Conor Mulligan on 30/04/2014.
//  Copyright (c) 2014 Conor Mulligan. All rights reserved.
//

#import "UXImageDownloader.h"

@interface UXImageDownloader ()

@property (copy, nonatomic) UIImage * (^transform)(UIImage *);
@property (copy, nonatomic) void (^completion)(UIImage *);

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *data;

@end

@implementation UXImageDownloader

@synthesize url = _url;
@synthesize transform = _transform;
@synthesize completion = _completion;
@synthesize connection = _connection;
@synthesize data = _data;

#pragma mark - Disk image

- (void)loadImageAtURL:(NSURL *)url completion:(void (^)(UIImage *image))completion {
    [self loadImageAtURL:url transform:nil completion:completion];
}

- (void)loadImageAtURL:(NSURL *)url transform:(UIImage * (^)(UIImage *))transform completion:(void (^)(UIImage *))completion {
    _url = url;
    self.transform = transform;
    self.completion = completion;
    
    self.data = [[NSMutableData alloc] init];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:self.data];
    
    if (self.transform) {
        [self performSelectorInBackground:@selector(doTransform:) withObject:image];
    } else {
        [self doCompletion:image];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.completion(nil);
}

#pragma mark - Blocks

- (void)doTransform:(UIImage *)image {
    image = self.transform(image);
    [self performSelectorOnMainThread:@selector(doCompletion:) withObject:image waitUntilDone:YES];
}

- (void)doCompletion:(UIImage *)image {
    self.completion(image);
}

@end
