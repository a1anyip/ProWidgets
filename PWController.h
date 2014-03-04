//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWController : UIViewController<SBUIActiveOrientationObserver> {
	
	/////////////////////////////
	///// Runtime variables /////
	/////////////////////////////
	
	BOOL _interfaceOrientationIsLocked;
	UIInterfaceOrientation _lockedInterfaceOrientation;
	BOOL _configured;
	BOOL _pendingDismissalRequest;
	
	// Base Bundle
	// for getting widget path
	NSBundle *_baseBundle;
	
	// Resource Bundle
	NSBundle *_resourceBundle;
	
	UIResponder *_lastFirstResponder;
	
	//////////////////////////
	///// User Interface /////
	//////////////////////////
	
	// Main Window
	PWWindow *_window;
	
	// Main View
	PWView *_mainView;
	
	//////////////////////
	///// Preference /////
	//////////////////////
	BOOL _enabledParallax;
	NSUInteger _preferredSource;
	BOOL _testMode;
	NSArray *_visibleWidgetOrder;
	NSArray *_hiddenWidgetOrder;
	NSString *_defaultThemeName;
	
	////////////////////////////
	///// Presented widget /////
	////////////////////////////
	
	// indicator of whether a widget is opened
	BOOL _isPresenting;
	
	// indicator of whether a widget is being opened (during animation)
	BOOL _isAnimating;
	
	// indicator of whether a widget is minimized
	BOOL _isMinimized;
	
	// current widget
	// keep a reference to the currently opened widget
	PWWidget *_presentedWidget;
	
	// Pending widget
	BOOL _hasPendingWidget;
	PWWidget *_pendingWidget;
	NSDictionary *_pendingUserInfo;
	
	/////////////////
	///// Theme /////
	/////////////////
	BOOL _loadedDefaultTheme;
	NSString *_cachedDefaultThemeTheme;
	PWTheme *_cachedDefaultTheme; // only save defualt theme
	
	/////////////////////////
	///// Private stuff /////
	/////////////////////////
	NSDate *_initialTime;
}

@property(nonatomic, readonly) NSBundle *baseBundle;
@property(nonatomic, readonly) NSBundle *resourceBundle;

@property(nonatomic, readonly) PWWindow *window;
@property(nonatomic, readonly) PWView *mainView;
@property(nonatomic, readonly) PWBackgroundView *backgroundView;
@property(nonatomic, readonly) PWContainerView *containerView;

@property(nonatomic, readonly) BOOL isPresenting;
@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic, readonly) BOOL isMinimized;
@property(nonatomic) BOOL pendingDismissalRequest;

// Preference
@property(nonatomic, readonly) BOOL enabledParallax;
@property(nonatomic, readonly) NSUInteger preferredSource; // 0 is iCloud, 1 is Local
@property(nonatomic, readonly) BOOL testMode;
@property(nonatomic, readonly) NSArray *visibleWidgetOrder;
@property(nonatomic, readonly) NSArray *hiddenWidgetOrder;
@property(nonatomic, readonly) NSString *defaultThemeName;

//////////////////////////////////////////////////////////////////////

/**
 * Singleton accessor
 **/

+ (instancetype)sharedInstance;

//////////////////////////////////////////////////////////////////////

/**
 * Getters
 **/

+ (BOOL)protectedDataAvailable;
+ (int)version;
+ (NSBundle *)baseBundle;
+ (NSString *)basePath;

+ (BOOL)isIPad;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;

// retrieve current orientation (either portrait or landscape)
+ (PWWidgetOrientation)currentOrientation;
- (PWWidgetOrientation)currentOrientation;

// retrieve current interface orientation (four orientations)
+ (UIInterfaceOrientation)currentInterfaceOrientation;
- (UIInterfaceOrientation)currentInterfaceOrientation;

- (CGFloat)availableWidthInOrientation:(PWWidgetOrientation)orientation;
- (CGFloat)availableHeightInOrientation:(PWWidgetOrientation)orientation withKeyboard:(BOOL)withKeyboard;
- (CGFloat)heightOfNavigationBarInOrientation:(PWWidgetOrientation)orientation;
- (CGFloat)defaultHeightOfKeyboardInOrientation:(PWWidgetOrientation)orientation;

- (UIImage *)imageResourceNamed:(NSString *)name;

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/
- (void)configure;
- (void)_constructUI;

/**
 * Preference loader
 **/
- (void)_loadPreference;
- (void)_reloadPreference;

/**
 * Notification handlers
 **/
- (void)_presentWidgetHandler:(NSNotification *)notification;
- (void)_dismissWidgetHandler:(NSNotification *)notification;

//////////////////////////////////////////////////////////////////////

/**
 * General bundle loaders
 **/

- (NSBundle *)_bundleNamed:(NSString *)name ofType:(NSString *)type;

//////////////////////////////////////////////////////////////////////

/**
 * Theme
 **/

// Retrieve active theme
+ (PWTheme *)activeTheme;
- (PWTheme *)activeTheme;

- (NSString *)defaultThemeName;

- (PWTheme *)loadDefaultTheme;
- (PWTheme *)reloadDefaultTheme;
- (PWTheme *)loadThemeNamed:(NSString *)name;

//////////////////////////////////////////////////////////////////////

/**
 * Widget
 **/

// Retrieve active widget
+ (PWWidget *)activeWidget;
- (PWWidget *)activeWidget;

// Widget loaders
- (NSBundle *)_bundleForWidgetNamed:(NSString *)name;
- (PWWidget *)_createWidgetFromBundle:(NSBundle *)bundle;
- (PWWidget *)_createWidgetNamed:(NSString *)name;

// Present or dismiss widget
- (BOOL)_presentWidget:(PWWidget *)widget userInfo:(NSDictionary *)userInfo;
- (BOOL)_dismissWidget;
- (BOOL)_dismissMinimizedWidget;

// Minimization
- (BOOL)_minimizeWidget;
- (BOOL)_maximizeWidget;

//////////////////////////////////////////////////////////////////////

/**
 * Script
 **/

// Widget loaders
- (NSBundle *)_bundleForScriptNamed:(NSString *)name;
- (PWScript *)_createScriptFromBundle:(NSBundle *)bundle;
- (PWScript *)_createScriptNamed:(NSString *)name;

// Execute script (async)
- (BOOL)_executeScript:(PWScript *)script userInfo:(NSDictionary *)userInfo;

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

// widget
- (BOOL)presentWidget:(PWWidget *)widget userInfo:(NSDictionary *)userInfo;
- (BOOL)presentWidgetNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (BOOL)presentWidgetFromBundle:(NSBundle *)bundle userInfo:(NSDictionary *)userInfo;

- (BOOL)dismissWidget;

- (BOOL)minimizeWidget;
- (BOOL)maximizeWidget;

// script
- (BOOL)executeScript:(PWScript *)script userInfo:(NSDictionary *)userInfo;
- (BOOL)executeScriptNamed:(NSString *)name userInfo:(NSDictionary *)userInfo;
- (BOOL)executeScriptFromBundle:(NSBundle *)bundle userInfo:(NSDictionary *)userInfo;

// widget
- (NSDictionary *)infoOfWidgetNamed:(NSString *)name;
- (NSDictionary *)infoOfWidgetInBundle:(NSBundle *)bundle;
- (NSDictionary *)infoOfEnabledWidgetInBundle:(NSBundle *)bundle;

// script
- (NSDictionary *)infoOfScriptNamed:(NSString *)name;
- (NSDictionary *)infoOfScriptInBundle:(NSBundle *)bundle;

// theme
- (NSDictionary *)infoOfThemeNamed:(NSString *)name;
- (NSDictionary *)infoOfThemeInBundle:(NSBundle *)bundle;

// activation method
- (NSDictionary *)infoOfActivationMethodInBundle:(NSBundle *)bundle;

- (UIImage *)iconOfWidgetNamed:(NSString *)name;
- (UIImage *)iconOfWidgetInBundle:(NSBundle *)bundle;
- (UIImage *)iconOfThemeNamed:(NSString *)name;
- (UIImage *)iconOfThemeInBundle:(NSBundle *)bundle;

- (UIImage *)maskOfWidgetNamed:(NSString *)name;
- (UIImage *)maskOfWidgetInBundle:(NSBundle *)bundle;

- (NSArray *)installedWidgets;
- (NSDictionary *)enabledWidgets;
- (NSArray *)visibleWidgets; // visible widgets in Activation Methods
- (NSArray *)hiddenWidgets; // hidden widgets in Activation Methods
- (NSArray *)installedScripts;
- (NSArray *)installedThemes;
- (NSArray *)activationMethods;

//////////////////////////////////////////////////////////////////////

/**
 * Private methods
 **/

+ (BOOL)_shouldDisableLockScreenIdleTimer;

- (void)_manuallyDismissWidget;
- (void)_showProtectedDataUnavailable:(PWWidget *)widget presented:(BOOL)presented;

- (void)_recordInitialTime;
- (void)_outputDuration;

- (void)_applyParallaxEffect;
- (void)_removeParallaxEffect;

- (NSArray *)_installedBundlesOfType:(NSString *)type infoSelector:(SEL)infoSelector;

@end