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

const DLAVTextControlMargins DLAVTextControlMarginsNone = {0.0, 0.0, 0.0, 0.0};

DLAVTextControlMargins DLAVTextControlMarginsMake(CGFloat top, CGFloat bottom, CGFloat left, CGFloat right) {
	return (DLAVTextControlMargins){top, bottom, left, right};
}

static DLAVAlertViewTheme *defaultTheme = nil;

@interface DLAVAlertViewTheme ()

@end

@implementation DLAVAlertViewTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	
	if (self) {
		_backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
		
		_cornerRadius = 8.0;
		
		_lineWidth = 1.0 / [[UIScreen mainScreen] scale];
		_lineColor = [UIColor colorWithWhite:0.0 alpha:0.15];
		
		_borderColor = [UIColor clearColor];
		_borderWidth = 0.0;
		
		_contentViewMargins = DLAVTextControlMarginsMake(0.0, 10.0, 10.0, 10.0);
		
		_titleMargins = DLAVTextControlMarginsMake(18.0, 15.0, 10.0, 10.0);
		_titleColor = [UIColor darkTextColor];
		_titleFont = [UIFont boldSystemFontOfSize:17.0];
		
		_messageMargins = DLAVTextControlMarginsMake(-5.0, 18.0, 10.0, 10.0);
		_messageColor = [UIColor darkTextColor];
		_messageFont = [UIFont systemFontOfSize:15.0];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
		_messageAlignment = NSTextAlignmentCenter;
		_messageLineBreakMode = NSLineBreakByWordWrapping;
#else
		_messageAlignment = UITextAlignmentCenter;
		_messageLineBreakMode = UILineBreakModeWordWrap;
#endif
		
		_shadowColor = [UIColor blackColor];
		_shadowOpacity = 0.5;
		_shadowRadius = 20.0;
		_shadowOffset = CGSizeMake(0.0, 0.0);
		
		_textFieldTheme = [[DLAVAlertViewTextFieldTheme alloc] init];
		
		_buttonTheme = [[DLAVAlertViewButtonTheme alloc] init];
		_primaryButtonTheme = [[[DLAVAlertViewButtonTheme alloc] init] themeWithBoldSystemFont];
		_otherButtonTheme = [[[DLAVAlertViewButtonTheme alloc] init] themeWithRegularSystemFont];
	}
	
	return self;
}

+ (instancetype)theme {
	return [[self alloc] init];
}

- (void)setButtonTheme:(DLAVAlertViewButtonTheme *)buttonTheme
{
	_buttonTheme = _primaryButtonTheme = _otherButtonTheme = buttonTheme;
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

+ (void)setDefaultTheme:(DLAVAlertViewTheme *)aDefaultTheme  {
	@synchronized(self) {
		defaultTheme = [aDefaultTheme copy];
	}
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewTheme *copy = [(DLAVAlertViewTheme *)[[self class] alloc] init];
	
	if (copy) {
		copy.backgroundColor = self.backgroundColor;
		
		copy.cornerRadius = self.cornerRadius;
		
		copy.lineWidth = self.lineWidth;
		copy.lineColor = self.lineColor;
		
		copy.borderColor = self.borderColor;
		copy.borderWidth = self.borderWidth;
		
		copy.titleMargins = self.titleMargins;
		copy.titleColor = self.titleColor;
		copy.titleFont = self.titleFont;
		
		copy.messageMargins = self.messageMargins;
		copy.messageColor = self.messageColor;
		copy.messageFont = self.messageFont;
		
		copy.shadowColor = self.shadowColor;
		copy.shadowOpacity = self.shadowOpacity;
		copy.shadowRadius = self.shadowRadius;
		copy.shadowOffset = self.shadowOffset;
		
		copy.textFieldTheme = [self.textFieldTheme copy];
		
		copy.primaryButtonTheme = [self.primaryButtonTheme copy];
		copy.otherButtonTheme = [self.otherButtonTheme copy];
	}
	
	return copy;
}

@end
