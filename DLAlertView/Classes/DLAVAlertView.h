//
//  DLAVAlertView.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Definite Loop. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DLAVAlertViewStyle) {
    DLAVAlertViewStyleDefault = 0,
    DLAVAlertViewStyleSecureTextInput,
    DLAVAlertViewStylePlainTextInput,
    DLAVAlertViewStyleLoginAndPasswordInput
};

@class DLAVAlertView;

#pragma mark Delegate Protocol

@protocol DLAVAlertViewDelegate <NSObject>

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(DLAVAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(DLAVAlertView *)alertView;

- (void)willPresentAlertView:(DLAVAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(DLAVAlertView *)alertView;  // after animation

- (void)alertView:(DLAVAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(DLAVAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(DLAVAlertView *)alertView;

@end

@class DLAVAlertView, DLAVAlertViewTheme, DLAVAlertViewButtonTheme, DLAVAlertViewTextFieldTheme;

typedef void(^DLAVAlertViewCompletionHandler)(DLAVAlertView *alertView, NSInteger buttonIndex);

@interface DLAVAlertView : UIView

#pragma mark - Properties

@property (nonatomic, weak) id <DLAVAlertViewDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic) NSInteger cancelButtonIndex;

@property (nonatomic, readonly) NSInteger firstOtherButtonIndex;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic, readwrite) BOOL dismissesOnBackdropTap;

@property(nonatomic, assign) DLAVAlertViewStyle alertViewStyle;

@property (nonatomic) UIView *contentView;

@property (readwrite, assign, nonatomic) CGFloat minContentWidth;
@property (readwrite, assign, nonatomic) CGFloat maxContentWidth;

+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme;

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
		   delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Initialization

- (NSInteger)addTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder;
- (NSString *)textFieldTextAtIndex:(NSInteger)textFieldIndex;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

#pragma mark - Display

- (void)show;
- (void)showWithCompletion:(DLAVAlertViewCompletionHandler)completion;

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

#pragma mark - Theming

+ (void)setBackdropColor:(UIColor *)color;

- (void)applyTheme:(DLAVAlertViewTheme *)theme;
- (void)applyTheme:(DLAVAlertViewTheme *)theme animated:(BOOL)animated;

- (void)setCustomButtonTheme:(DLAVAlertViewButtonTheme *)buttonTheme forButtonAtIndex:(NSUInteger)index;
- (void)setCustomButtonTheme:(DLAVAlertViewButtonTheme *)buttonTheme forButtonAtIndex:(NSUInteger)index animated:(BOOL)animated;

- (void)setCustomTextFieldTheme:(DLAVAlertViewTextFieldTheme *)textFieldTheme forTextFieldAtIndex:(NSUInteger)index;
- (void)setCustomTextFieldTheme:(DLAVAlertViewTextFieldTheme *)textFieldTheme forTextFieldAtIndex:(NSUInteger)index animated:(BOOL)animated;

@end