//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetController : NSObject {
	
	BOOL _isActive;
	BOOL _isAnimating;
	BOOL _isPresented;
	BOOL _isMinimized;
	
	BOOL _pendingDismissalRequest;
	
	BOOL _recordedLastPosition;
	CGPoint _lastPosition;
	
	CGFloat _keyboardHeight;
	
	PWBackgroundView *_backgroundView;
	PWContainerView *_containerView;
	PWMiniView *_miniView;
	
	PWWidget *_widget;
}

@property(nonatomic, readonly) BOOL isActive;
@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic, readonly) BOOL isPresented;
@property(nonatomic, readonly) BOOL isMinimized;

@property(nonatomic, assign) BOOL pendingDismissalRequest;

@property(nonatomic, readonly) PWBackgroundView *backgroundView;
@property(nonatomic, readonly) PWContainerView *containerView;
@property(nonatomic, readonly) PWMiniView *miniView;

@property(nonatomic, readonly) PWWidget *widget;

+ (BOOL)isPresentingWidget;

+ (BOOL)isLocked;
+ (void)lock;
+ (void)releaseLock;

+ (PWWidget *)_createWidgetFromBundle:(NSBundle *)bundle;
+ (PWWidget *)_createWidgetNamed:(NSString *)name;

+ (BOOL)presentWidget:(PWWidget *)widget userInfo:(NSDictionary *)userInfo;
+ (BOOL)presentWidgetNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
+ (BOOL)presentWidgetFromBundle:(NSBundle *)bundle userInfo:(NSDictionary *)userInfo;

+ (NSSet *)allControllers;
+ (instancetype)activeController;
+ (instancetype)controllerForPresentedWidget:(PWWidget *)widget;
+ (instancetype)controllerForPresentedWidgetNamed:(NSString *)name;
+ (instancetype)controllerForPresentedWidgetWithPrincipalClass:(Class)principalClass;

+ (void)updateActiveController:(PWWidgetController *)controller;

- (instancetype)initWithWidget:(PWWidget *)widget;
- (BOOL)_presentWithUserInfo:(NSDictionary *)userInfo;

- (BOOL)dismiss;
- (BOOL)dismissWhenMinimized;
- (void)_forceDismiss;

- (BOOL)minimize;
- (BOOL)maximize;

- (void)makeActive:(BOOL)configureFirstResponder;
- (void)resignActive:(BOOL)makeActive;

// notification handlers
- (void)keyboardWillShowHandler:(CGFloat)height;
- (void)keyboardWillHideHandler;
- (void)protectedDataWillBecomeUnavailableHandler;

// container view
- (PWContainerView *)createContainerView;
- (void)removeContainerView;

// mini view
- (PWMiniView *)createMiniView;
- (void)removeMiniView;
- (CGPoint)getInitialPositionOfMiniView;

// private methods
- (CGRect)_containerBounds;
- (void)_resizeAnimated:(BOOL)animated;
- (void)_showProtectedDataUnavailable:(BOOL)presented;

// gesture recognizer handlers
- (void)handleNavigationBarPan:(UIPanGestureRecognizer *)sender;
- (void)handleMiniViewPan:(UIPanGestureRecognizer *)sender;
- (void)handleMiniViewSingleTap:(UITapGestureRecognizer *)sender;
- (void)handleMiniViewDoubleTap:(UITapGestureRecognizer *)sender;

@end