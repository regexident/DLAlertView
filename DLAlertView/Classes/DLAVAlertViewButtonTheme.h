//
//  DLAVAlertViewButtonTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLAVAlertViewTheme.h"

@interface DLAVAlertViewButtonTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIFont *font;

@property (readwrite, strong, nonatomic) UIColor *textColor;
@property (readwrite, strong, nonatomic) UIColor *highlightTextColor;
@property (readwrite, strong, nonatomic) UIColor *disabledTextColor;

@property (readwrite, strong, nonatomic) UIColor *backgroundColor;
@property (readwrite, strong, nonatomic) UIColor *highlightBackgroundColor;

@property (readonly, assign, nonatomic) DLAVAlertViewThemeStyle style;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style;
+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style;

#pragma mark - Convenience

- (instancetype)themeWithRegularSystemFont:(BOOL)bold;
- (instancetype)themeWithBoldSystemFont:(BOOL)bold;

+ (DLAVAlertViewThemeStyle)defaultThemeStyle;

@end
