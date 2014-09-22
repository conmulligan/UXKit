//
//  BSMapsActivity.h
//  UXKit
//
//  Created by Conor Mulligan on 23/09/2014.
//  Copyright (c) 2014 Conor Mulligan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UXMapsActivity : UIActivity

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, assign) NSUInteger zoomLevel;

@end
