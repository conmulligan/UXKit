//
//  UXStackController.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UXMenuSegue.h"

@class UXStackController;

@protocol UXStackControllerDelegate <NSObject>

- (void)stackController:(UXStackController *)stackController didPerformSegue:(UXMenuSegue *)segue;

@end

@interface UXStackController : UIViewController

@property (weak, nonatomic) id<UXStackControllerDelegate> delegate;

@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) CGFloat visibleWidth;
@property (strong, nonatomic) UIImage *menuItemImage;

@property (strong, nonatomic) UIViewController *backgroundViewController;
@property (strong, nonatomic) UIViewController *foregroundViewController;

@property (assign, nonatomic) UIInterfaceOrientationMask supportedOrientations;

- (void)showBackgroundViewController;
- (void)showForegroundViewController;

- (id)initWithBackgroundViewController:(UIViewController *)background foregroundViewController:(UIViewController *)foreground;

@end
