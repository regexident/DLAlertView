//
//  DLAVAlertView.m
//  DLAVAlertView
//
//  Created by Vincent Esche on 31/10/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVAlertViewController.h"

#import "DLAVAlertView.h"

#pragma mark Alert View

@interface DLAVAlertView ()

- (void)updateFrameWithAnimationOfDuration:(NSTimeInterval)duration;
- (void)hideWithCompletion:(void (^)(void))completion;
- (void)unhideWithCompletion:(void (^)(void))completion;
- (void)dismissWithBackdropTap;

@end

@interface DLAVAlertViewController () <UITextFieldDelegate>

@property (readwrite, strong, nonatomic) NSMutableArray *alertViews;
@property (readwrite, strong, nonatomic) DLAVAlertView *currentAlertView;

@property (readwrite, strong, nonatomic) UIWindow *alertWindow;
@property (readwrite, strong, nonatomic) UIView *backgroundView;

@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation DLAVAlertViewController

- (id)init {
	self = [super init];
	
	if (self) {
		_alertWindow = [self firstWindowWithLevel:UIWindowLevelAlert];
		_alertViews = [NSMutableArray array];
		
		if (!_alertWindow) {
			_alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
			_alertWindow.windowLevel = UIWindowLevelAlert;
		}
		
		_alertWindow.rootViewController = self;
		
		CGRect frame = [self frameForOrientation:self.interfaceOrientation];
		self.view.frame = frame;
		
		_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
		[_tapGestureRecognizer setNumberOfTapsRequired:1];
		
		_backgroundView = [[UIView alloc] initWithFrame:frame];
		_backgroundView.backgroundColor = [UIColor clearColor];
		_backgroundView.userInteractionEnabled = YES;
		_backgroundView.multipleTouchEnabled = NO;
		[_backgroundView addGestureRecognizer:_tapGestureRecognizer];
		[self.view addSubview:_backgroundView];
		
	}
	
	return self;
}

+ (instancetype)sharedController {
	static DLAVAlertViewController *sharedController = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedController = [[self alloc] init];
	});
	return sharedController;
}

- (void)setBackdropColor:(UIColor *)backdropColor {
	self.backgroundView.backgroundColor = backdropColor;
}

- (void)addAlertView:(DLAVAlertView *)alertView {
	if (!self.alertViews.count) {
		self.alertWindow.hidden = NO;
		[self.alertWindow addSubview:self.view];
		[self.alertWindow makeKeyAndVisible];
		[self showBackgroundViewWithCompletion:nil];
	}
	
	DLAVAlertView *last = [self.alertViews lastObject];
	
	if (last) {
		[last hideWithCompletion:^{
			[last removeFromSuperview];
		}];
	}
	
	[alertView updateFrameWithAnimationOfDuration:0.0];
	
	[self.alertViews addObject:alertView];
	[self.view addSubview:alertView];
	self.currentAlertView = alertView;
}

- (void)removeAlertView:(DLAVAlertView *)alertView {
	[alertView removeFromSuperview];
	[self.alertViews removeObject:alertView];
	DLAVAlertView *previousAlertView = [self.alertViews lastObject];
	
	if (previousAlertView) {
		[self.view addSubview:previousAlertView];
		[previousAlertView unhideWithCompletion:nil];
	}
	self.currentAlertView = previousAlertView;
	
	if (!self.alertViews.count) {
		[self hideBackgroundViewWithCompletion:^(BOOL finished) {
			if (!self.alertViews.count) {
				self.alertWindow.hidden = YES;
				[[self lastWindowWithLevel:UIWindowLevelNormal] makeKeyAndVisible];
			}
		}];
	}
}

#pragma mark - Windows

- (UIWindow *)firstWindowWithLevel:(UIWindowLevel)windowLevel {
	NSArray *windows = [[UIApplication sharedApplication] windows];
	
	for (UIWindow *window in windows) {
		if (window.windowLevel == windowLevel) {
			return window;
		}
	}
	
	return nil;
}

- (UIWindow *)lastWindowWithLevel:(UIWindowLevel)windowLevel {
	NSArray *windows = [[UIApplication sharedApplication] windows];
	
	for (UIWindow *window in [windows reverseObjectEnumerator]) {
		if (window.windowLevel == windowLevel) {
			return window;
		}
	}
	
	return nil;
}

- (void)windowsWithLevel:(UIWindowLevel)windowLevel block:(void (^)(UIWindow*))block {
	if (!block) {
		return;
	}
	
	NSArray *windows = [[UIApplication sharedApplication] windows];
	
	for (UIWindow *window in windows) {
		if (window.windowLevel == windowLevel) {
			block(window);
		}
	}
}

#pragma mark - Device Orientation

- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation {
	CGRect frame;

	BOOL iOS8 = [[UIDevice currentDevice] systemVersion].floatValue >= 8.0;
	if (!iOS8 && UIInterfaceOrientationIsLandscape(orientation)) {
		CGRect bounds = [UIScreen mainScreen].bounds;
		frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
	} else {
		frame = [UIScreen mainScreen].bounds;
	}
	
	return frame;
}

- (void)updateFrameWithOrientation:(UIInterfaceOrientation)orientation {
	CGRect frame = [self frameForOrientation:orientation];
	self.view.frame = frame;
	self.backgroundView.frame = frame;
	[self.currentAlertView updateFrameWithAnimationOfDuration:0.0];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self updateFrameWithOrientation:toInterfaceOrientation];
	// workaround for UIWindow fading through black during orientation rotation
	self.view.window.alpha = 0.0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	// workaround for UIWindow fading through black during orientation rotation
	self.view.window.alpha = 1.0;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	// iOS 8 equivalent of calling willRotateToInterfaceOrientation
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		[self updateFrameWithOrientation:orientation];
		// workaround for UIWindow fading through black during orientation rotation
		[UIView performWithoutAnimation:^{
			self.view.window.alpha = 0.0;
		}];
	} completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
		// workaround for UIWindow fading through black during orientation rotation
		[UIView performWithoutAnimation:^{
			self.view.window.alpha = 1.0;
		}];
	}];
	[super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)prefersStatusBarHidden {
	return [UIApplication sharedApplication].statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
	return [UIApplication sharedApplication].statusBarStyle;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

#pragma mark - Device Orientation

- (void)showBackgroundViewWithCompletion:(void (^)(BOOL finished))completion {
#if __IPHONE_OS_VERSION_MIN_REQUIRED > 61000
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		[self windowsWithLevel:UIWindowLevelNormal block:^(UIWindow *window) {
			window.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
			[window tintColorDidChange];
		}];
	}
#endif
	
	[UIView animateWithDuration:0.3 animations:^{
		self.backgroundView.alpha = 1.0;
	} completion:completion];
}

- (void)hideBackgroundViewWithCompletion:(void (^)(BOOL finished))completion {
#if __IPHONE_OS_VERSION_MIN_REQUIRED > 61000
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		[self windowsWithLevel:UIWindowLevelNormal block:^(UIWindow *window) {
			window.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
			[window tintColorDidChange];
		}];
	}
#endif
	
	[UIView animateWithDuration:0.3 animations:^{
		self.backgroundView.alpha = 0.0;
	} completion:completion];
}

- (void)dismiss:(UITapGestureRecognizer *)sender {
	if (self.currentAlertView.dismissesOnBackdropTap) {
		[self.currentAlertView dismissWithBackdropTap];
	}
}

@end
