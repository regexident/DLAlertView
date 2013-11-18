//
//  DLAVAlertViewButtonTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewButtonTheme.h"

@interface DLAVAlertViewButtonTheme ()

@property (readwrite, assign, nonatomic) DLAVAlertViewThemeStyle style;

@end

@implementation DLAVAlertViewButtonTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	
	if (self) {
		_font = [UIFont systemFontOfSize:17.0];
		
		_textColor = [UIColor colorWithHue:0.61 saturation:0.92 brightness:0.97 alpha:1.0];
		_highlightTextColor = nil;
		_disabledTextColor = [UIColor grayColor];
		
		_backgroundColor = [UIColor clearColor];
		_highlightBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
		
		_style = [[self class] defaultThemeStyle];
	}
	
	return self;
}

+ (instancetype)theme {
	return [[self alloc] init];
}

- (id)initWithStyle:(DLAVAlertViewThemeStyle)style {
	self = [self init];
	
	if (self) {
		_style = style;
		
		if (style == DLAVAlertViewThemeStyleHUD) {
			[self adjustPropertiesForStyleHUD];
		}
	}
	
	return self;
}

+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style {
	return [(DLAVAlertViewButtonTheme *)[self alloc] initWithStyle : style];
}

#pragma mark - Style Adjustments

- (void)adjustPropertiesForStyleHUD {
	_textColor = [UIColor whiteColor];
	_disabledTextColor = [UIColor colorWithWhite:1.0 alpha:0.5];
}

#pragma mark - Convenience

- (instancetype)themeWithRegularSystemFont:(BOOL)bold {
	DLAVAlertViewButtonTheme *theme = [self copy];
	
	theme.font = [UIFont systemFontOfSize:theme.font.pointSize];
	return theme;
}

- (instancetype)themeWithBoldSystemFont:(BOOL)bold {
	DLAVAlertViewButtonTheme *theme = [self copy];
	
	theme.font = [UIFont boldSystemFontOfSize:theme.font.pointSize];
	return theme;
}

+ (DLAVAlertViewThemeStyle)defaultThemeStyle {
	return [DLAVAlertViewTheme defaultThemeStyle];
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewButtonTheme *copy = [(DLAVAlertViewButtonTheme *)[[self class] alloc] init];
	
	if (copy) {
		copy.font = self.font;
		
		copy.textColor = self.textColor;
		copy.highlightTextColor = self.highlightTextColor;
		copy.disabledTextColor = self.disabledTextColor;
		
		copy.backgroundColor = self.backgroundColor;
		copy.highlightBackgroundColor = self.highlightBackgroundColor;
		
		copy.style = self.style;
	}
	
	return copy;
}

@end
