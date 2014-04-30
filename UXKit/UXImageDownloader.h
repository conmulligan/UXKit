//
//  UXImageDownloader.h
//  UXKit
//
//  Created by Conor Mulligan on 30/04/2014.
//  Copyright (c) 2014 Conor Mulligan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXImageDownloader : NSObject <NSURLConnectionDelegate>

@property (nonatomic, readonly) NSURL *url;

- (void)loadImageAtURL:(NSURL *)url completion:(void (^)(UIImage *image))completion;
- (void)loadImageAtURL:(NSURL *)url transform:(UIImage * (^)(UIImage *image))transform completion:(void (^)(UIImage *image))completion;

@end