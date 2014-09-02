//
//  DLAVAlertViewTextControlTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTextControlTheme.h"

@interface DLAVAlertViewTextControlTheme ()

@end

@implementation DLAVAlertViewTextControlTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		_font = [UIFont systemFontOfSize:17.0];
		
		_verticalContentAlignment = UIControlContentVerticalAlignmentCenter;
		_horizontalContentAlignment = UIControlContentHorizontalAlignmentCenter;
		
		_textColor = [UIColor darkTextColor];
		_highlightTextColor = nil;
		_disabledTextColor = [UIColor grayColor];
		
		_backgroundColor = [UIColor clearColor];
		_highlightBackgroundColor = [UIColor clearColor];
		
		_borderColor = [UIColor blackColor];
		_borderWidth = 0.0;
		
		_cornerRadius = 0.0;
		
		_height = 44.0;
		_margins = DLAVTextControlMarginsNone;
	}
	return self;
}

+ (instancetype)theme {
	return [[self alloc] init];
}

#pragma mark - Convenience

- (instancetype)themeWithRegularSystemFont {
	DLAVAlertViewTextControlTheme *theme = [self copy];
	
	theme.font = [UIFont systemFontOfSize:theme.font.pointSize];
	return theme;
}

- (instancetype)themeWithBoldSystemFont {
	DLAVAlertViewTextControlTheme *theme = [self copy];
	
	theme.font = [UIFont boldSystemFontOfSize:theme.font.pointSize];
	return theme;
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewTextControlTheme *copy = [[[self class] alloc] init];
	if (copy) {
		copy.font = self.font;
		
		copy.textColor = self.textColor;
		copy.highlightTextColor = self.highlightTextColor;
		copy.disabledTextColor = self.disabledTextColor;
		
		copy.backgroundColor = self.backgroundColor;
		copy.highlightBackgroundColor = self.highlightBackgroundColor;
		
		copy.borderColor = self.borderColor;
		copy.borderWidth = self.borderWidth;
		
		copy.cornerRadius = self.cornerRadius;
		
		copy.height = self.height;
		copy.margins = self.margins;
	}
	return copy;
}

@end
