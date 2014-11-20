//
//  UXMapsActivity.m
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
#import "UXMapsActivity.h"

@implementation UXMapsActivity

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize zoomLevel = _zoomLevel;

- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"Open in Maps", @"");
}

- (UIImage *)activityImage {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UXKit.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:@"Map" ofType:@"png"]];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	if (self.latitude && self.longitude) {
        return YES;
    } else {
        return NO;
    }
}

- (void)performActivity {
    NSString *urlString = [NSMutableString stringWithFormat:@"http://maps.apple.com/maps?ll=%@,%@", self.latitude, self.longitude];
	NSURL *url = [NSURL URLWithString:urlString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        [self activityDidFinish:YES];
    } else {
        [self activityDidFinish:NO];
    }
}

@end
