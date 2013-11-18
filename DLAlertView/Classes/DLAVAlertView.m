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

static const CGFloat DLAVAlertViewContentMargin = 10.0;
static const CGFloat DLAVAlertViewVerticalSpacing = 10.0;
static const CGFloat DLAVAlertViewThemeChangeDuration = 1.0;
static const CGFloat DLAVAlertViewAnimationDuration = 0.3;

@interface DLAVAlertViewController ()

+ (instancetype)sharedController;

- (void)setBackdropColor:(UIColor *)color;

- (void)addAlertView:(DLAVAlertView *)alertView;
- (void)removeAlertView:(DLAVAlertView *)alertView;

@end

@interface DLAVAlertView () <UITextFieldDelegate>

@property (readwrite, strong, nonatomic) UILabel *titleLabel;
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

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		self.clipsToBounds = YES;
		_textfields = [NSMutableArray array];
		_buttons = [NSMutableArray array];
		_lines = [NSMutableArray array];
		
		_theme = [DLAVAlertViewTheme defaultTheme];
		_textFieldThemes = [NSMutableArray array];
		_buttonThemes = [NSMutableArray array];
		
		_dismissesOnBackdropTap = NO;
		
		_minContentWidth = 200.0;
		_maxContentWidth = 270.0;
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle, ...{
	self = [self initWithFrame:CGRectZero];
	
	if (self) {
		UILabel *titleLabel = [[self class] titleLabelWithTitle:title];
		_titleLabel = titleLabel;
		[self addSubview:titleLabel];
		
		UILabel *messageLabel = [[self class] titleLabelWithTitle:message];
		_messageLabel = messageLabel;
		[self addSubview:messageLabel];
		
		_alertViewStyle = DLAVAlertViewStyleDefault;
		
		if (cancelButtonTitle) {
			[self addButtonWithTitle:cancelButtonTitle];
		}
		
		if (otherButtonTitle) {
			[self addButtonWithTitle:otherButtonTitle];
		}
		
		if (otherButtonTitle) {
			va_list args;
			va_start(args, otherButtonTitle);
			NSString *buttonTitle;
			
			while ((buttonTitle = va_arg(args, NSString *))) {
				[self addButtonWithTitle:buttonTitle];
			}
			
			va_end(args);
		}
		
		_cancelButtonIndex = [self indexOfButtonWithTitle:cancelButtonTitle];
		
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
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
	titleLabel.numberOfLines = 0.0;
	return titleLabel;
}

+ (UILabel *)messageLabelWithMessage:(NSString *)message  {
	UILabel *messageLabel = [[UILabel alloc] init];
	
	messageLabel.text = (message.length) ? message : nil;
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.textAlignment = NSTextAlignmentCenter;
	messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
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
	
	button.backgroundColor = [UIColor clearColor];
	return button;
}

+ (UIView *)line  {
	UIView *line = [[UIView alloc] init];
	
	return line;
}

#pragma mark - Textfields

- (NSInteger)addTextFieldWithText:(NSString *)text placeholder:(NSString *)placeholder {
	UITextField *lastTextField = [self.textfields lastObject];
	
	lastTextField.returnKeyType = UIReturnKeyNext;
	
	// Add line:
	UIView *line = [[self class] line];
	line.backgroundColor = self.theme.lineColor;
	[self addSubview:line];
	[self.lines insertObject:line atIndex:self.textfields.count];
	
	// Add default textfield theme placeholder:
	[self.textFieldThemes addObject:[NSNull null]];
	
	// Add textfield:
	NSUInteger numberOfTextFields = self.textfields.count;
	UITextField *textfield = [[self class] textFieldWithText:text placeholder:placeholder];
	textfield.returnKeyType = UIReturnKeyDone;
	textfield.tag = numberOfTextFields;
	textfield.delegate = self;
	[self addSubview:textfield];
	[self.textfields addObject:textfield];
	
	// Theme textfield:
	[[self class] applyTheme:self.theme.textFieldTheme toTextField:textfield animated:NO];
	
	// Handle layout changes:
	[self updateFrameWithAnimationOfDuration:[self animationDuration]];
	
	// Handle keyboard behaviour:
	if (!self.isObservingKeyboard) {
		[self addKeyboardNotificationObservers];
	}
	
	if (self.visible && (self.textfields.count == 1)) {
		[self.textfields[0] becomeFirstResponder];
	}
	
	return numberOfTextFields;
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
	return self.textfields[textFieldIndex];
}

- (NSString *)textFieldTextAtIndex:(NSInteger)buttonIndex {
	return [self textFieldAtIndex:buttonIndex].text;
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

#pragma mark - Buttons
- (NSInteger)addButtonWithTitle:(NSString *)title {
	// Add line:
	UIView *line = [[self class] line];
	
	line.backgroundColor = self.theme.lineColor;
	[self addSubview:line];
	[self.lines addObject:line];
	
	// Add default button theme placeholder:
	[self.buttonThemes addObject:[NSNull null]];
	
	// Add button:
	NSUInteger numberOfButtons = self.buttons.count;
	UIButton *button = [[self class] buttonWithTitle:title target:self];
	button.tag = numberOfButtons;
	[button addTarget:self action:@selector(dismissWithButton:) forControlEvents:UIControlEventTouchUpInside];
	[button addTarget:self action:@selector(setHighlightBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
	[button addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
	[self addSubview:button];
	[self.buttons addObject:button];
	
	// Theme textfield:
	[[self class] applyTheme:self.theme.buttonTheme toButton:button animated:NO];
	
	// Handle layout changes:
	[self updateBoundsWithAnimationOfDuration:[self animationDuration]];
	
	return numberOfButtons;
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
	NSInteger buttonIndex = [self firstOtherButtonIndex];
	
	if (buttonIndex != -1) {
		[self buttonAtIndex:buttonIndex].enabled = YES;
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
		
		[self addTextFieldWithText:nil placeholder:placeholderString];
		[self setCustomTextFieldTheme:self.theme.textFieldTheme
				  forTextFieldAtIndex:self.textfields.count - 1];
		UITextField *textField = [self.textfields lastObject];
		[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}
	
	if ((alertViewStyle == DLAVAlertViewStyleSecureTextInput) || (alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput)) {
		NSString *placeholderString = NSLocalizedString(@"Password", @"DLAVAlertView password placeholder");
		[self addTextFieldWithText:nil placeholder:placeholderString];
		[self setCustomTextFieldTheme:self.theme.textFieldTheme
				  forTextFieldAtIndex:self.textfields.count - 1];
		UITextField *textField = [self.textfields lastObject];
		textField.secureTextEntry = YES;
		[textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	}
	
	if (self.visible && (alertViewStyle != DLAVAlertViewStyleDefault)) {
		[self.textfields[oldTextFieldCount] becomeFirstResponder];
	}
	
	[self removeTextFieldsInRange:NSMakeRange(0, oldTextFieldCount)];
	
	[self updateFirstOtherButtonEnabledWithCurrentTextField:nil];
}

- (void)setAlertViewStyle:(DLAVAlertViewStyle)alertViewStyle {
	_alertViewStyle = alertViewStyle;
	[self updateTextFieldsForAlertViewStyle:alertViewStyle];
}

- (NSInteger)numberOfButtons  {
	return self.buttons.count;
}

- (NSInteger)firstOtherButtonIndex  {
	if (self.buttons.count == 1) {
		return (self.cancelButtonIndex == -1) ? 0 : -1;
	}
	
	return 1;
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
		[self addSubview:contentView];
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
	self.theme = theme;
	CGFloat duration = ((animated) ? DLAVAlertViewThemeChangeDuration : 0.0);
	[UIView animateWithDuration:duration animations:^{
		self.backgroundColor = theme.backgroundColor;
		self.layer.cornerRadius = theme.cornerRadius;
		self.layer.borderColor = theme.borderColor.CGColor;
		self.layer.borderWidth = theme.borderWidth;
		self.titleLabel.textColor = theme.titleColor;
		self.titleLabel.font = theme.titleFont;
		self.messageLabel.textColor = theme.messageColor;
		self.messageLabel.font = theme.messageFont;
		[self.lines enumerateObjectsUsingBlock:^(UIView *line, NSUInteger index, BOOL *stop) {
			line.backgroundColor = theme.lineColor;
		}];
		DLAVAlertViewTextFieldTheme *defaultTextFieldTheme = theme.textFieldTheme;
		[self.textfields enumerateObjectsUsingBlock:^(UITextField *textfield, NSUInteger index, BOOL *stop) {
			DLAVAlertViewTextFieldTheme *textFieldTheme = self.textFieldThemes[index];
			
			if ([textFieldTheme isKindOfClass:[NSNull class]]) {
				textFieldTheme = defaultTextFieldTheme;
			}
			
			[[self class] applyTheme:textFieldTheme toTextField:textfield animated:animated];
		}];
		DLAVAlertViewButtonTheme *defaultButtonTheme = theme.buttonTheme;
		[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger index, BOOL *stop) {
			DLAVAlertViewButtonTheme *buttonTheme = self.buttonThemes[index];
			
			if ([buttonTheme isKindOfClass:[NSNull class]]) {
				buttonTheme = defaultButtonTheme;
			}
			
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
		textfield.textAlignment = theme.textAlignment;
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
	}];
}

#pragma mark - Button State Handling

- (void)setBackgroundColorForButton:(UIButton *)button {
	DLAVAlertViewButtonTheme *theme = self.buttonThemes[button.tag];
	
	if ([theme isKindOfClass:[NSNull class]]) {
		theme = self.theme.buttonTheme;
	}
	
	button.backgroundColor = theme.backgroundColor;
}

- (void)setHighlightBackgroundColorForButton:(UIButton *)button {
	DLAVAlertViewButtonTheme *theme = self.buttonThemes[button.tag];
	
	if ([theme isKindOfClass:[NSNull class]]) {
		theme = self.theme.buttonTheme;
	}
	
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
	
	[self showAnimated:YES withCompletion:^{
		[self didShowOrUnhide];
		
		if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
			[self.delegate didPresentAlertView:self];
		}
	}];
}

- (void)willDismissOrHide {
	if (self.textfields.count) {
		[self removeKeyboardNotificationObservers];
		[self endEditing:YES];
	}
}

- (void)didShowOrUnhide {
	if (self.textfields.count) {
		[self addKeyboardNotificationObservers];
		[self.textfields[0] becomeFirstResponder];
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
	} else if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[self.delegate alertView:self clickedButtonAtIndex:-1];
	}
	
	[self didDismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)dismissWithButton:(UIButton *)sender {
	[self dismissWithClickedButtonIndex:sender.tag animated:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
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
	
	if ((orientation == UIInterfaceOrientationLandscapeRight) ||
		(orientation == UIInterfaceOrientationLandscapeLeft)) {
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
	[self updateFirstOtherButtonEnabledWithCurrentTextField:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (self.visible && (textField.tag + 1 < self.textfields.count)) {
		[[self textFieldAtIndex:textField.tag + 1] becomeFirstResponder];
	}
	
	[textField resignFirstResponder];
	
	BOOL returnEnabled = [self shouldSetFirstOtherButtonEnabled];
	
	if (textField.returnKeyType == UIReturnKeyDone) {
		NSInteger firstOtherButtonIndex = [self firstOtherButtonIndex];
		
		if (returnEnabled && (firstOtherButtonIndex != -1)) {
			[self dismissWithButton:[self buttonAtIndex:firstOtherButtonIndex]];
		}
	}
	
	return returnEnabled;
}

- (void)textFieldDidChange:(UITextField *)textField {
	[self updateFirstOtherButtonEnabledWithCurrentTextField:textField];
}

- (BOOL)shouldSetFirstOtherButtonEnabled {
	NSInteger firstOtherButtonIndex = [self firstOtherButtonIndex];
	
	if (firstOtherButtonIndex == -1) {
		return YES;
	}
	
	if ([self.delegate respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]) {
		return [self.delegate alertViewShouldEnableFirstOtherButton:self];
	} else if (self.alertViewStyle == DLAVAlertViewStyleSecureTextInput) {
		return [self textFieldTextAtIndex:0].length != 0;
	} else if (self.alertViewStyle == DLAVAlertViewStyleLoginAndPasswordInput) {
		return [self textFieldTextAtIndex:0].length != 0 && [self textFieldTextAtIndex:1].length != 0;
	}
	
	return YES;
}

- (void)updateFirstOtherButtonEnabledWithCurrentTextField:(UITextField *)textField {
	if (!self.textfields.count) {
		return;
	}
	
	NSInteger firstOtherButtonIndex = [self firstOtherButtonIndex];
	
	if (firstOtherButtonIndex == -1) {
		return;
	}
	
	UIButton *button = [self buttonAtIndex:firstOtherButtonIndex];
	button.enabled = [self shouldSetFirstOtherButtonEnabled];
}

#pragma mark - View Layout

- (void)layoutSubviews  {
	CGFloat alertWidth = [self alertWidth];
	CGFloat alertHeight = DLAVAlertViewContentMargin;
	
	BOOL animationsEnabled = [UIView areAnimationsEnabled];
	
	[UIView setAnimationsEnabled:NO];
	
	// Layout title:
	if (self.title && self.titleLabel) {
		CGFloat titleHeight = [self titleHeight];
		self.titleLabel.frame = CGRectMake(DLAVAlertViewContentMargin, alertHeight, alertWidth - DLAVAlertViewContentMargin * 2, titleHeight);
		alertHeight += titleHeight + DLAVAlertViewVerticalSpacing;
	}
	
	// Layout message:
	if (self.message && self.messageLabel) {
		self.messageLabel.hidden = NO;
		CGFloat messageHeight = [self messageHeight];
		self.messageLabel.frame = CGRectMake(DLAVAlertViewContentMargin, alertHeight, alertWidth - DLAVAlertViewContentMargin * 2, messageHeight);
		alertHeight += messageHeight + DLAVAlertViewVerticalSpacing;
	} else {
		self.messageLabel.hidden = YES;
	}
	
	// Layout content view:
	if (self.contentView) {
		UIView *contentView = self.contentView;
		CGFloat contentViewHeight = contentView.frame.size.height;
		contentView.frame = CGRectMake(0.0, alertHeight, MIN(alertWidth, contentView.frame.size.width), contentViewHeight);
		contentView.center = CGPointMake(alertWidth / 2, contentView.center.y);
		alertHeight += contentViewHeight + DLAVAlertViewVerticalSpacing;
	}
	
	NSUInteger lineIndex = 0;
	
	if (self.textfields.count) {
		CGFloat textfieldHeight = [self textFieldHeight];
		
		for (UITextField *textfield in self.textfields) {
			
			// Layout line:
			CGFloat lineHeight = [self lineWidth];
			UIView *horizontalLine = self.lines[lineIndex++];
			horizontalLine.frame = CGRectMake(0.0, alertHeight, alertWidth, lineHeight);
			alertHeight += lineHeight;
			
			// Layout textfield:
			textfield.frame = CGRectMake(DLAVAlertViewContentMargin, alertHeight, alertWidth - DLAVAlertViewContentMargin * 2, textfieldHeight);
			
			alertHeight += textfieldHeight;
		}
	}
	
	if (self.buttons.count) {
		// Layout buttons:
		CGFloat buttonHeight = [self buttonHeight];
		
		if (self.buttons.count == 2) {
			// Layout line:
			CGFloat lineHeight = [self lineWidth];
			UIView *horizontalLine = self.lines[lineIndex++];
			horizontalLine.frame = CGRectMake(0.0, alertHeight, alertWidth, lineHeight);
			alertHeight += lineHeight;
			
			// Layout left button:
			CGFloat halfWidth = alertWidth / 2;
			UIButton *leftButton = self.buttons[0];
			leftButton.frame = CGRectMake(0.0, alertHeight, halfWidth, buttonHeight);
			
			// Layout line:
			CGFloat lineWidth = [self lineWidth];
			UIView *verticalLine = self.lines[lineIndex++];
			verticalLine.frame = CGRectMake(halfWidth, alertHeight, lineWidth, buttonHeight);
			
			// Layout right button:
			UIButton *rightButton = self.buttons[1];
			rightButton.frame = CGRectMake(halfWidth, alertHeight, halfWidth, buttonHeight);
			
			alertHeight += buttonHeight;
		} else {
			for (UIButton *button in self.buttons) {
				// Layout line:
				CGFloat lineHeight = [self lineWidth];
				UIView *line = self.lines[lineIndex++];
				line.frame = CGRectMake(0.0, alertHeight, alertWidth, lineHeight);
				alertHeight += lineHeight;
				// Layout button:
				button.frame = CGRectMake(0.0, alertHeight, alertWidth, buttonHeight);
				alertHeight += buttonHeight;
			}
		}
	}
	
	[UIView setAnimationsEnabled:animationsEnabled];
}

- (CGFloat)animationDuration {
	return (self.visible) ? DLAVAlertViewAnimationDuration : 0.0;
}

- (CGFloat)alertWidth  {
	CGFloat width = 0.0;
	CGSize maxContentSize = CGSizeMake(CGFLOAT_MAX, [self maxContentWidth]);
	
	width = MAX(width, [[self class] optimalSizeForLabel:self.titleLabel inMaxSize:maxContentSize].width);
	width = MAX(width, [[self class] optimalSizeForLabel:self.messageLabel inMaxSize:maxContentSize].width);
	width = MAX(width, self.contentView.bounds.size.width);
	
	if (self.buttons.count == 2) {
		CGFloat leftWidth = [[self class] optimalSizeForLabel:[self buttonAtIndex:0].titleLabel inMaxSize:maxContentSize].width;
		CGFloat rightWidth = [[self class] optimalSizeForLabel:[self buttonAtIndex:1].titleLabel inMaxSize:maxContentSize].width;
		width = MAX(width, leftWidth + rightWidth);
	} else {
		for (UIButton *button in self.buttons) {
			width = MAX(width, [[self class] optimalSizeForLabel:button.titleLabel inMaxSize:maxContentSize].width);
		}
	}
	
	width = MIN(width, [self maxContentWidth]);
	width = MAX(width, [self minContentWidth]);
	
	return width + (2 * DLAVAlertViewContentMargin);
}

- (CGFloat)alertHeight  {
	CGFloat height = DLAVAlertViewContentMargin * 2;
	
	// Title height:
	height += [self titleHeight];
	
	// Message height:
	if (self.message) {
		height += [self messageHeight];
		height += (self.messageLabel) ? DLAVAlertViewVerticalSpacing : 0.0;
	}
	
	// Content view height:
	if (self.contentView) {
		height += [self contentViewHeight];
		height += (self.contentView) ? DLAVAlertViewVerticalSpacing : 0.0;
	}
	
	// Textfield heights:
	if (self.textfields.count) {
		NSUInteger textfieldCount = self.textfields.count;
		height += textfieldCount * [self lineWidth];
		height += textfieldCount * [self textFieldHeight];
	}
	
	// Button heights:
	NSUInteger buttonCount = self.buttons.count;
	
	if (buttonCount == 2) {
		height += [self lineWidth];
		height += [self buttonHeight];
	} else {
		height += buttonCount * [self lineWidth];
		height += buttonCount * [self buttonHeight];
	}
	
	return height;
}

- (CGSize)preferredFrameSize  {
	return CGSizeMake([self alertWidth], [self alertHeight]);
}

- (CGFloat)titleHeight  {
	return [[self class] optimalSizeForLabel:self.titleLabel inMaxSize:CGSizeMake([self alertWidth], [self maxContentWidth])].height;
}

- (CGFloat)messageHeight  {
	return (self.messageLabel) ? [[self class] optimalSizeForLabel:self.messageLabel inMaxSize:CGSizeMake([self alertWidth], [self maxContentWidth])].height : 0.0;
}

- (CGFloat)lineWidth  {
	return 0.5;
}

- (CGFloat)contentViewHeight  {
	return self.contentView.bounds.size.height;
}

- (CGFloat)textFieldHeight  {
	return 30.0;
}

- (CGFloat)buttonHeight  {
	return 44.0;
}

+ (CGSize)optimalSizeForLabel:(UILabel *)label inMaxSize:(CGSize)maxSize {
	CGSize size = CGSizeMake(0.0, 0.0);
	
	if (!label.text) {
		return size;
	}
	
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		size = [label.text sizeWithFont:label.font
					  constrainedToSize:maxSize
						  lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
	} else {
		NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
		context.minimumScaleFactor = 1.0;
		size = [label.text boundingRectWithSize:maxSize
										options:NSStringDrawingUsesLineFragmentOrigin
									 attributes:@{ NSFontAttributeName : label.font }
										context:context].size;
	}
	
	return size;
}

- (void)positionInRect:(CGRect)rect {
	[self updateFrameWithAnimationOfDuration:0.0];
}

- (void)updateFrameWithAnimationOfDuration:(NSTimeInterval)duration {
	[self updateBoundsWithAnimationOfDuration:duration];
	[self updateCenterWithAnimationOfDuration:duration];
}

- (void)updateBoundsWithAnimationOfDuration:(NSTimeInterval)duration {
	[UIView animateWithDuration:duration animations:^{
		CGSize size = [self preferredFrameSize];
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
	
	if ((orientation == UIInterfaceOrientationLandscapeRight) ||
		(orientation == UIInterfaceOrientationLandscapeLeft)) {
		CGRect temp = CGRectZero;
		temp.size.width = fullScreenRect.size.height;
		temp.size.height = fullScreenRect.size.width;
		fullScreenRect = temp;
	}
	
	return fullScreenRect;
}

@end
