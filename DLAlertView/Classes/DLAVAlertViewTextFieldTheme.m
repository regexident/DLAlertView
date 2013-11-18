//
//  DLAVAlertViewTextFieldTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTextFieldTheme.h"

@interface DLAVAlertViewTextFieldTheme ()

@property (readwrite, assign, nonatomic) DLAVAlertViewThemeStyle style;

@end

@implementation DLAVAlertViewTextFieldTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	
	if (self) {
		_font = [UIFont systemFontOfSize:17.0];
		_textColor = [UIColor colorWithHue:0.61 saturation:0.92 brightness:0.97 alpha:1.0];
		_backgroundColor = [UIColor clearColor];
		_textAlignment = NSTextAlignmentCenter;
		
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
	return [(DLAVAlertViewTextFieldTheme *)[self alloc] initWithStyle : style];
}

#pragma mark - Style Adjustments

- (void)adjustPropertiesForStyleHUD {
	_textColor = [UIColor whiteColor];
}

#pragma mark - Convenience

+ (DLAVAlertViewThemeStyle)defaultThemeStyle {
	return [DLAVAlertViewTheme defaultThemeStyle];
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewTextFieldTheme *copy = [(DLAVAlertViewTextFieldTheme *)[[self class] alloc] init];
	
	if (copy) {
		copy.font = self.font;
		copy.textColor = self.textColor;
		copy.backgroundColor = self.backgroundColor;
		copy.textAlignment = self.textAlignment;
		
		copy.style = self.style;
	}
	
	return copy;
}

@end
