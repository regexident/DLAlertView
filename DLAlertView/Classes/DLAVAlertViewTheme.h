//
//  DLAVAlertViewTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, DLAVAlertViewThemeStyle) {
	DLAVAlertViewThemeStyleIOS7, // default
	DLAVAlertViewThemeStyleHUD
};

@class DLAVAlertViewTextFieldTheme, DLAVAlertViewButtonTheme;

@interface DLAVAlertViewTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIColor *backgroundColor;

@property (readwrite, assign, nonatomic) CGFloat cornerRadius;

@property (readwrite, strong, nonatomic) UIColor *lineColor;

@property (readwrite, strong, nonatomic) UIColor *borderColor;
@property (readwrite, assign, nonatomic) CGFloat borderWidth;

@property (readwrite, strong, nonatomic) UIColor *titleColor;
@property (readwrite, strong, nonatomic) UIFont *titleFont;
@property (readwrite, strong, nonatomic) UIColor *messageColor;
@property (readwrite, strong, nonatomic) UIFont *messageFont;

@property (readwrite, copy, nonatomic) DLAVAlertViewTextFieldTheme *textFieldTheme;
@property (readwrite, copy, nonatomic) DLAVAlertViewButtonTheme *buttonTheme;

@property (readonly, assign, nonatomic) DLAVAlertViewThemeStyle style;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style;
+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style;

+ (DLAVAlertViewTheme *)defaultTheme;
+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme;

#pragma mark - Defaults

+ (DLAVAlertViewThemeStyle)defaultThemeStyle;

@end

