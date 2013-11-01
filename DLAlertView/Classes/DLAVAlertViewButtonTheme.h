//
//  DLAVAlertViewButtonTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLAVAlertViewTheme.h"

@interface DLAVAlertViewButtonTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (nonatomic) UIFont *font;

@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *highlightTextColor;
@property (nonatomic) UIColor *disabledTextColor;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *highlightBackgroundColor;

@property (nonatomic, readonly) DLAVAlertViewThemeStyle style;

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
