//
//  DLAVAlertView.h
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, DLAVAlertViewStyle) {
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

typedef void (^DLAVAlertViewCompletionHandler)(DLAVAlertView *alertView, NSInteger buttonIndex);

@interface DLAVAlertView : UIView

#pragma mark - Properties

@property (readwrite, weak, nonatomic) id <DLAVAlertViewDelegate> delegate;
@property (readwrite, copy, nonatomic) NSString *title;
@property (readwrite, copy, nonatomic) NSString *message;

@property (readonly, assign, nonatomic) NSInteger numberOfButtons;
@property (readwrite, assign, nonatomic) NSInteger cancelButtonIndex;

@property (readonly, assign, nonatomic) NSInteger firstOtherButtonIndex;
@property (readonly, assign, nonatomic, getter = isVisible) BOOL visible;
@property (readwrite, assign, nonatomic) BOOL dismissesOnBackdropTap;

@property(nonatomic, assign) DLAVAlertViewStyle alertViewStyle;

@property (readwrite, strong, nonatomic) UIView *contentView;

@property (readwrite, assign, nonatomic) CGFloat minContentWidth;
@property (readwrite, assign, nonatomic) CGFloat maxContentWidth;

+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme;

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title
			message:(NSString *)message
		   delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Textfields

- (NSInteger)addTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder;
- (NSString *)textFieldTextAtIndex:(NSInteger)textFieldIndex;

- (void)setKeyboardType:(UIKeyboardType)keyboardType ofTextFieldAtIndex:(NSInteger)index;
- (void)setInputView:(UIView *)inputView ofTextFieldAtIndex:(NSInteger)index;
- (void)setSecureTextEntry:(BOOL)secureTextEntry ofTextFieldAtIndex:(NSInteger)index;

#pragma mark - Buttons

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (NSInteger)indexOfButtonWithTitle:(NSString *)title;

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