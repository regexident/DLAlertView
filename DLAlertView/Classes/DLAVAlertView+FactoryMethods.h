//
//  DLAVAlertView+FactoryMethods.h
//  DLAlertView
//
//  Created by Austin Drummond on 2/20/15.
//  Copyright (c) 2015 Definite Loop. All rights reserved.
//

#import "DLAVAlertView.h"

@interface DLAVAlertView (FactoryMethods)

+ (instancetype) alertWithTitle:(NSString *)title
                        message:(NSString*)message
                       delegate:(id)delegate
                         cancel:(NSString*)cancel
                   otherButtons:(NSArray*)otherButtons;

+ (instancetype) showAlertWithTitle:(NSString *)title;

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message;

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString*)cancel;

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString*)cancel
                               done:(NSString*)done
                     withCompletion:(DLAVAlertViewCompletionHandler)handler;

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString*)cancel
                       otherButtons:(NSArray *)otherButtons
                     withCompletion:(DLAVAlertViewCompletionHandler)handler;

+ (instancetype) showAlertWith:(NSError *)error
                withCompletion:(DLAVAlertViewCompletionHandler)handler;

@end
