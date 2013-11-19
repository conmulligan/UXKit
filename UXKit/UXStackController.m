//
//  UXStackController.m
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

#import "UXStackController.h"

@interface UXStackController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation UXStackController

@synthesize animationDuration = _animationDuration;
@synthesize visibleWidth = _visibleWidth;
@synthesize backgroundViewController = _backgroundViewController;
@synthesize foregroundViewController = _foregroundViewController;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;

#pragma mark - Initialization

- (id)initWithBackgroundViewController:(UIViewController *)background foregroundViewController:(UIViewController *)foreground {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.animationDuration = 0.35f;
        self.visibleWidth = 10.f;
        
        self.backgroundViewController = background;
        self.foregroundViewController = foreground;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - Subview management

- (void)setForegroundViewController:(UIViewController *)foregroundViewController {
    if (self.foregroundViewController) {
        if (self.foregroundViewController) {
            [self.foregroundViewController.view removeGestureRecognizer:self.tapGestureRecognizer];
            self.tapGestureRecognizer = nil;
        }
        if (self.panGestureRecognizer) {
            [self.foregroundViewController.view removeGestureRecognizer:self.panGestureRecognizer];
            self.panGestureRecognizer = nil;
        }
        
        foregroundViewController.view.frame = self.foregroundViewController.view.frame;
        [_foregroundViewController removeFromParentViewController];
        [_foregroundViewController.view removeFromSuperview];
    }
    _foregroundViewController = foregroundViewController;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.foregroundViewController.view.bounds];
    self.foregroundViewController.view.layer.masksToBounds = NO;
    self.foregroundViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.foregroundViewController.view.layer.shadowOpacity = 1.f;
    self.foregroundViewController.view.layer.shadowOffset = CGSizeMake(0.f, 0.f);
    self.foregroundViewController.view.layer.shadowRadius = 7.f;
    self.foregroundViewController.view.layer.shadowPath = shadowPath.CGPath;
    
    [self addChildViewController:self.foregroundViewController];
    [self.view addSubview:self.foregroundViewController.view];
}

- (void)setBackgroundViewController:(UIViewController *)backgroundViewController {
    if (self.backgroundViewController) {
        [_backgroundViewController removeFromParentViewController];
        [_backgroundViewController.view removeFromSuperview];
    }
    _backgroundViewController = backgroundViewController;
    
    [self addChildViewController:self.backgroundViewController];
    [self.view addSubview:self.backgroundViewController.view];
    [self.view sendSubviewToBack:self.backgroundViewController.view];
}

- (void)showBackgroundViewController {
    [self.view addSubview:self.backgroundViewController.view];
    [self.view bringSubviewToFront:self.foregroundViewController.view];
    
    if (!self.tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showForegroundViewController)];
    }
    [self.foregroundViewController.view addGestureRecognizer:self.tapGestureRecognizer];
    
    if (!self.panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panForegroundViewController:)];
    }
    [self.panGestureRecognizer setMinimumNumberOfTouches:1];
    [self.panGestureRecognizer setMaximumNumberOfTouches:1];
    [self.foregroundViewController.view addGestureRecognizer:self.panGestureRecognizer];
    
    for (UIView *view in self.foregroundViewController.view.subviews) {
        view.userInteractionEnabled = NO;
    }
    
    CGRect f = self.backgroundViewController.view.frame;
    f.size.width = self.view.frame.size.width - self.visibleWidth;
    self.backgroundViewController.view.frame = f;
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGRect frame = self.foregroundViewController.view.frame;
        frame.origin.x = self.view.frame.size.width - self.visibleWidth;
        self.foregroundViewController.view.frame = frame;
    }];
}

- (void)panForegroundViewController:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    
    CGFloat left = self.view.frame.size.width - self.visibleWidth;
    CGFloat w = self.foregroundViewController.view.frame.size.width;
    CGFloat x = (w/2);
    
    if ((recognizer.view.center.x + translation.x - x) > left) {
        x = x + left;
    } else if ((recognizer.view.center.x + translation.x - x) > 0) {
        x = recognizer.view.center.x + translation.x;
    }
    
    recognizer.view.center = CGPointMake(x, recognizer.view.center.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.x < (left/2)) {
            [self showForegroundViewController];
        } else {
            [self showBackgroundViewController];
        }
    }
}

- (void)showForegroundViewController {
    for (UIView *view in self.foregroundViewController.view.subviews) {
        view.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGRect frame = self.foregroundViewController.view.frame;
        frame.origin.x = 0;
        self.foregroundViewController.view.frame = frame;
    } completion:^(BOOL finished) {
        if (self.tapGestureRecognizer) {
            [self.foregroundViewController.view removeGestureRecognizer:self.tapGestureRecognizer];
            self.tapGestureRecognizer = nil;
        }
        if (self.panGestureRecognizer) {
            [self.foregroundViewController.view removeGestureRecognizer:self.panGestureRecognizer];
            self.panGestureRecognizer = nil;
        }
        
        [self.backgroundViewController.view removeFromSuperview];
    }];
}

@end
