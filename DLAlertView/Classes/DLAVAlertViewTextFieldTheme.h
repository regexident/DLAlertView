//
//  DLAVAlertViewTextFieldTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLAVAlertViewTheme.h"

@interface DLAVAlertViewTextFieldTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIFont *font;
@property (readwrite, strong, nonatomic) UIColor *textColor;
@property (readwrite, strong, nonatomic) UIColor *backgroundColor;
@property (readwrite, assign, nonatomic) NSTextAlignment textAlignment;

@property (readonly, assign, nonatomic) DLAVAlertViewThemeStyle style;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style;
+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style;

#pragma mark - Convenience

+ (DLAVAlertViewThemeStyle)defaultThemeStyle;

@end
