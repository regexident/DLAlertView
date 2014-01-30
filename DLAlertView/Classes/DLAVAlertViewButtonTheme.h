//
//  DLAVAlertViewButtonTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTextControlTheme.h"

@interface DLAVAlertViewButtonTheme : DLAVAlertViewTextControlTheme

@property (readwrite, strong, nonatomic) UIColor *textShadowColor;
@property (readwrite, assign, nonatomic) CGFloat textShadowOpacity;
@property (readwrite, assign, nonatomic) CGFloat textShadowRadius;
@property (readwrite, assign, nonatomic) CGSize textShadowOffset;

@end
