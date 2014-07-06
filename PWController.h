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
	
	BOOL _showingWelcomeScreen;
	
	BOOL _interfaceOrientationIsLocked;
	UIInterfaceOrientation _lockedInterfaceOrientation;
	
	UIInterfaceOrientation _lastWillChangeToOrientation;
	UIInterfaceOrientation _lastDidChangeToOrientation;
	
	// Base Bundle
	// for getting widget path
	NSBundle *_baseBundle;
	
	// Localization Bundle
	NSBundle *_localizationBundle;
	NSArray *_localizations;
	NSMutableDictionary *_cachedCommonLocalizations;
	
	// Resource Bundle
	NSBundle *_resourceBundle;
	
	UIResponder *_lastFirstResponder;
	
	//////////////////////////
	///// User Interface /////
	//////////////////////////
	
	// Welcome Screen
	PWWSWindow *_welcomeScreen;
	
	// Main Window
	PWWindow *_window;
	
	// Main View
	PWView *_mainView;
	
	//////////////////////
	///// Preference /////
	//////////////////////
	
	NSArray *_visibleWidgetOrder;
	NSArray *_hiddenWidgetOrder;
	NSString *_defaultThemeName;
	
	// Welcome Screen
	BOOL _showedWelcomeScreen;
	
	// General
	PWLockAction _lockAction;
	CGFloat _miniViewScale;
	
	// Effect
	PWWidgetPresentationStyle _presentationStyle;
	BOOL _enabledParallax;
	BOOL _disabledBlur;
	BOOL _disabledMask;
	
	// Global Preference
	NSUInteger _preferredSource;
	
	// Others
	BOOL _testMode;
	
	// Pending widget
	BOOL _hasPendingWidget;
	PWWidget *_pendingWidget;
	NSDictionary *_pendingUserInfo;
	
	/////////////////////////
	///// Private stuff /////
	/////////////////////////
	NSDate *_initialTime;
}

@property(nonatomic, assign) BOOL interfaceOrientationIsLocked;
@property(nonatomic, assign) UIInterfaceOrientation lockedInterfaceOrientation;

@property(nonatomic, readonly) NSBundle *baseBundle;
@property(nonatomic, readonly) NSBundle *localizationBundle;
@property(nonatomic, readonly) NSBundle *resourceBundle;

@property(nonatomic, readonly) PWWindow *window;
@property(nonatomic, readonly) PWView *mainView;
@property(nonatomic, readonly) PWBackgroundView *backgroundView;

// Preference
@property(nonatomic, readonly) NSArray *visibleWidgetOrder;
@property(nonatomic, readonly) NSArray *hiddenWidgetOrder;
@property(nonatomic, readonly) NSString *defaultThemeName;
@property(nonatomic, readonly) PWWidgetPresentationStyle presentationStyle;
@property(nonatomic, readonly) NSUInteger preferredSource; // 0 is iCloud, 1 is Local

//////////////////////////////////////////////////////////////////////

/**
 * Singleton accessor
 **/

+ (instancetype)sharedInstance;

//////////////////////////////////////////////////////////////////////

/**
 * Bundle loaders
 **/

+ (NSBundle *)bundleNamed:(NSString *)name ofType:(NSString *)type extension:(NSString *)extension;
+ (NSBundle *)widgetBundleNamed:(NSString *)name;
+ (NSBundle *)scriptBundleNamed:(NSString *)name;
+ (NSBundle *)themeBundleNamed:(NSString *)name;
+ (NSBundle *)activationMethodBundleNamed:(NSString *)name;

//////////////////////////////////////////////////////////////////////

+ (BOOL)shouldShowBackgroundView;
+ (BOOL)shouldMaskBackgroundView;
+ (BOOL)shouldMinimizeAllControllersAutomatically;
+ (BOOL)supportsDragging;
+ (BOOL)supportsMultipleWidgetsOnScreen;

+ (BOOL)protectedDataAvailable;
+ (NSString *)deviceModel;
+ (int)version;
+ (NSBundle *)baseBundle;
+ (NSString *)basePath;
+ (NSBundle *)localizationBundle;

+ (BOOL)isIPad;
+ (BOOL)isPortrait;
+ (BOOL)isLandscape;

// retrieve current orientation (either portrait or landscape)
+ (PWWidgetOrientation)currentOrientation;
- (PWWidgetOrientation)currentOrientation;

// retrieve current interface orientation (four orientations)
+ (UIInterfaceOrientation)currentInterfaceOrientation;
- (UIInterfaceOrientation)currentInterfaceOrientation;

- (CGFloat)availableWidthInOrientation:(PWWidgetOrientation)orientation fullscreen:(BOOL)fullscreen;
- (CGFloat)availableHeightInOrientation:(PWWidgetOrientation)orientation fullscreen:(BOOL)fullscreen withKeyboard:(BOOL)withKeyboard;
- (CGFloat)heightOfNavigationBarInOrientation:(PWWidgetOrientation)orientation;
- (CGFloat)defaultHeightOfKeyboardInOrientation:(PWWidgetOrientation)orientation;

- (UIImage *)imageResourceNamed:(NSString *)name;
- (NSString *)commonLocalizedStringForPreferences:(NSArray *)preferences key:(NSString *)key;

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

//////////////////////////////////////////////////////////////////////

/**
 * Theme
 **/

- (PWTheme *)loadDefaultThemeForWidget:(PWWidget *)widget;
- (PWTheme *)loadThemeNamed:(NSString *)name forWidget:(PWWidget *)widget;

//////////////////////////////////////////////////////////////////////

/**
 * Script
 **/

// Widget loaders
- (PWScript *)_createScriptFromBundle:(NSBundle *)bundle;
- (PWScript *)_createScriptNamed:(NSString *)name;

// Execute script (async)
- (BOOL)_executeScript:(PWScript *)script userInfo:(NSDictionary *)userInfo;

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

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
- (NSDictionary *)infoOfActivationMethodNamed:(NSString *)name;
- (NSDictionary *)infoOfActivationMethodInBundle:(NSBundle *)bundle;

- (UIImage *)iconOfWidgetNamed:(NSString *)name;
- (UIImage *)iconOfWidgetInBundle:(NSBundle *)bundle;
- (UIImage *)iconOfThemeNamed:(NSString *)name;
- (UIImage *)iconOfThemeInBundle:(NSBundle *)bundle;

- (UIImage *)maskOfWidgetNamed:(NSString *)name;
- (UIImage *)maskOfWidgetInBundle:(NSBundle *)bundle;

- (NSArray *)installedWidgets;
- (NSArray *)enabledWidgets;
- (NSDictionary *)enabledWidgetsWithCategories;
- (NSArray *)visibleWidgets; // visible widgets in Activation Methods
- (NSArray *)hiddenWidgets; // hidden widgets in Activation Methods
- (NSArray *)installedScripts;
- (NSArray *)installedThemes;
- (NSArray *)activationMethods;

//////////////////////////////////////////////////////////////////////

/**
 * Private methods
 **/

+ (BOOL)_checkAPIEnvironment;

- (BOOL)_showingWelcomeScreen;
- (void)_firstTimeShowWelcomeScreen;
- (void)_showWelcomeScreen;
- (void)_hideWelcomeScreen;

- (void)_recordInitialTime;
- (void)_outputDuration;

- (void)_applyParallaxEffect;
- (void)_removeParallaxEffect;

- (NSArray *)_installedBundlesOfType:(NSString *)type extension:(NSString *)extension infoSelector:(SEL)infoSelector;

- (BOOL)_disabledMask;
- (CGFloat)_miniViewScale;

@end