//
//  UXMapsActivity.m
//  UXKit
//
//  Created by Conor Mulligan on 23/09/2014.
//  Copyright (c) 2014 Conor Mulligan. All rights reserved.
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
	return [UIImage imageNamed:@"Map"];
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
