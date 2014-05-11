//
//  UXWebViewController.m
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

#import "UIDevice+Utilities.h"
#import "UXSafariActivity.h"
#import "UXWebViewController.h"

@interface UXWebViewController ()

@end

@implementation UXWebViewController

@synthesize webView = _webView;
@synthesize titleLabel = _titleLabel;
@synthesize request = _request;

#pragma mark - Initialization

- (id)initWithRequest:(NSURLRequest *)request {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.request = request;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.frame];
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _titleLabel.font = [UIFont systemFontOfSize:12.f];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 2;
    _titleLabel.textColor = [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = [[self.request URL] description];
    self.navigationItem.titleView = _titleLabel;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];
    [_webView loadRequest:_request];
    
    if (self.parentViewController.parentViewController.presentedViewController == self.navigationController) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(dismissViewController:)];
        if ([UIDevice isiPad]) {
            self.navigationItem.leftBarButtonItem = doneButton;   
        } else {
            self.navigationItem.rightBarButtonItem = doneButton;
        }
    }
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"UXKit.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    UIImage *left = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"Left" ofType:@"png"]];
    UIImage *right = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"Right" ofType:@"png"]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:left
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(backButtonSelected:)];
    backButton.enabled = NO;
    
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage:right
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(forwardButtonSelected:)];
    forwardButton.enabled = NO;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadButtonSelected:)];
    
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(shareButtonSelected:)];
    
    self.toolbarItems = [NSArray arrayWithObjects:backButton, flexibleSpace, forwardButton, flexibleSpace, reloadButton, flexibleSpace, shareButton, nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([UIDevice isiPad]) {
        [self.navigationController setToolbarHidden:YES animated:YES];
        
        UIToolbar *topToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.f, 0.f, 240.f, 44.f)];
        topToolbar.backgroundColor = [UIColor clearColor];
        topToolbar.tintColor = [UIColor blackColor];
        topToolbar.opaque = NO;
        topToolbar.items = self.toolbarItems;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:topToolbar];
    } else {
        [self.navigationController setToolbarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.webView stopLoading];
}

- (void)dismissViewController:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Web view helpers

- (NSString *)location {
    return [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)wv {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [self updateToolbar];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.titleLabel.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateToolbar];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)urlRequest navigationType:(UIWebViewNavigationType)navigationType {
    self.request = urlRequest;
    return YES;
}

#pragma mark - Toolbar actions

- (void)updateToolbar {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbarItems];
    
    UIBarButtonItem *backButton = [items objectAtIndex:0];
    if (_webView.canGoBack) {
        backButton.enabled = YES;
    } else {
        backButton.enabled = NO;
    }
    [items replaceObjectAtIndex:0 withObject:backButton];
    
    UIBarButtonItem *forwardButton = [items objectAtIndex:2];
    if (_webView.canGoForward) {
        forwardButton.enabled = YES;
    } else {
        forwardButton.enabled = NO;
    }
    [items replaceObjectAtIndex:2 withObject:forwardButton];
    
    if (_webView.loading) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        UIBarButtonItem *activityViewButton = [[UIBarButtonItem alloc] initWithCustomView:activityView];
        [items replaceObjectAtIndex:4 withObject:activityViewButton];
        
    } else {
        UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                      target:self
                                                                                      action:@selector(reloadButtonSelected:)];
        [items replaceObjectAtIndex:4 withObject:reloadButton];
    }
    
    self.toolbarItems = items;
}

- (void)backButtonSelected:(id)sender {
    [self.webView goBack];
}

- (void)forwardButtonSelected:(id)sender {
    [self.webView goForward];
}

- (void)reloadButtonSelected:(id)sender {
    [self.webView reload];
}

- (void)shareButtonSelected:(id)sender {
    NSURL *url = self.webView.request.URL;
    
    UXSafariActivity *activity = [[UXSafariActivity alloc] init];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[activity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
