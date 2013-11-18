//
//  DLAVAlertViewTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTheme.h"

#import "DLAVAlertViewTextFieldTheme.h"
#import "DLAVAlertViewButtonTheme.h"

static DLAVAlertViewTheme *defaultTheme = nil;

@interface DLAVAlertViewTheme ()

@property (readwrite, assign, nonatomic) DLAVAlertViewThemeStyle style;

@end

@implementation DLAVAlertViewTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	
	if (self) {
		_backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		
		_cornerRadius = 8.0;
		
		_lineColor = [UIColor colorWithWhite:0.0 alpha:0.15];
		
		_borderColor = [UIColor clearColor];
		_borderWidth = 0.0;
		
		_titleColor = [UIColor blackColor];
		_titleFont = [UIFont boldSystemFontOfSize:17.0];
		_messageColor = [UIColor blackColor];
		_messageFont = [UIFont systemFontOfSize:15.0];
		
		_textFieldTheme = [[DLAVAlertViewTextFieldTheme alloc] initWithStyle:[[self class] defaultThemeStyle]];
		_buttonTheme = [[DLAVAlertViewButtonTheme alloc] initWithStyle:[[self class] defaultThemeStyle]];
		
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
		_textFieldTheme = [[DLAVAlertViewTextFieldTheme alloc] initWithStyle:style];
		_buttonTheme = [[DLAVAlertViewButtonTheme alloc] initWithStyle:style];
		
		if (style == DLAVAlertViewThemeStyleIOS7) {
			// default no changes necessary
		} else if (style == DLAVAlertViewThemeStyleHUD) {
			[self adjustPropertiesForStyleHUD];
		}
	}
	
	return self;
}

+ (instancetype)themeWithStyle:(DLAVAlertViewThemeStyle)style {
	return [(DLAVAlertViewTheme *)[self alloc] initWithStyle : style];
}

#pragma mark - Defaults

+ (DLAVAlertViewThemeStyle)defaultThemeStyle {
	return DLAVAlertViewThemeStyleIOS7;
}

#pragma mark - Style Adjustments

- (void)adjustPropertiesForStyleHUD {
	_backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
	_lineColor = [UIColor colorWithWhite:1.0 alpha:0.5];
	_titleColor = [UIColor whiteColor];
	_messageColor = [UIColor whiteColor];
}

+ (void)initialize  {
	if ([self class] == [DLAVAlertViewTheme class]) {
		[self setDefaultTheme:[DLAVAlertViewTheme theme]];
	}
}

+ (DLAVAlertViewTheme *)defaultTheme  {
	@synchronized(self) {
		return [defaultTheme copy];
	}
}

+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme  {
	@synchronized(self) {
		defaultTheme = theme;
	}
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewTheme *copy = [(DLAVAlertViewTheme *)[[self class] alloc] init];
	
	if (copy) {
		copy.backgroundColor = self.backgroundColor;
		
		copy.cornerRadius = self.cornerRadius;
		
		copy.lineColor = self.lineColor;
		
		copy.borderColor = self.borderColor;
		copy.borderWidth = self.borderWidth;
		
		copy.titleColor = self.titleColor;
		copy.titleFont = self.titleFont;
		copy.messageColor = self.messageColor;
		copy.messageFont = self.messageFont;
		
		copy.textFieldTheme = self.textFieldTheme;
		copy.buttonTheme = self.buttonTheme;
		
		copy.style = self.style;
	}
	
	return copy;
}

@end
