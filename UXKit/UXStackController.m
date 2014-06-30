//
//  UXStackController.m
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

#import "UXStackController.h"

static NSString *const UXSegueBackgroundID = @"background";
static NSString *const UXSegueForegroundID = @"foreground";

@interface UXStackController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *edgeGestureRecognizer;

@property (strong, nonatomic) UIBarButtonItem *menuBarButtonItem;

@end

@implementation UXStackController

@synthesize delegate = _delegate;
@synthesize animationDuration = _animationDuration;
@synthesize visibleWidth = _visibleWidth;
@synthesize backgroundViewController = _backgroundViewController;
@synthesize foregroundViewController = _foregroundViewController;
@synthesize supportedOrientations = _supportedOrientations;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize edgeGestureRecognizer = _edgeGestureRecognizer;
@synthesize menuBarButtonItem = _menuBarButtonItem;

#pragma mark - Initialization

- (void)commonInit {
    self.animationDuration = 0.35f;
    self.visibleWidth = 20.f;
    
    self.supportedOrientations = UIInterfaceOrientationMaskAll;
    
    self.menuBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(menuSelected:)];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithBackgroundViewController:(UIViewController *)background foregroundViewController:(UIViewController *)foreground {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self commonInit];
        
        self.backgroundViewController = background;
        self.foregroundViewController = foreground;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadStoryboardControllers];
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

#pragma mark - Actions

- (void)menuSelected:(id)sender {
    [self showBackgroundViewController];
}

#pragma mark - Segues

- (void)loadStoryboardControllers {
    if (self.storyboard && !self.backgroundViewController) {
        [self performSegueWithIdentifier:UXSegueBackgroundID sender:nil];
        [self performSegueWithIdentifier:UXSegueForegroundID sender:nil];
    }
}

- (void)prepareForSegue:(UXMenuSegue *)segue sender:(id)sender {
    NSString *identifier = segue.identifier;
    if ([segue isKindOfClass:[UXMenuSegue class]] && !sender) {
        if ([identifier isEqualToString:UXSegueBackgroundID]) {
            segue.performBlock = ^(UXMenuSegue *menuSegue, UIViewController *source, UIViewController *destination) {
                self.backgroundViewController = destination;
            };
        } else if ([identifier isEqualToString:UXSegueForegroundID]) {
            segue.performBlock = ^(UXMenuSegue *menuSegue, UIViewController *source, UIViewController *destination) {
                self.foregroundViewController = destination;
            };
        }
    }
    
    __strong id<UXStackControllerDelegate> delegate = self.delegate;
    if (delegate) {
        [delegate stackController:self didPerformSegue:segue];
    }
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
        
        [_foregroundViewController willMoveToParentViewController:nil];
        [_foregroundViewController.view removeFromSuperview];
        [_foregroundViewController removeFromParentViewController];
    }
    
    _foregroundViewController = foregroundViewController;
    
    [self addChildViewController:self.foregroundViewController];
    [self.view addSubview:self.foregroundViewController.view];
    
    if (!self.edgeGestureRecognizer) {
        _edgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panForegroundViewController:)];
    }
    self.edgeGestureRecognizer.edges = UIRectEdgeLeft;
    [self.foregroundViewController.view addGestureRecognizer:self.edgeGestureRecognizer];
    
    [self.foregroundViewController didMoveToParentViewController:self];
    
    if ([_foregroundViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)foregroundViewController;
        navigationController.topViewController.navigationItem.leftBarButtonItem = self.menuBarButtonItem;
    } else {
        _foregroundViewController.navigationItem.leftBarButtonItem = self.menuBarButtonItem;
    }
}

- (void)setBackgroundViewController:(UIViewController *)backgroundViewController {
    if (self.backgroundViewController) {
        [_backgroundViewController willMoveToParentViewController:nil];
        [_backgroundViewController.view removeFromSuperview];
        [_backgroundViewController removeFromParentViewController];
    }
    _backgroundViewController = backgroundViewController;
    
    [self addChildViewController:self.backgroundViewController];
    
    CGRect f = self.backgroundViewController.view.frame;
    f.size.width = self.view.frame.size.width - self.visibleWidth;
    self.backgroundViewController.view.frame = f;
    
    [self.view sendSubviewToBack:self.backgroundViewController.view];
    [self.backgroundViewController didMoveToParentViewController:self];
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
    
    [self updateBackgroundFrame];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGRect frame = self.foregroundViewController.view.frame;
        frame.origin.x = self.view.frame.size.width - self.visibleWidth;
        self.foregroundViewController.view.frame = frame;
        
        [self updateBackgroundFrame];
    }];
}

- (void)panForegroundViewController:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    
    // Pan foreground
    
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
    
    [self.view addSubview:self.backgroundViewController.view];
    [self.view bringSubviewToFront:self.foregroundViewController.view];
    [self updateBackgroundFrame];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (recognizer.view.frame.origin.x < (left / 2)) {
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
    
    [self updateBackgroundFrame];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        CGRect frame = self.foregroundViewController.view.frame;
        frame.origin.x = 0;
        self.foregroundViewController.view.frame = frame;
        
        [self updateBackgroundFrame];
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

- (void)updateBackgroundFrame {
    CGRect f = self.backgroundViewController.view.frame;
    f.origin.x = (self.foregroundViewController.view.frame.origin.x - f.size.width) / 3;
    self.backgroundViewController.view.frame = f;
}

@end
