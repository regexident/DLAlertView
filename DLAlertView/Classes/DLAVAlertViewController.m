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

- (void)positionInRect:(CGRect)rect;
- (void)hideWithCompletion:(void (^)(void))completion;
- (void)unhideWithCompletion:(void (^)(void))completion;
- (void)dismissWithBackdropTap;

@end

@interface DLAVAlertViewController () <UITextFieldDelegate>

@property (readwrite, strong, nonatomic) NSMutableArray *alertViews;
@property (readwrite, strong, nonatomic) DLAVAlertView *currentAlertView;

@property (readwrite, strong, nonatomic) UIWindow *mainWindow;
@property (readwrite, strong, nonatomic) UIWindow *alertWindow;
@property (readwrite, strong, nonatomic) UIView *backgroundView;

@property (readwrite, strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (readwrite, assign, nonatomic, getter = isVisible) BOOL visible;

@end

@implementation DLAVAlertViewController

- (id)init {
	self = [super init];
	
	if (self) {
		_mainWindow = [self windowWithLevel:UIWindowLevelNormal];
		_alertWindow = [self windowWithLevel:UIWindowLevelAlert];
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
	_backgroundView.backgroundColor = backdropColor;
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
		self.currentAlertView = previousAlertView;
	}
	
	if (!self.alertViews.count) {
		[self hideBackgroundViewWithCompletion:^(BOOL finished) {
			self.alertWindow.hidden = YES;
			[self.mainWindow makeKeyAndVisible];
		}];
	}
}

#pragma mark - Device Orientation

- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel {
	NSArray *windows = [[UIApplication sharedApplication] windows];
	
	for (UIWindow *window in windows) {
		if (window.windowLevel == windowLevel) {
			return window;
		}
	}
	
	return nil;
}

- (CGRect)frameForOrientation:(UIInterfaceOrientation)orientation {
	CGRect frame;
	
	if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight)) {
		CGRect bounds = [UIScreen mainScreen].bounds;
		frame = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.height, bounds.size.width);
	} else {
		frame = [UIScreen mainScreen].bounds;
	}
	
	return frame;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	CGRect frame = [self frameForOrientation:toInterfaceOrientation];
	self.view.frame = frame;
	self.backgroundView.frame = frame;
	[self.currentAlertView positionInRect:CGRectZero];
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

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

#pragma mark - Device Orientation

- (void)showBackgroundViewWithCompletion:(void (^)(BOOL finished))completion {
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
		[self.mainWindow tintColorDidChange];
	}
	
	[UIView animateWithDuration:0.3 animations:^{
		self.backgroundView.alpha = 1.0;
	} completion:completion];
}

- (void)hideBackgroundViewWithCompletion:(void (^)(BOOL finished))completion {
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
		[self.mainWindow tintColorDidChange];
	}
	
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
