//
//  DLAVAlertViewTextControlTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLAVAlertViewTheme.h"

@interface DLAVAlertViewTextControlTheme : NSObject <NSCopying>

#pragma mark - Properties

@property (readwrite, strong, nonatomic) UIFont *font;

@property (readwrite, assign, nonatomic) UIControlContentVerticalAlignment verticalContentAlignment;
@property (readwrite, assign, nonatomic) UIControlContentHorizontalAlignment horizontalContentAlignment;

@property (readwrite, strong, nonatomic) UIColor *textColor;
@property (readwrite, strong, nonatomic) UIColor *highlightTextColor;
@property (readwrite, strong, nonatomic) UIColor *disabledTextColor;

@property (readwrite, strong, nonatomic) UIColor *backgroundColor;
@property (readwrite, strong, nonatomic) UIColor *highlightBackgroundColor;

@property (readwrite, strong, nonatomic) UIColor *borderColor;
@property (readwrite, assign, nonatomic) CGFloat borderWidth;

@property (readwrite, assign, nonatomic) CGFloat cornerRadius;

@property (readwrite, assign, nonatomic) CGFloat height;
@property (readwrite, assign, nonatomic) DLAVTextControlMargins margins;

#pragma mark - Initialization

- (id)init;
+ (instancetype)theme;

#pragma mark - Convenience

- (instancetype)themeWithRegularSystemFont;
- (instancetype)themeWithBoldSystemFont;

@end
