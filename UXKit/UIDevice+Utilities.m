//
//  UIDevice+Utilities.m
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

#import "UIDevice+Utilities.h"

@implementation UIDevice (Utilities)

+ (BOOL)isiPad {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
        return([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);	
	} else {
        return NO;
    }
}

+ (BOOL)versionIsEqualTo:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

+ (BOOL)versionIsGreaterThan:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

+ (BOOL)versionIsAtLeast:(NSString *)version {
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

@end