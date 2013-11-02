//
//  DLAVAlertViewTextFieldTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLAVAlertViewTheme.h"

@interface DLAVAlertViewTextFieldTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIFont *font;
@property (readwrite, strong, nonatomic) UIColor *textColor;
@property (readwrite, strong, nonatomic) UIColor *backgroundColor;

@property (readwrite, assign, nonatomic) NSTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) UIKeyboardType keyboardType;
@property (readwrite, strong, nonatomic) UIView *inputView;

@property (readwrite, assign, nonatomic) BOOL secureTextEntry;

@property (readonly, assign, nonatomic) DLAVAlertViewThemeStyle style;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style;
+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style;

#pragma mark - Convenience

- (instancetype)themeWithSecureTextEntry:(BOOL)secureTextEntry;

+ (DLAVAlertViewThemeStyle)defaultThemeStyle;

@end
