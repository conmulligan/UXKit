//
//  UXValueViewController.m
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

#import "UXValueViewController.h"

#define kSliderTag 123

@interface UXValueViewController ()

@property (nonatomic, retain) UISlider *slider;

@end

@implementation UXValueViewController

@synthesize value = _value;
@synthesize range = _range;
@synthesize selectedIndex = _selectedIndex;
@synthesize mode = _mode;
@synthesize delegate = _delegate;
@synthesize valueLabel = _valueLabel;
@synthesize leftLabel = _leftLabel;
@synthesize rightLabel = _rightLabel;
@synthesize slider = _slider;

#pragma mark - Initialization

- (id)initWithValue:(id)value {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        BOOL supported = NO;

        if ([value isKindOfClass:[NSNumber class]]) {
            supported = YES;
            self.mode = UXValueViewControllerModeNumber;
        } else if ([value isKindOfClass:[NSArray class]]) {
            supported = YES;
            self.mode = UXValueViewControllerModeMultiValue;
        }
        
        if (supported) {
            self.value = value;
        } else {
            [NSException raise:NSInvalidArgumentException format:@"Value %@ is invalid.", value];
        }
    }
    return self;
}

- (void)setPercentageMode:(BOOL)mode {
    if ([self.value isKindOfClass:[NSNumber class]] && [(NSNumber *)self.value floatValue] > 1.f) {
        [NSException raise:NSInvalidArgumentException format:@"Percantage Mode requires a number less than 1."];
    } else {
        _mode = mode;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Value", @"");
}

#pragma mark - Subviews

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont boldSystemFontOfSize:16.f];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textColor = [UIColor darkGrayColor];
        _valueLabel.shadowColor = [UIColor whiteColor];
        _valueLabel.shadowOffset = CGSizeMake(0.f, 1.f);
    }
    return _valueLabel;
}

- (UILabel *)leftLabel {
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLabel;
}

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightLabel.backgroundColor = [UIColor clearColor];
        _rightLabel.font = [UIFont boldSystemFontOfSize:15.f];
        _rightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightLabel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.value isKindOfClass:[NSNumber class]]) {
        return 1;
    } else if ([self.value isKindOfClass:[NSArray class]]) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.value isKindOfClass:[NSNumber class]]) {
        return 1;
    } else if ([self.value isKindOfClass:[NSArray class]]) {
        return (NSInteger)[(NSArray *)self.value count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.mode == UXValueViewControllerModeRange) {
        return 40.f;
    }
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.mode == UXValueViewControllerModeRange) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 40.f)];
        
        self.valueLabel.frame = CGRectMake(10.f, 10.f, containerView.frame.size.width - 20.f, 20.f);
        self.valueLabel.text = [NSString stringWithFormat:@"%0.1f", [(NSNumber *)self.value floatValue]];
        [containerView addSubview:self.valueLabel];
        
        return containerView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    if ([self.value isKindOfClass:[NSNumber class]]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (self.mode == UXValueViewControllerModeRange) {
            cell.textLabel.text = @"";
            
            float min = [(NSNumber *)[(NSArray *)self.range objectAtIndex:0] floatValue];
            float max = [(NSNumber *)[(NSArray *)self.range lastObject] floatValue];
            float value = [(NSNumber *)self.value floatValue];
            
            if (!self.leftLabel.text) {
                self.leftLabel.text = [NSString stringWithFormat:@"%0.1f", min];
            }
            
            CGRect leftRect = [self.leftLabel.text boundingRectWithSize:CGSizeMake(120.f, 34.f)
                                                                options:(NSStringDrawingTruncatesLastVisibleLine)
                                                             attributes:@{NSFontAttributeName: self.leftLabel.font}
                                                                context:nil];
            
            self.leftLabel.frame = CGRectMake(10.f, 5.f, leftRect.size.width, 34.f);
            [cell.contentView addSubview:self.leftLabel];
            
            if (!self.rightLabel.text) {
                self.rightLabel.text = [NSString stringWithFormat:@"%0.1f", max];
            }
            CGRect rightRect = [self.rightLabel.text boundingRectWithSize:CGSizeMake(120.f, 34.f)
                                                                  options:(NSStringDrawingTruncatesLastVisibleLine)
                                                               attributes:@{NSFontAttributeName: self.rightLabel.font}
                                                                  context:nil];
            self.rightLabel.frame = CGRectMake(290.f - rightRect.size.width, 5.f, rightRect.size.width, 34.f);
            [cell.contentView addSubview:self.rightLabel];
            
            if (!self.slider) {
                _slider = [[UISlider alloc] initWithFrame:CGRectZero];
                _slider.tag = kSliderTag;
                _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                _slider.minimumValue = 0.f;
                _slider.maximumValue = 1.f;
                _slider.value = [(NSNumber *)self.value floatValue];
                [_slider addTarget:self action:@selector(sliderDidSlide:) forControlEvents:UIControlEventValueChanged];
            }
            _slider.frame = CGRectMake(self.leftLabel.frame.size.width + 15.f,
                                       2.f,
                                       290.f - self.leftLabel.frame.size.width - self.rightLabel.frame.size.width,
                                       40.f);
            _slider.minimumValue = min;
            _slider.maximumValue = max;
            _slider.value = value;
            [cell.contentView addSubview:_slider];
            
        } else if (self.mode == UXValueViewControllerModePercentage) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d%%", (int)([(NSNumber *)self.value floatValue] * 100)];
            
            if (!self.slider) {
                _slider = [[UISlider alloc] initWithFrame:CGRectMake(60.f, 2.f, 248.f, 40.f)];
                _slider.tag = kSliderTag;
                _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [_slider addTarget:self action:@selector(sliderDidSlide:) forControlEvents:UIControlEventValueChanged];
            }
            _slider.minimumValue = 0.f;
            _slider.maximumValue = 1.f;
            _slider.value = [(NSNumber *)self.value floatValue];
            [cell.contentView addSubview:_slider];
        } else {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, 10.f, 280.f, 40.f)];
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.delegate = self;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.placeholder = NSLocalizedString(@"Enter a Number", @"");
            textField.text = [(NSNumber *)self.value stringValue];
            
            [cell.contentView addSubview:textField];
            [textField becomeFirstResponder];
        }
    } else if ([self.value isKindOfClass:[NSArray class]]) {
        if (indexPath.row == (NSInteger)self.selectedIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        NSObject *item = [(NSArray *)self.value objectAtIndex:(NSUInteger)indexPath.row];
        cell.textLabel.text = [item description];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.value isKindOfClass:[NSArray class]]) {
        NSObject *item = [(NSArray *)self.value objectAtIndex:(NSUInteger)indexPath.row];
        if ([self.delegate respondsToSelector:@selector(valueViewController:didSelectObject:fromArray:)]) {
            [self.delegate valueViewController:self didSelectObject:item fromArray:(NSArray *)self.value];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Slider change event

- (void)sliderDidSlide:(id)sender {
    if ([self.value isKindOfClass:[NSNumber class]]) {
        if (self.mode == UXValueViewControllerModeRange) {
            _valueLabel.text = [NSString stringWithFormat:@"%0.1f", _slider.value];
        } else if (self.mode == UXValueViewControllerModePercentage) {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.textLabel.text = [NSString stringWithFormat:@"%d%%", (int)(_slider.value * 100)];
        }
        
        NSNumber *number = [NSNumber numberWithFloat:self.slider.value];
        if (self.delegate && [self.delegate respondsToSelector:@selector(valueViewController:didSelectNumber:)]) {
            [self.delegate valueViewController:self didSelectNumber:number];
        }
    }
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.delegate) {
        if ([self.value isKindOfClass:[NSNumber class]]) {
            NSNumber *number = [NSNumber numberWithFloat:[textField.text floatValue]];
            if ([self.delegate respondsToSelector:@selector(valueViewController:didSelectNumber:)]) {
                [self.delegate valueViewController:self didSelectNumber:number];
            }
        }
    }
}

@end
