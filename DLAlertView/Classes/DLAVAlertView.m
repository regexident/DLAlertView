//
//  DLAVAlertView.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertView.h"

#import "DLAVAlertViewTheme.h"
#import "DLAVAlertViewTextFieldTheme.h"
#import "DLAVAlertViewButtonTheme.h"
#import "DLAVAlertViewController.h"

static const CGFloat DLAVAlertViewThemeChangeDuration = 1.0;
static const CGFloat DLAVAlertViewAnimationDuration = 0.3;

@interface DLAVAlertViewController ()

+ (instancetype)sharedController;

- (void)setBackdropColor:(UIColor *)color;

- (void)addAlertView:(DLAVAlertView *)alertView;
- (void)removeAlertView:(DLAVAlertView *)alertView;

@end

@interface DLAVAlertView () <UITextFieldDelegate>

@property (readwrite, strong, nonatomic) UIView *clippingView;

@property (readwrite, strong, nonatomic) UILabel *titleLabel;
@property (readwrite, strong, nonatomic) UIView *titleBackgroundView;
@property (readwrite, strong, nonatomic) UILabel *messageLabel;

@property (readwrite, strong, nonatomic) NSMutableArray *textfields;
@property (readwrite, strong, nonatomic) NSMutableArray *buttons;
@property (readwrite, strong, nonatomic) NSMutableArray *lines;

@property (readwrite, strong, nonatomic) NSMutableArray *textFieldThemes;
@property (readwrite, strong, nonatomic) NSMutableArray *buttonThemes;
@property (readwrite, copy, nonatomic) DLAVAlertViewTheme *theme;

@property (readwrite, assign, nonatomic, getter = isVisible) BOOL visible;

@property (readwrite, assign, nonatomic) BOOL isObservingKeyboard;
@property (readwrite, assign, nonatomic) CGFloat keyboardHeight;

@property (readwrite, copy, nonatomic) DLAVAlertViewCompletionHandler completion;

- (CGSize)preferredFrameSize;

@end

@implementation DLAVAlertView

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ...{
	self = [self initWithFrame:CGRectZero];
	
	if (self) {
		self.clipsToBounds = NO;
		
		_delegate = delegate;
		
		_textfields = [NSMutableArray array];
		_buttons = [NSMutableArray array];
		_lines = [NSMutableArray array];
		
		_theme = [DLAVAlertViewTheme defaultTheme];
		_textFieldThemes = [NSMutableArray array];
		_buttonThemes = [NSMutableArray array];
		
		_dismissesOnBackdropTap = NO;
		_pairButtons = YES;
		
		_minContentWidth = 200.0;
		_maxContentWidth = 270.0;
		
		_clippingView = [[UIView alloc] initWithFrame:self.bounds];
		_clippingView.clipsToBounds = YES;
		[self addSubview:_clippingView];
		
		_alertViewStyle = DLAVAlertViewStyleDefault;
		
		[self addLabelWithTitle:title];
		
		[self addLabelWithMessage:message];
		
		if (cancelButtonTitle) {
			[self internalAddButtonWithTitle:cancelButtonTitle];
		}
		
		if (otherButtonTitle) {
			[self internalAddButtonWithTitle:otherButtonTitle];
		}
		
		NSString *firstOtherButtonTitle = otherButtonTitle ?: NSLocalizedString(@"OK", nil);
		
		if (otherButtonTitle) {
			va_list args;
			va_start(args, otherButtonTitle);
			NSString *buttonTitle;
			while ((buttonTitle = va_arg(args, NSString *))) {
				[self internalAddButtonWithTitle:buttonTitle];
			}
			va_end(args);
		}
		
		_cancelButtonIndex = [self indexOfButtonWithTitle:cancelButtonTitle];
		_doneButtonIndex = [self indexOfButtonWithTitle:firstOtherButtonTitle];
		
		[self applyTheme:_theme];
		
		[self updateFrameWithAnimationOfDuration:0.0];
	}
	
	return self;
}

+ (void)initialize  {
	if ([self class] == [DLAVAlertView class]) {
		[[DLAVAlertViewController sharedController] setBackdropColor:[UIColor colorWithWhite:0.0 alpha:0.4]];
	}
}

#pragma mark - Element Factories

+ (NSArray *)buttonTitlesWithCancelTitle:(NSString *)cancelTitle otherTitle:(NSString *)otherTitle  {
	if (cancelTitle && otherTitle) {
		return @[cancelTitle, otherTitle];
	} else if (cancelTitle) {
		return @[cancelTitle];
	}
	return nil;
}

+ (UILabel *)titleLabelWithTitle:(NSString *)title  {
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.text = (title.length) ? title : nil;
	titleLabel.backgroundColor = [UIColor clearColor];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
#else
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.lineBreakMode = UILineBreakModeWordWrap;
#endif
	titleLabel.numberOfLines = 0.0;
	return titleLabel;
}

+ (UILabel *)messageLabelWithMessage:(NSString *)message  {
	UILabel *messageLabel = [[UILabel alloc] init];
	messageLabel.text = (message.length) ? message : nil;
	messageLabel.backgroundColor = [UIColor clearColor];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
	messageLabel.textAlignment = NSTextAlignmentCenter;
	messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
#else
	messageLabel.textAlignment = UITextAlignmentCenter;
	messageLabel.lineBreakMode = UILineBreakModeWordWrap;
#endif
	messageLabel.numberOfLines = 0.0;
	return messageLabel;
}

+ (UITextField *)textFieldWithText:(NSString *)text placeholder:(NSString *)placeholder  {
	UITextField *textfield = [[UITextField alloc] init];
	textfield.backgroundColor = [UIColor clearColor];
	textfield.text = text;
	textfield.placeholder = placeholder;
	return textfield;
}

+ (UIButton *)buttonWithTitle:(NSString *)title target:(id)target  {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	if (title) {
		[button setTitle:title forState:UIControlStateNormal];
	} else {
		[button setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
	}
	button.enabled = NO;
	button.backgroundColor = [UIColor clearColor];
	return button;
}

+ (UIView *)line  {
	UIView *line = [[UIView alloc] init];
	return line;
}

#pragma mark - Textfields

- (void)addTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder {
	[self internalAddTextFieldWithText:text placeholder:placeholder];
}

- (UITextField *)internalAddTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder {
	UITextField *lastTextField = [self.textfields lastObject];
	
	lastTextField.returnKeyType = UIReturnKeyNext;
	
	// Add line:
	UIView *line = [[self class] line];
	line.backgroundColor = self.theme.lineColor;
	[self.clippingView addSubview:line];
	[self.lines insertObject:line atIndex:self.textfields.count];
	
	// Add default textfield theme placeholder:
	[self.textFieldThemes addObject:[NSNull null]];
	
	// Add textfield:
	NSUInteger numberOfTextFields = self.textfields.count;
	UITextField *textfield = [[self class] textFieldWithText:text placeholder:placeholder];
	textfield.returnKeyType = UIReturnKeyDone;
	textfield.tag = numberOfTextFields;
	textfield.delegate = self;
	[self.clippingView addSubview:textfield];
	[self.textfields addObject:textfield];
	
	// Theme textfield:
	
	DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:numberOfTextFields];
	[[self class] applyTheme:textFieldTheme toTextField:textfield animated:NO];
	
	// Handle layout changes:
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
	
	// Handle keyboard behaviour:
	if (!self.isObservingKeyboard) {
		[self addKeyboardNotificationObservers];
	}
	
	if (self.visible && (self.textfields.count == 1)) {
		[self makeTextFieldAtIndexFirstResponder:0];
	}
	
	return textfield;
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	return self.textfields[textFieldIndex];
}

- (NSString *)textFieldTextAtIndex:(NSInteger)buttonIndex {
	return [self textFieldAtIndex:buttonIndex].text;
}

- (NSInteger)numberOfTextFields {
	return self.textfields.count;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType ofTextFieldAtIndex:(NSInteger)index {
	[self textFieldAtIndex:index].keyboardType = keyboardType;
}

- (void)setInputView:(UIView *)inputView ofTextFieldAtIndex:(NSInteger)index {
	[self textFieldAtIndex:index].inputView = inputView;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry ofTextFieldAtIndex:(NSInteger)index {
	[self textFieldAtIndex:index].secureTextEntry = secureTextEntry;
}

- (DLAVAlertViewTextFieldTheme *)themeForTextFieldAtIndex:(NSUInteger)index {
	DLAVAlertViewTextFieldTheme *textFieldTheme = self.textFieldThemes[index];
	if ([textFieldTheme isKindOfClass:[NSNull class]]) {
		textFieldTheme = self.theme.textFieldTheme;
	}
	return textFieldTheme;
}

- (void)addLabelWithTitle:(NSString *)title {
	UILabel *titleLabel = [[self class] titleLabelWithTitle:title];
	[self.titleLabel removeFromSuperview];
	self.titleLabel = titleLabel;
	[self.clippingView addSubview:titleLabel];
	
	UIView *titleBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	[self.titleBackgroundView removeFromSuperview];
	self.titleBackgroundView = titleBackgroundView;
	[self.clippingView insertSubview:titleBackgroundView belowSubview:titleLabel];
}

- (void)addLabelWithMessage:(NSString *)message {
	UILabel *messageLabel = [[self class] titleLabelWithTitle:message];
	[self.messageLabel removeFromSuperview];
	self.messageLabel = messageLabel;
	[self.clippingView addSubview:messageLabel];
}

#pragma mark - Buttons

- (void)addButtonWithTitle:(NSString *)title {
	[self internalAddButtonWithTitle:title];
	[self updateButtons];
}

- (UIButton *)internalAddButtonWithTitle:(NSString *)title {
	// Add line:
	UIView *line = [[self class] line];
	
	line.backgroundColor = self.theme.lineColor;
	[self.clippingView addSubview:line];
	[self.lines addObject:line];
	
	// Add default button theme placeholder:
	[self.buttonThemes addObject:[NSNull null]];
	
	// Add button:
	NSUInteger numberOfButtons = [self numberOfButtons];
	UIButton *button = [[self class] buttonWithTitle:title target:self];
	button.tag = numberOfButtons;
	button.alpha = 0.0;
	[button addTarget:self action:@selector(dismissWithButton:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(setHighlightBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
	[self.clippingView addSubview:button];
	[self.buttons addObject:button];
	
	// Fade in the button
	[UIView animateWithDuration:([self animationDuration]/2.0f)
						  delay:([self animationDuration]/2.0f) options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 button.alpha = 1.0;
					 }
					 completion:nil];

	// Theme textfield:
	DLAVAlertViewButtonTheme *buttonTheme = [self themeForButtonAtIndex:numberOfButtons];
	[[self class] applyTheme:buttonTheme toButton:button animated:NO];
	
	// Handle layout changes:
	[self updateBoundsWithAnimationOfDuration:[self animationDuration]];
	
	return button;
}

- (UIButton *)buttonAtIndex:(NSInteger)buttonIndex {
	return self.buttons[buttonIndex];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
	return [self buttonAtIndex:buttonIndex].titleLabel.text;
}

- (NSInteger)indexOfButtonWithTitle:(NSString *)title {
	NSInteger buttonIndex = -1;
	NSUInteger i = 0;
	
	for (UIButton *button in self.buttons) {
		if ([button.titleLabel.text isEqualToString:title]) {
			buttonIndex = i;
			break;
		}
		
		i++;
	}
	
	return buttonIndex;
}

- (BOOL)isPrimaryButtonAtIndex:(NSUInteger)buttonIndex {
	if (self.numberOfButtons == 1) {
		return YES;
	} else if (self.numberOfButtons == 2 && self.pairButtons) {
		if (self.cancelButtonIndex != -1) {
			return (buttonIndex == self.cancelButtonIndex) ? NO : YES;
		} else {
			return NO;
		}
	} else {
		if (self.cancelButtonIndex != -1) {
			return (buttonIndex == self.cancelButtonIndex) ? YES : NO;
		} else {
			return NO;
		}
	}
}

- (DLAVAlertViewButtonTheme *)themeForButtonAtIndex:(NSUInteger)index {
	DLAVAlertViewButtonTheme *buttonTheme = self.buttonThemes[index];
	if ([buttonTheme isKindOfClass:[NSNull class]]) {
		buttonTheme = [self isPrimaryButtonAtIndex:index] ? self.theme.primaryButtonTheme : self.theme.otherButtonTheme;
	}
	return buttonTheme;
}

#pragma mark - Textfields

- (void)removeTextFieldsInRange:(NSRange)range {
	for (UITextField *textfield in [self.textfields subarrayWithRange : range]) {
		UIView *line = self.lines[0];
		[line removeFromSuperview];
		[self.lines removeObjectAtIndex:0];
		[textfield removeFromSuperview];
	}
	
	[self.textfields removeObjectsInRange:range];
	[self.textFieldThemes removeObjectsInRange:range];
	NSInteger buttonIndex = [self doneButtonIndex];
	
	if (buttonIndex != -1 && self.visible) {
		[self updateButtons];
	}
	
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
}

- (void)updateTextFieldsForAlertViewStyle:(DLAVAlertViewStyle)alertViewStyle {
	NSUInteger oldTextFieldCount = self.textfields.count;
	
	if (alertViewStyle == DLAVAlertViewStyleDefault) {
		[self endEditing:YES];
		[self removeKeyboardNotificationObservers];
	} else {
		[self addKeyboardNotificationObservers];
	}
	
	if ((alertViewStyle == DLAVAlertViewStylePlainTextInput) || (alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput)) {
		NSString *placeholderString = nil;
		if (alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput) {
			placeholderString = NSLocalizedString(@"Username", @"DLAVAlertView username placeholder");
		}
		UITextField *textField = [self internalAddTextFieldWithText:nil placeholder:placeholderString];
		textField.tag = 0;
		[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}
	
	if ((alertViewStyle == DLAVAlertViewStyleSecureTextInput) || (alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput)) {
		NSString *placeholderString = NSLocalizedString(@"Password", @"DLAVAlertView password placeholder");
		UITextField *textField = [self internalAddTextFieldWithText:nil placeholder:placeholderString];
		if (alertViewStyle == DLAVAlertViewStyleSecureTextInput) {
			textField.tag = 0;
		} else if (alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput) {
			textField.tag = 1;
		}
		textField.secureTextEntry = YES;
		[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}
	
	if (self.visible && (alertViewStyle != DLAVAlertViewStyleDefault)) {
		[self makeTextFieldAtIndexFirstResponder:oldTextFieldCount];
	}
	
	[self removeTextFieldsInRange:NSMakeRange(0, oldTextFieldCount)];
	
	if (self.visible) {
		[self updateButtons];
	}
}

- (void)setAlertViewStyle:(DLAVAlertViewStyle)alertViewStyle {
	_alertViewStyle = alertViewStyle;
	[self updateTextFieldsForAlertViewStyle:alertViewStyle];
}

- (NSInteger)numberOfButtons  {
	return self.buttons.count;
}

- (NSInteger)firstOtherButtonIndex  {
	if (self.cancelButtonIndex == -1) {
		return 0;
	}
	return (self.buttons.count == 1) ? -1 : 1;
}

- (void)setCancelButtonIndex:(NSInteger)cancelButtonIndex  {
	_cancelButtonIndex = MAX(cancelButtonIndex, -1);
}

- (NSString *)title {
	return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
	self.titleLabel.text = (title.length) ? title : nil;
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
}

- (NSString *)message {
	return self.messageLabel.text;
}

- (void)setMessage:(NSString *)message {
	self.messageLabel.text = (message.length) ? message : nil;
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
}

- (void)setContentView:(UIView *)contentView {
	[_contentView removeFromSuperview];
	_contentView = contentView;
	
	if (contentView) {
		[self.clippingView addSubview:contentView];
	}
	
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
}

- (void)setMinContentWidth:(CGFloat)minContentWidth {
	_minContentWidth = minContentWidth;
	[self updateFrameWithAnimationOfDuration:0.0];
}

- (void)setMaxContentWidth:(CGFloat)maxContentWidth {
	_maxContentWidth = maxContentWidth;
	[self updateFrameWithAnimationOfDuration:0.0];
}

#pragma mark - Theming

+ (void)setDefaultTheme:(DLAVAlertViewTheme *)theme {
	[DLAVAlertViewTheme setDefaultTheme:theme];
}

+ (void)setBackdropColor:(UIColor *)color {
	[DLAVAlertViewController sharedController].backdropColor = color ? : [UIColor clearColor];
}

- (void)setCustomTextFieldTheme:(DLAVAlertViewTextFieldTheme *)textFieldTheme forTextFieldAtIndex:(NSUInteger)index {
	[self setCustomTextFieldTheme:textFieldTheme forTextFieldAtIndex:index animated:NO];
}

- (void)setCustomTextFieldTheme:(DLAVAlertViewTextFieldTheme *)textFieldTheme forTextFieldAtIndex:(NSUInteger)index animated:(BOOL)animated {
	self.textFieldThemes[index] = textFieldTheme ? : [NSNull null];
	[[self class] applyTheme:((textFieldTheme) ? : self.theme.textFieldTheme) toTextField:[self textFieldAtIndex:index] animated:animated];
	[self updateFrameWithAnimationOfDuration:(animated) ? DLAVAlertViewAnimationDuration:0.0];
}

- (void)setCustomButtonTheme:(DLAVAlertViewButtonTheme *)buttonTheme forButtonAtIndex:(NSUInteger)index {
	[self setCustomButtonTheme:buttonTheme forButtonAtIndex:index animated:NO];
}

- (void)setCustomButtonTheme:(DLAVAlertViewButtonTheme *)buttonTheme forButtonAtIndex:(NSUInteger)index animated:(BOOL)animated {
	self.buttonThemes[index] = buttonTheme ? : [NSNull null];
	[[self class] applyTheme:((buttonTheme) ? : self.theme.buttonTheme) toButton:[self buttonAtIndex:index] animated:animated];
	[self updateFrameWithAnimationOfDuration:(animated) ? DLAVAlertViewAnimationDuration:0.0];
}

- (void)applyTheme:(DLAVAlertViewTheme *)theme  {
	[self applyTheme:theme animated:NO];
}

- (void)applyTheme:(DLAVAlertViewTheme *)theme animated:(BOOL)animated {
	if (_theme != theme) {
		self.theme = theme;
	}
	CGFloat duration = ((animated) ? DLAVAlertViewThemeChangeDuration : 0.0);
	[UIView animateWithDuration:duration animations:^{
		CALayer *layer = self.layer;
		layer.cornerRadius = theme.cornerRadius;
		layer.borderColor = theme.borderColor.CGColor;
		layer.borderWidth = theme.borderWidth;
		layer.shadowColor = theme.shadowColor.CGColor;
		layer.shadowRadius = theme.shadowRadius;
		layer.shadowOpacity = theme.shadowOpacity;
		layer.shadowOffset = theme.shadowOffset;
		CALayer *clippingLayer = self.clippingView.layer;
		clippingLayer.cornerRadius = theme.cornerRadius;
		self.backgroundColor = theme.backgroundColor;
		self.titleLabel.textColor = theme.titleColor;
		self.titleLabel.font = theme.titleFont;
		self.titleBackgroundView.backgroundColor = (theme.titleBackgroundColor ?: theme.backgroundColor);
		self.messageLabel.textColor = theme.messageColor;
		self.messageLabel.font = theme.messageFont;
		self.messageLabel.textAlignment = (NSTextAlignment)theme.messageAlignment;
		self.messageLabel.lineBreakMode = (NSLineBreakMode)theme.messageLineBreakMode;
		[self.lines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger index, BOOL *stop) {
			line.backgroundColor = theme.lineColor;
		}];
		[self.textfields enumerateObjectsUsingBlock:^(UITextField *textfield, NSUInteger index, BOOL *stop) {
			DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:index];
			[[self class] applyTheme:textFieldTheme toTextField:textfield animated:animated];
		}];
		[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
			DLAVAlertViewButtonTheme *buttonTheme = [self themeForButtonAtIndex:index];
			[[self class] applyTheme:buttonTheme toButton:button animated:animated];
		}];
	}];
	[self updateFrameWithAnimationOfDuration:duration];
}

+ (void)applyTheme:(DLAVAlertViewTextFieldTheme *)theme toTextField:(UITextField *)textfield animated:(BOOL)animated {
	CGFloat duration = ((animated) ? DLAVAlertViewThemeChangeDuration : 0.0);
	[UIView animateWithDuration:duration animations:^{
		textfield.font = theme.font;
		textfield.textColor = theme.textColor;
		textfield.backgroundColor = theme.backgroundColor;
		textfield.contentVerticalAlignment = theme.verticalContentAlignment;
		textfield.contentHorizontalAlignment = theme.horizontalContentAlignment;
		textfield.textAlignment = theme.textAlignment;
		textfield.borderStyle = theme.borderStyle;
	}];
}

+ (void)applyTheme:(DLAVAlertViewButtonTheme *)theme toButton:(UIButton *)button animated:(BOOL)animated {
	[UIView animateWithDuration:(animated ? DLAVAlertViewThemeChangeDuration : 0.0) animations:^{
		button.titleLabel.font = theme.font;
		[button setTitleColor:theme.textColor forState:UIControlStateNormal];
		
		if (theme.highlightTextColor) {
			[button setTitleColor:theme.highlightTextColor forState:UIControlStateDisabled];
		} else {
			UIColor *disabledColor = [theme.highlightTextColor colorWithAlphaComponent:CGColorGetAlpha(theme.highlightTextColor.CGColor) / 2];
			[button setTitleColor:disabledColor forState:UIControlStateDisabled];
		}
		[button setTitleColor:(theme.disabledTextColor ? : [theme.textColor colorWithAlphaComponent:0.3]) forState:UIControlStateDisabled];
		[button setTitleColor:(theme.highlightTextColor ? : theme.textColor) forState:UIControlStateHighlighted];
		button.backgroundColor = theme.backgroundColor;
		
		button.contentVerticalAlignment = theme.verticalContentAlignment;
		button.contentHorizontalAlignment = theme.horizontalContentAlignment;
		
		CALayer *layer = button.layer;
		layer.borderColor = theme.borderColor.CGColor;
		layer.borderWidth = theme.borderWidth;
		
		layer.cornerRadius = theme.cornerRadius;
		
		CALayer *titleLayer = button.titleLabel.layer;
		titleLayer.shadowColor = theme.textShadowColor.CGColor;
		titleLayer.shadowOpacity = theme.textShadowOpacity;
		titleLayer.shadowRadius = theme.textShadowRadius;
		titleLayer.shadowOffset = theme.textShadowOffset;
	}];
}

#pragma mark - Button State Handling

- (void)setBackgroundColorForButton:(UIButton *)button {
	DLAVAlertViewButtonTheme *theme = [self themeForButtonAtIndex:button.tag];
	button.backgroundColor = theme.backgroundColor;
}

- (void)setHighlightBackgroundColorForButton:(UIButton *)button {
	DLAVAlertViewButtonTheme *theme = [self themeForButtonAtIndex:button.tag];
	button.backgroundColor = theme.highlightBackgroundColor ? : theme.backgroundColor;
}

#pragma mark - Display Handling

- (void)show {
	[self showWithCompletion:nil];
}

- (void)showWithCompletion:(DLAVAlertViewCompletionHandler)completion {
	if (self.visible) {
		return;
	}
	
	self.completion = completion;
	[[DLAVAlertViewController sharedController] addAlertView:self];
	
	if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
		[self.delegate willPresentAlertView:self];
	}
	
	[self updateButtons];
	
	[self showAnimated:YES withCompletion:^{
		[self didShowOrUnhide];
		
		if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
			[self.delegate didPresentAlertView:self];
		}
	}];
}

- (void)willDismissOrHide {
	if(self.isObservingKeyboard){
		[self removeKeyboardNotificationObservers];
	}
	
	if (self.textfields.count) {
		[self endEditing:YES];
	}
}

- (void)didShowOrUnhide {
	if(self.textfields.count || self.hasCustomTextFields){
		[self addKeyboardNotificationObservers];
	}
	
	NSUInteger textfieldCount = self.textfields.count;
	for (NSUInteger index = 0; index < textfieldCount; index++) {
		[self makeTextFieldAtIndexFirstResponder:index];
	}
}

- (void)hideWithCompletion:(void (^)(void))completion {
	[self willDismissOrHide];
	[self dismissAnimated:YES withCompletion:^{
		if (completion) {
			completion();
		}
	}];
}

- (void)unhideWithCompletion:(void (^)(void))completion {
	[self updateButtons];
	
	[self showAnimated:YES withCompletion:^{
		[self didShowOrUnhide];
		
		if (completion) {
			completion();
		}
	}];
}

- (void)dismissWithBackdropTap {
	if ([self.delegate respondsToSelector:@selector(alertViewCancel:)]) {
		[self.delegate alertViewCancel:self];
	}
	
	[self dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)dismissWithButton:(UIButton *)sender {
	[self dismissWithClickedButtonIndex:sender.tag animated:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
	}
	
	if ([self.delegate respondsToSelector:@selector(alertView:shouldDismissAfterClickingButtonAtIndex:)]) {
		if(![self.delegate alertView:self shouldDismissAfterClickingButtonAtIndex:buttonIndex]){
			UIButton *clickedButton = [self buttonAtIndex:buttonIndex];
			[self setBackgroundColorForButton:clickedButton];
			return;
		}
	}
	
	double delayInSeconds = 0.1;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self didDismissWithClickedButtonIndex:buttonIndex animated:animated];
	});
}

- (void)didDismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[self willDismissOrHide];
	
	if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
		[self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
	}
	
	[self dismissAnimated:animated withCompletion:^{
		[[DLAVAlertViewController sharedController] removeAlertView:self];
		
		if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
			[self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
		}
		
		if (self.completion) {
			self.completion(self, buttonIndex);
			self.completion = nil;
		}
	}];
}

- (void)showAnimated:(BOOL)animated withCompletion:(void (^)(void))completion {
	CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	
	transformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.20, 1.20, 1.00)],
								  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.00)],
								  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.00)]];
	transformAnimation.keyTimes = @[@0.0, @0.5, @1.0];
	
	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.fromValue = @0.5;
	opacityAnimation.toValue = @1.0;
	
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.animations = @[transformAnimation, opacityAnimation, opacityAnimation];
	animationGroup.duration = 0.2;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.removedOnCompletion = NO;
	
	[self.layer addAnimation:animationGroup forKey:@"showAlert"];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationGroup.duration * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		self.visible = YES;
		
		if (completion) {
			completion();
		}
	});
}

- (void)dismissAnimated:(BOOL)animated withCompletion:(void (^)(void))completion {
	CAKeyframeAnimation *transformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	
	transformAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.00)],
								  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.00)],
								  [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.80, 0.80, 1.00)]];
	transformAnimation.keyTimes = @[@0.0, @0.5, @1.0];
	
	CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	opacityAnimation.fromValue = @1.0;
	opacityAnimation.toValue = @0.5;
	
	CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
	animationGroup.animations = @[transformAnimation, opacityAnimation, opacityAnimation];
	animationGroup.duration = 0.2;
	animationGroup.fillMode = kCAFillModeForwards;
	animationGroup.removedOnCompletion = NO;
	
	[self.layer addAnimation:animationGroup forKey:@"dismissAlert"];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationGroup.duration * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		self.visible = NO;
		
		if (completion) {
			completion();
		}
	});
}

- (void)makeTextFieldAtIndexFirstResponder:(NSUInteger)index {
	BOOL hasFirstResponder = NO;
	for (UITextField *textfield in self.textfields) {
		hasFirstResponder |= [textfield isFirstResponder];
	}
	BOOL makeFirstResponder = !hasFirstResponder && (index == 0); // by default make first textfield first responder
	if ([self.delegate respondsToSelector:@selector(alertView:textFieldAtIndex:shouldBecomeFirstResponder:)]) {
		makeFirstResponder = [self.delegate alertView:self textFieldAtIndex:index shouldBecomeFirstResponder:makeFirstResponder];
	}
	if (makeFirstResponder) {
		[self.textfields[index] becomeFirstResponder];
	}
}

#pragma mark - Keyboard Observation

- (void)addKeyboardNotificationObservers {
	if (self.isObservingKeyboard) {
		return;
	}
	
	self.isObservingKeyboard = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidChangeFrame:)
												 name:UIKeyboardWillChangeFrameNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)removeKeyboardNotificationObservers {
	if (!self.isObservingKeyboard) {
		return;
	}
	
	self.isObservingKeyboard = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillChangeFrameNotification
												  object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	self.keyboardHeight = 0.0;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardFrame;
	NSDictionary *userInfo = [notification userInfo];
	
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	CGRect screenRect = [[self class] getScreenFrameForCurrentOrientation];
	CGFloat keyboardHeight = CGRectGetHeight(keyboardFrame);
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	BOOL iOS8 = [[UIDevice currentDevice] systemVersion].floatValue >= 8.0;
	if (!iOS8 && ((orientation == UIInterfaceOrientationLandscapeRight) ||
				  (orientation == UIInterfaceOrientationLandscapeLeft))) {
		keyboardHeight = CGRectGetWidth(keyboardFrame);
	}
	
	screenRect.size.height -= keyboardHeight;
	self.keyboardHeight = keyboardHeight;
	self.center = CGPointMake(CGRectGetMidX(screenRect), CGRectGetMidY(screenRect));
	[UIView commitAnimations];
}

#pragma mark - UITextfieldDelegate Protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:textField.tag];
	textField.backgroundColor = textFieldTheme.highlightBackgroundColor;
	[self updateButtons];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:textField.tag];
	textField.backgroundColor = textFieldTheme.backgroundColor;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (self.visible && (textField.tag + 1 < self.textfields.count)) {
		[self makeTextFieldAtIndexFirstResponder:textField.tag + 1];
	}
	
	[textField resignFirstResponder];
	
	if ((textField.returnKeyType == UIReturnKeyDone) && (self.doneButtonIndex != NSNotFound)) {
		NSInteger doneButtonIndex = [self doneButtonIndex];
		if (doneButtonIndex != -1) {
			UIButton *doneButton = [self buttonAtIndex:doneButtonIndex];
			if (doneButton.enabled && (doneButtonIndex != -1)) {
				[self dismissWithButton:doneButton];
			}
		}
	}
	
	return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
	[self updateButtons];
}

- (void)updateButtons {
	NSInteger firstOtherButtonIndex = self.firstOtherButtonIndex;
	NSInteger doneButtonIndex = self.doneButtonIndex;
	
	BOOL respondsTo_alertViewShouldEnableFirstOtherButton = [self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)];
	BOOL respondsTo_alertView_buttonAtIndex_shouldBeEnabled = [self.delegate respondsToSelector:@selector(alertView:buttonAtIndex:shouldBeEnabled:)];
	
	BOOL doneButtonEnabled = YES;
	if (self.alertViewStyle == DLAVAlertViewStylePlainTextInput) {
		if (doneButtonIndex != -1) {
			doneButtonEnabled = [self textFieldTextAtIndex:0].length != 0;
		}
	} else if (self.alertViewStyle == DLAVAlertViewStyleSecureTextInput) {
		if (doneButtonIndex != -1) {
			doneButtonEnabled = [self textFieldTextAtIndex:0].length != 0;
		}
	} else if (self.alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput) {
		if (doneButtonIndex != -1) {
			doneButtonEnabled = [self textFieldTextAtIndex:0].length != 0 && [self textFieldTextAtIndex:1].length != 0;
		}
	}
	
	NSUInteger buttonCount = self.buttons.count;
	for (NSUInteger buttonIndex = 0; buttonIndex < buttonCount; buttonIndex++) {
		UIButton *button = [self buttonAtIndex:buttonIndex];
		BOOL buttonEnabled = YES;
		if ((buttonIndex == firstOtherButtonIndex) && respondsTo_alertViewShouldEnableFirstOtherButton) {
			buttonEnabled = [self.delegate alertViewShouldEnableFirstOtherButton:self];
		}
		if (respondsTo_alertView_buttonAtIndex_shouldBeEnabled) {
			if (buttonIndex == doneButtonIndex) {
				buttonEnabled = doneButtonEnabled;
			}
			buttonEnabled = [self.delegate alertView:self buttonAtIndex:buttonIndex shouldBeEnabled:buttonEnabled];
		}
		button.enabled = buttonEnabled;
	}
}

#pragma mark - View Layout

- (void)layoutSubviews  {
	BOOL animationsEnabled = [UIView areAnimationsEnabled];
	[UIView setAnimationsEnabled:NO];
	
	DLAVAlertViewTheme *theme = self.theme;
	
	self.clippingView.frame = self.bounds;
	
	CGSize alertSize = self.clippingView.frame.size;
	
	__block CGFloat offset = 0.0;
	
	// Layout title:
	if (self.title) {
		[self layoutTitleLabelWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	}
	
	// Layout message:
	if (self.message) {
		[self layoutMessageLabelWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	}
	
	self.messageLabel.hidden = self.message == nil;
	
	// Layout content view:
	if (self.contentView) {
		[self layoutContentViewWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	}
	
	if (self.textfields.count) {
		[self layoutTextFieldsWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	}
	
	NSUInteger buttonCount = self.buttons.count;
	// Layout buttons:
	if (buttonCount == 2 && self.pairButtons) {
		[self layoutButtonPairWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	} else if (buttonCount != 0) {
		[self layoutButtonsWithTheme:theme inAlertWithSize:alertSize atVerticalOffset:&offset];
	}
	
	[UIView setAnimationsEnabled:animationsEnabled];
}

- (void)layoutTitleLabelWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	CGFloat titleHeight = [self titleHeight];
	DLAVTextControlMargins titleMargins = theme.titleMargins;
	CGFloat titleBackgroundHeight = titleHeight + titleMargins.top + titleMargins.bottom;
	CGRect titleBackgroundViewFrame = CGRectMake(0, *offset, alertSize.width, titleBackgroundHeight);
	self.titleBackgroundView.frame = titleBackgroundViewFrame;
	CGRect titleLabelFrame = CGRectMake(titleMargins.left, *offset + titleMargins.top, alertSize.width - titleMargins.left - titleMargins.right, titleHeight);
	self.titleLabel.frame = titleLabelFrame;
	*offset += titleBackgroundHeight;
}

- (void)layoutMessageLabelWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	DLAVTextControlMargins messageMargins = theme.messageMargins;
	*offset += messageMargins.top;
	CGFloat messageHeight = [self messageHeight];
	self.messageLabel.frame = CGRectMake(messageMargins.left, *offset, alertSize.width - messageMargins.left - messageMargins.right, messageHeight);
	*offset += messageHeight + messageMargins.bottom;
}

- (void)layoutContentViewWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	DLAVTextControlMargins contentViewMargins = theme.contentViewMargins;
	UIView *contentView = self.contentView;
	*offset += contentViewMargins.top;
	CGFloat contentViewHeight = contentView.frame.size.height;
	contentView.frame = CGRectMake(contentViewMargins.left, *offset, MIN(alertSize.width, contentView.frame.size.width), contentViewHeight);
	contentView.center = CGPointMake(alertSize.width / 2, contentView.center.y);
	*offset += contentViewHeight + contentViewMargins.bottom;
}

- (void)layoutTextFieldsWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	CGFloat lineWidth = theme.lineWidth;
	__block NSUInteger lineIndex = 0;
	[self.textfields enumerateObjectsUsingBlock:^(UITextField *textfield, NSUInteger index, BOOL *stop) {
		// Layout line:
		UIView *horizontalLine = self.lines[lineIndex++];
		horizontalLine.frame = CGRectMake(0.0, *offset, alertSize.width, lineWidth);
		*offset += lineWidth;
		DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:index];
		DLAVTextControlMargins textfieldMargins = textFieldTheme.margins;
		*offset += textfieldMargins.top;
		CGFloat textfieldHeight = textFieldTheme.height;
		// Layout textfield:
		textfield.frame = CGRectMake(textfieldMargins.left,
									 *offset,
									 alertSize.width - textfieldMargins.left - textfieldMargins.right,
									 textfieldHeight);
		*offset += textfieldHeight + textfieldMargins.bottom;
	}];
}

- (void)layoutButtonPairWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	NSUInteger lineIndex = self.textfields.count;
	CGFloat lineWidth = theme.lineWidth;
	// Layout line:
	UIView *horizontalLine = self.lines[lineIndex++];
	horizontalLine.frame = CGRectMake(0.0, *offset, alertSize.width, lineWidth);
	*offset += lineWidth;
	
	// Layout buttons:
	CGFloat alertWidthHalf = alertSize.width * 0.5;
	
	DLAVAlertViewButtonTheme *leftButtonTheme = [self themeForButtonAtIndex:0];
	DLAVAlertViewButtonTheme *rightButtonTheme = [self themeForButtonAtIndex:1];
	DLAVTextControlMargins leftButtonMargins = leftButtonTheme.margins;
	DLAVTextControlMargins rightButtonMargins = rightButtonTheme.margins;
	CGFloat leftButtonHeight = leftButtonTheme.height;
	CGFloat rightButtonHeight = rightButtonTheme.height;
	
	UIButton *leftButton = self.buttons[0];
	UIButton *rightButton = self.buttons[1];
	
	leftButton.frame = CGRectMake(leftButtonMargins.left,
								  *offset + leftButtonMargins.top,
								  alertWidthHalf - leftButtonMargins.left - leftButtonMargins.right,
								  leftButtonHeight);
	
	rightButton.frame = CGRectMake(rightButtonMargins.left + alertWidthHalf,
								   *offset + rightButtonMargins.top,
								   alertWidthHalf - rightButtonMargins.left - rightButtonMargins.right,
								   rightButtonHeight);
	
	CGFloat maxVerticalOffsetDelta = MAX(leftButtonMargins.top + leftButtonHeight + leftButtonMargins.bottom,
										 rightButtonMargins.top + rightButtonHeight + rightButtonMargins.bottom);
	
	// Layout line:
	UIView *verticalLine = self.lines[lineIndex++];
	CGFloat lineHeight = maxVerticalOffsetDelta;
	verticalLine.frame = CGRectMake(alertWidthHalf, *offset, lineWidth, lineHeight);
	
	*offset += maxVerticalOffsetDelta;
}

- (void)layoutButtonsWithTheme:(DLAVAlertViewTheme *)theme inAlertWithSize:(CGSize)alertSize atVerticalOffset:(CGFloat *)offset {
	NSAssert(offset, @"Method argument 'offset' must not be NULL.");
	__block NSUInteger lineIndex = self.textfields.count;
	CGFloat lineWidth = theme.lineWidth;
	[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
		// Layout line:
		UIView *line = self.lines[lineIndex++];
		line.frame = CGRectMake(0.0, *offset, alertSize.width, lineWidth);
		*offset += lineWidth;
		
		// Layout button:
		DLAVAlertViewButtonTheme *buttonTheme = [self themeForButtonAtIndex:index];
		DLAVTextControlMargins buttonMargins = buttonTheme.margins;
		*offset += buttonMargins.top;
		CGFloat buttonHeight = buttonTheme.height;
		button.frame = CGRectMake(buttonMargins.left,
								  *offset,
								  alertSize.width - buttonMargins.left - buttonMargins.right,
								  buttonHeight);
		*offset += buttonHeight + buttonMargins.bottom;
	}];
}

- (CGFloat)alertWidth  {
	__block CGFloat width = 0.0;
	CGSize maxContentSize = CGSizeMake([self maxContentWidth], CGFLOAT_MAX);
	DLAVAlertViewTheme *theme = self.theme;
	
	CGFloat titleWidth = [[self class] optimalSizeForLabel:self.titleLabel inMaxSize:maxContentSize].width;
	DLAVTextControlMargins titleMargins = theme.titleMargins;
	width = MAX(width, titleMargins.left + titleWidth + titleMargins.right);
	
	CGFloat messageWidth = [[self class] optimalSizeForLabel:self.messageLabel inMaxSize:maxContentSize].width;
	DLAVTextControlMargins messageMargins = theme.messageMargins;
	width = MAX(width, messageMargins.left + messageWidth + messageMargins.right);
	
	CGFloat contentViewWidth = self.contentView.bounds.size.width;
	DLAVTextControlMargins contentViewMargins = theme.contentViewMargins;
	width = MAX(width, contentViewMargins.left + contentViewWidth + contentViewMargins.right);
	
	if (self.buttons.count == 2 && self.pairButtons) {
		CGFloat leftWidth = [[self class] optimalSizeForLabel:[self buttonAtIndex:0].titleLabel inMaxSize:maxContentSize].width;
		CGFloat rightWidth = [[self class] optimalSizeForLabel:[self buttonAtIndex:1].titleLabel inMaxSize:maxContentSize].width;
		DLAVAlertViewButtonTheme *leftButtonTheme = [self themeForButtonAtIndex:0];
		DLAVAlertViewButtonTheme *rightButtonTheme = [self themeForButtonAtIndex:1];
		DLAVTextControlMargins leftButtonMargins = leftButtonTheme.margins;
		DLAVTextControlMargins rightButtonMargins = rightButtonTheme.margins;
		leftWidth += leftButtonMargins.left + leftButtonMargins.right;
		rightWidth += rightButtonMargins.left + rightButtonMargins.right;
		width = MAX(width, leftWidth + rightWidth);
	} else {
		[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
			width = MAX(width, [[self class] optimalSizeForLabel:button.titleLabel inMaxSize:maxContentSize].width);
			DLAVAlertViewButtonTheme *buttonTheme = [self themeForButtonAtIndex:index];
			DLAVTextControlMargins buttonMargins = buttonTheme.margins;
			width += buttonMargins.left + buttonMargins.right;
		}];
	}
	
	width = MIN(width, [self maxContentWidth]);
	width = MAX(width, [self minContentWidth]);
	return width;
}

- (CGFloat)alertHeight  {
	DLAVAlertViewTheme *theme = self.theme;
	
	CGFloat lineWidth = theme.lineWidth;
	
	CGFloat height = 0.0;
	
	// Title height:
	if (self.title) {
		DLAVTextControlMargins titleMargins = theme.titleMargins;
		height += titleMargins.top + [self titleHeight] + titleMargins.bottom;
	}
	
	// Message height:
	if (self.message) {
		DLAVTextControlMargins messageMargins = theme.messageMargins;
		if (!self.title) {
			messageMargins.top = theme.titleMargins.top;
		}
		height += messageMargins.top + [self messageHeight] + messageMargins.bottom;
	}
	
	// Content view height:
	if (self.contentView) {
		DLAVTextControlMargins contentViewMargins = theme.contentViewMargins;
		height += contentViewMargins.top + [self contentViewHeight] + contentViewMargins.bottom;
	}
	
	// Textfield heights:
	NSUInteger textfieldCount = self.textfields.count;
	if (textfieldCount) {
		for (NSUInteger index = 0; index < textfieldCount; index++) {
			DLAVAlertViewTextFieldTheme *textFieldTheme = [self themeForTextFieldAtIndex:index];
			DLAVTextControlMargins textFieldMargins = textFieldTheme.margins;
			height += lineWidth + textFieldMargins.top + textFieldTheme.height + textFieldMargins.bottom;
		}
	}
	
	// Button heights:
	NSUInteger buttonCount = self.buttons.count;
	if (buttonCount == 2 && self.pairButtons) {
		DLAVAlertViewButtonTheme *leftButtonTheme = [self themeForButtonAtIndex:0];
		DLAVAlertViewButtonTheme *rightButtonTheme = [self themeForButtonAtIndex:1];
		DLAVTextControlMargins leftButtonMargins = leftButtonTheme.margins;
		DLAVTextControlMargins rightButtonMargins = rightButtonTheme.margins;
		height += lineWidth + MAX(leftButtonMargins.top + leftButtonTheme.height + leftButtonMargins.bottom,
								  rightButtonMargins.top + rightButtonTheme.height + rightButtonMargins.bottom);
	} else {
		for (NSUInteger index = 0; index < buttonCount; index++) {
			DLAVAlertViewButtonTheme *buttonTheme = [self themeForButtonAtIndex:index];
			DLAVTextControlMargins buttonMargins = buttonTheme.margins;
			height += lineWidth + buttonMargins.top + buttonTheme.height + buttonMargins.bottom;
		}
	}
	
	// Use floor() to remove fractional points that would otherwise leave a gap around the content.
	return floor(height);
}

- (CGSize)preferredFrameSize  {
	return CGSizeMake([self alertWidth], [self alertHeight]);
}

- (CGFloat)titleHeight  {
	DLAVTextControlMargins margins = self.theme.titleMargins;
	CGFloat usableWidth = [self alertWidth] - margins.left - margins.right;
	return ceil([[self class] optimalSizeForLabel:self.titleLabel inMaxSize:CGSizeMake(usableWidth, CGFLOAT_MAX)].height);
}

- (CGFloat)messageHeight  {
	DLAVTextControlMargins margins = self.theme.messageMargins;
	CGFloat usableWidth = [self alertWidth] - margins.left - margins.right;
	return (self.messageLabel) ? ceil([[self class] optimalSizeForLabel:self.messageLabel inMaxSize:CGSizeMake(usableWidth, CGFLOAT_MAX)].height) : 0.0;
}

- (CGFloat)contentViewHeight  {
	return self.contentView.bounds.size.height;
}

+ (CGSize)optimalSizeForLabel:(UILabel *)label inMaxSize:(CGSize)maxSize {
	CGSize size = CGSizeMake(0.0, 0.0);
	
	if (!label.text) {
		return size;
	}
	
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 61000
	NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
	context.minimumScaleFactor = 1.0;
	size = [label.text boundingRectWithSize:maxSize
									options:NSStringDrawingUsesLineFragmentOrigin
								 attributes:@{ NSFontAttributeName : label.font }
									context:context].size;
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	size = [label.text sizeWithFont:label.font
				  constrainedToSize:maxSize
					  lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
#endif
	
	return size;
}

- (CGFloat)animationDuration {
	return (self.visible) ? DLAVAlertViewAnimationDuration : 0.0;
}

- (void)updateFrameWithAnimationOfDuration:(NSTimeInterval)duration {
	[self updateBoundsWithAnimationOfDuration:0.0];
	[self updateCenterWithAnimationOfDuration:duration];
}

- (void)updateBoundsWithAnimationOfDuration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{
		CGSize size = [self preferredFrameSize];
		
		CGSize screenSize = [[self class] getScreenFrameForCurrentOrientation].size;
		CGFloat margin = 10.0;
		size.width = MIN(screenSize.width - margin, size.width);
		size.height = MIN(screenSize.height - margin, size.height);
		
		self.bounds = CGRectMake(0.0, 0.0, size.width, size.height);
	}];
}

- (void)updateCenterWithAnimationOfDuration:(NSTimeInterval)duration {
	CGRect rect = [[self class] getScreenFrameForCurrentOrientation];
	CGFloat keyboardHeight = self.keyboardHeight;
	
	rect.size.height -= keyboardHeight;
	[UIView animateWithDuration:duration animations:^{
		self.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
	}];
}

+ (CGRect)getScreenFrameForCurrentOrientation {
	return [self getScreenFrameForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+ (CGRect)getScreenFrameForOrientation:(UIInterfaceOrientation)orientation {
	UIScreen *screen = [UIScreen mainScreen];
	CGRect fullScreenRect = screen.bounds;

	BOOL iOS8 = [[UIDevice currentDevice] systemVersion].floatValue >= 8.0;
	if (!iOS8 && UIInterfaceOrientationIsLandscape(orientation)) {
		CGRect temp = CGRectZero;
		temp.size.width = fullScreenRect.size.height;
		temp.size.height = fullScreenRect.size.width;
		fullScreenRect = temp;
	}
	
	return fullScreenRect;
}

@end
