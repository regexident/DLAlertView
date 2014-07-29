//
//  DLAVAlertViewTextFieldTheme.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewTextControlTheme.h"

@interface DLAVAlertViewTextFieldTheme : DLAVAlertViewTextControlTheme

@property (readwrite, assign, nonatomic) NSTextAlignment textAlignment;
@property (readwrite, assign, nonatomic) UITextBorderStyle borderStyle;

@end
