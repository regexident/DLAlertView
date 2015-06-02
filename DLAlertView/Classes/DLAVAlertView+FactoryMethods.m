//
//  DLAVAlertView+FactoryMethods.m
//  DLAlertView
//
//  Created by Austin Drummond on 2/20/15.
//  Copyright (c) 2015 Definite Loop. All rights reserved.
//

#import "DLAVAlertView+FactoryMethods.h"

@implementation DLAVAlertView (FactoryMethods)

+ (instancetype) alertWithTitle:(NSString *)title
                        message:(NSString*)message
                       delegate:(id)delegate
                         cancel:(NSString*)cancel
                   otherButtons:(NSArray*)otherButtons {
    
    DLAVAlertView *av = [[DLAVAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:delegate
                                           cancelButtonTitle:cancel
                                                buttonTitles:otherButtons];
    return av;
}

+ (instancetype) alertWithTitle:(NSString *)title
                        message:(NSString*)message
                         cancel:(NSString*)cancel
                           done:(NSString*)done {
    
    NSArray *buttons = done ? @[done] : @[];
    
    return [self alertWithTitle:title
                        message:message
                       delegate:nil
                         cancel:cancel
                   otherButtons:buttons];
}

+ (instancetype) showAlertWithTitle:(NSString *)title {
    
    return [self showAlertWithTitle:title
                            message:nil
                             cancel:nil
                               done:nil
                     withCompletion:nil];
}

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message {
    
    return [self showAlertWithTitle:title
                            message:message
                             cancel:nil
                               done:nil
                     withCompletion:nil];
}

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString *)cancel {
    
    return [self showAlertWithTitle:title
                            message:message
                             cancel:cancel
                               done:nil
                     withCompletion:nil];
}

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString*)cancel
                               done:(NSString*)done
                     withCompletion:(DLAVAlertViewCompletionHandler)handler {
    
    DLAVAlertView *av = [self alertWithTitle:title
                                     message:message
                                      cancel:cancel
                                        done:done];
    [av showWithCompletion:handler];
    return av;
}

+ (instancetype) showAlertWithTitle:(NSString *)title
                            message:(NSString*)message
                             cancel:(NSString*)cancel
                       otherButtons:(NSArray *)otherButtons
                     withCompletion:(DLAVAlertViewCompletionHandler)handler {
    
    DLAVAlertView *av = [self alertWithTitle:title
                                     message:message
                                    delegate:nil
                                      cancel:cancel
                                otherButtons:otherButtons];
    
    [av showWithCompletion:handler];
    return av;
}

+ (instancetype) showAlertWith:(NSError *)error
                withCompletion:(DLAVAlertViewCompletionHandler)handler {
    
    DLAVAlertView *av;
    if (error) {
        
        NSString *title = @"Unknown Error";
        NSString *message = [NSString stringWithFormat:@"An unknown error occurred. Please try agian later. (%ld)",error.code];
        
        if (error.code < NSURLErrorBadURL && error.code > NSURLErrorNotConnectedToInternet) {
            
            title = @"Network Error";
            message = [NSString stringWithFormat:@"Please check your network connection and try again later. (%ld)",error.code];
            
        } else {
            
        }
        
        av = [self alertWithTitle:title
                          message:message
                         delegate:nil
                           cancel:nil
                     otherButtons:nil];
    }
    
    [av showWithCompletion:handler];
    return av;
}

@end
