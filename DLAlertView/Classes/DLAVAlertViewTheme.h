//
//  DLAVAlertViewTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DLAVAlertViewThemeStyle) {
	DLAVAlertViewThemeStyleIOS7, // default
	DLAVAlertViewThemeStyleHUD
};

@class DLAVAlertViewTextFieldTheme, DLAVAlertViewButtonTheme;

@interface DLAVAlertViewTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (nonatomic) UIColor *backgroundColor;

@property (nonatomic) CGFloat cornerRadius;

@property (nonatomic) UIColor *lineColor;

@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;

@property (nonatomic) UIColor *titleColor;
@property (nonatomic) UIFont *titleFont;
@property (nonatomic) UIColor *messageColor;
@property (nonatomic) UIFont *messageFont;

@property (nonatomic, copy) DLAVAlertViewTextFieldTheme *textFieldTheme;
@property (nonatomic, copy) DLAVAlertViewButtonTheme *buttonTheme;

@property (nonatomic, readonly) DLAVAlertViewThemeStyle style;

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

