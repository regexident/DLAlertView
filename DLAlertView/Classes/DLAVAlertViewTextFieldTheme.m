//
//  DLAVAlertViewTextFieldTheme.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTextFieldTheme.h"

@interface DLAVAlertViewTextFieldTheme ()

@end

@implementation DLAVAlertViewTextFieldTheme

#pragma mark - Initialization

- (id)init {
	self = [super init];
	if (self) {
		self.font = [UIFont systemFontOfSize:17.0];
		self.height = 33.0;
		self.textAlignment = NSTextAlignmentCenter;
		self.backgroundColor = [UIColor clearColor];
		self.highlightBackgroundColor = [UIColor colorWithHue:0.61 saturation:0.92 brightness:0.97 alpha:0.1];
	}
	return self;
}

#pragma mark - NSCopying Protocol

- (instancetype)copyWithZone:(NSZone *)zone {
	DLAVAlertViewTextFieldTheme *copy = [super copyWithZone:zone];
	if (copy) {
		copy.textAlignment = self.textAlignment;
	}
	return copy;
}

@end
