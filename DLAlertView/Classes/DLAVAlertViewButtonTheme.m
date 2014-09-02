//
//  DLAVAlertViewButtonTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewButtonTheme.h"

@interface DLAVAlertViewButtonTheme ()

@end

@implementation DLAVAlertViewButtonTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		self.font = [UIFont systemFontOfSize:17.0];
		self.textColor = [UIColor colorWithHue:0.61 saturation:0.92 brightness:0.97 alpha:1.0];
		self.highlightBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
		self.height = 44.0;
		
		_textShadowColor = [UIColor clearColor];
		_textShadowOpacity = 0.0;
		_textShadowRadius = 0.0;
		_textShadowOffset = CGSizeMake(0.0, 0.0);
	}
	return self;
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewButtonTheme *copy = [super copyWithZone:zone];
	if (copy) {
		copy.textShadowColor = self.textShadowColor;
		copy.textShadowOpacity = self.textShadowOpacity;
		copy.textShadowRadius = self.textShadowRadius;
		copy.textShadowOffset = self.textShadowOffset;
	}
	return copy;
}

@end
