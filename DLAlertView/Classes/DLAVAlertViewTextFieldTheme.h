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

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *backgroundColor;

@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIView *inputView;

@property (nonatomic) BOOL secureTextEntry;

@property (nonatomic, readonly) DLAVAlertViewThemeStyle style;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style;
+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style;

#pragma mark - Convenience

- (instancetype)themeWithSecureTextEntry:(BOOL)secureTextEntry;

+ (DLAVAlertViewThemeStyle)defaultThemeStyle;

@end
