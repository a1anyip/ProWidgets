//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWBackgroundView.h"

typedef enum {
	ReferenceLineLeft,
	ReferenceLineMiddle,
	ReferenceLineRight
} ReferenceLine;

typedef struct {
	ReferenceLine referenceLine;
	CGFloat referenceValue;
} ReferencePoint;

typedef struct {
	ReferencePoint x;
	ReferencePoint y;
} ReferenceLocation;

@interface PWWidgetController : NSObject {
	
	BOOL _isActive;
	BOOL _isAnimating;
	BOOL _isPresented;
	BOOL _isMinimized;
	
	BOOL _pendingDismissalRequest;
	
	// container view
	BOOL _hasContainerViewLocation;
	ReferenceLocation _containerViewLocation;
	CGFloat _keyboardHeight;
	
	// mini view
	BOOL _hasMiniViewLocation;
	ReferenceLocation _miniViewLocation;
	
	PWBackgroundView *_backgroundView;
	PWContainerView *_containerView;
	PWMiniView *_miniView;
	PWShadowView *_shadowView;
	UIImageView *_resizer;
	
	PWWidget *_widget;
}

@property(nonatomic, readonly) BOOL isActive;
@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic, readonly) BOOL isPresented;
@property(nonatomic, readonly) BOOL isMinimized;

@property(nonatomic, assign) BOOL pendingDismissalRequest;
@property(nonatomic, assign) CGFloat keyboardHeight;

@property(nonatomic, readonly) PWBackgroundView *backgroundView;
@property(nonatomic, readonly) PWContainerView *containerView;
@property(nonatomic, readonly) PWMiniView *miniView;
@property(nonatomic, readonly) PWShadowView *shadowView;
@property(nonatomic, readonly) UIImageView *resizer;

@property(nonatomic, readonly) PWWidget *widget;

+ (BOOL)shouldDisableNotificationCenterPresentation;
+ (BOOL)isDragging;
+ (BOOL)isResizing;
+ (BOOL)isPresentingWidget;
+ (BOOL)isPresentingMaximizedWidget;

+ (void)hideCenter;

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

+ (void)adjustLayoutForAllControllers;
+ (void)dismissAllControllers:(BOOL)force;
+ (void)minimizeAllControllers;
+ (void)updateActiveController:(PWWidgetController *)controller;

- (instancetype)initWithWidget:(PWWidget *)widget;
- (BOOL)_present;

- (BOOL)dismiss;
- (BOOL)dismissWhenMinimized;
- (void)_forceDismiss;

- (BOOL)minimize;
- (BOOL)maximize;

- (void)makeActive:(BOOL)configureFirstResponder;
- (void)resignActive:(BOOL)makeActive;

// container view
- (PWContainerView *)createContainerView;
- (void)removeContainerView;

// mini view
- (PWMiniView *)createMiniView;
- (void)removeMiniView;

// shadow view
- (PWShadowView *)createShadowView;
- (void)removeShadowView;

// adjust layout
- (void)adjustLayout;

// private methods
- (CGPoint)_containerCenterForBounds:(CGRect)bounds;
- (CGRect)_containerBounds;
- (CGPoint)_miniViewCenter;
- (void)_updateBackgroundViewMaskForPresentation;
- (void)_updateBackgroundViewMaskForMaximization;
- (void)_resizeAnimated:(BOOL)animated;
- (void)_resetKeyboardHeight;
- (void)_keyboardWillShowHandler:(CGFloat)height;
- (void)_keyboardWillHideHandler;
- (void)_protectedDataWillBecomeUnavailableHandler;
- (void)_showProtectedDataUnavailable:(BOOL)presented;

// gesture recognizer handlers
- (void)handleNavigationBarPan:(UIPanGestureRecognizer *)sender;
- (void)handleResizerPan:(UIPanGestureRecognizer *)sender;
- (void)handleMiniViewPan:(UIPanGestureRecognizer *)sender;
- (void)handleMiniViewSingleTap:(UITapGestureRecognizer *)sender;
- (void)handleMiniViewDoubleTap:(UITapGestureRecognizer *)sender;

@end