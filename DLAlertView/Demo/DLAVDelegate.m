//
//  DLAVDelegate.m
//  DLAlertView
//
//  Created by Vincent Esche on 01/11/13.
//  Copyright (c) 2013 Vincent Esche. All rights reserved.
//

#import "DLAVDelegate.h"

@implementation DLAVDelegate

#pragma mark - DLAVAlertViewDelegate Protocol

- (void)alertView:(DLAVAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"[DLAVUsecase alertView:%p clickedButtonAtIndex:%ld]", alertView, (long)buttonIndex);
}

- (void)alertViewCancel:(DLAVAlertView *)alertView {
	NSLog(@"[DLAVUsecase alertViewCancel:%p]", alertView);
}

- (void)willPresentAlertView:(DLAVAlertView *)alertView {
	NSLog(@"[DLAVUsecase willPresentAlertView:%p]", alertView);
}

- (void)didPresentAlertView:(DLAVAlertView *)alertView {
	NSLog(@"[DLAVUsecase didPresentAlertView:%p]", alertView);
}

- (void)alertView:(DLAVAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"[DLAVUsecase alertView:%p willDismissWithButtonIndex:%ld]", alertView, (long)buttonIndex);
}

- (void)alertView:(DLAVAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"[DLAVUsecase alertView:%p didDismissWithButtonIndex:%ld]", alertView, (long)buttonIndex);
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(DLAVAlertView *)alertView {
	NSLog(@"[DLAVUsecase alertViewShouldEnableFirstOtherButton:%p]", alertView);
	return YES;
}

- (BOOL)alertView:(DLAVAlertView *)alertView buttonAtIndex:(NSUInteger)buttonIndex shouldBeEnabled:(BOOL)enabled {
	NSLog(@"[DLAVUsecase alertView:%p buttonAtIndex:%ld shouldBeEnabled:%s]", alertView, (long)buttonIndex, (enabled) ? "YES" : "NO");
	return enabled; // simply forwards default behaviour
}

@end
