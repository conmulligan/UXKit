//
//  UXValueViewController.h
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

#import <UIKit/UIKit.h>

typedef enum {
    UXValueViewControllerModeNumber,
    UXValueViewControllerModeRange,
    UXValueViewControllerModePercentage,
    UXValueViewControllerModeMultiValue,
} UXValueViewControllerMode;

@class UXValueViewController;

@protocol UXValueViewControllerDelegate <NSObject>

@optional
- (void)valueViewController:(UXValueViewController *)viewController didSelectNumber:(NSNumber *)number;
- (void)valueViewController:(UXValueViewController *)viewController didSelectObject:(NSObject *)object fromArray:(NSArray *)array;

@end

@interface UXValueViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSObject *value;
@property (strong, nonatomic) NSArray *range;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (assign, nonatomic) UXValueViewControllerMode mode;

@property (assign, nonatomic) NSObject<UXValueViewControllerDelegate> *delegate;

@property (strong, nonatomic, readonly) UILabel *valueLabel;
@property (strong, nonatomic, readonly) UILabel *leftLabel;
@property (strong, nonatomic, readonly) UILabel *rightLabel;

- (id)initWithValue:(id)value;

@end
