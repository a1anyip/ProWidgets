//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWBase.h"
#import "PWAlertView.h"
#import "PWContentViewControllerDelegate.h"

@interface PWWidget : PWBase<UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
	
	UINavigationController *_navigationController;
	
	BOOL _configured;
	BOOL _configuredGestureRecognizers;
	BOOL _isPresenting;
	
	// inherit from PWBase
	/*NSString *_name;
	NSBundle *_bundle;
	NSDictionary *_info;
	NSDictionary *_userInfo;
	*/
	PWWidgetLayout _layout;
	NSString *_title;
	UIColor *_preferredTintColor;
	UIColor *_preferredBarTextColor;
	
	PWTheme *_widgetTheme;
	
	// inherit from PWBase
	/*
	NSString *_preferencePlistPath;
	NSMutableDictionary *_preferenceDict;
	*/
	// for default layout
	// developers have to push their own view controller in custom layout
	NSString *_defaultItemViewControllerPlist;
	PWContentItemViewController *_defaultItemViewController;
}

@property(nonatomic, readonly) UINavigationController *navigationController;

// inherit from PWBase
@property(nonatomic) BOOL requiresProtectedDataAccess;

// inherit from PWBase
@property(nonatomic, readonly) BOOL isPresenting;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, readonly) NSString *displayName;
@property(nonatomic, retain) NSBundle *bundle;
@property(nonatomic, retain) NSDictionary *info;
@property(nonatomic, retain) NSDictionary *userInfo;

// these four variables can only be changed in loadInfo
@property(nonatomic) PWWidgetLayout layout;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) UIColor *preferredTintColor;
@property(nonatomic, copy) UIColor *preferredBarTextColor;

// inherit from PWBase
@property(nonatomic, readonly) NSString *preferencePlistPath;
@property(nonatomic, readonly) NSMutableDictionary *preferenceDict;

@property(nonatomic, copy) NSString *defaultItemViewControllerPlist;
@property(nonatomic, readonly) PWContentItemViewController *defaultItemViewController;

@property(nonatomic, readonly) id<PWContentViewControllerDelegate> topViewController;

//////////////////////////////////////////////////////////////////////

/**
 * Widget initialization
 **/

- (void)configure;
- (void)load;
- (void)preparePresentation;

- (void)_setConfigured;
- (BOOL)_checkConfigured:(SEL)selector;

//////////////////////////////////////////////////////////////////////

/**
 * Loader
 * Public API
 **/

- (BOOL)loadWidgetPlist:(NSString *)filename;
- (BOOL)loadThemeNamed:(NSString *)name;
- (BOOL)loadThemePlist:(NSString *)filename;
- (NSString *)_pathOfPlist:(NSString *)filename;
- (NSDictionary *)_loadPlistAtPath:(NSString *)path;

//////////////////////////////////////////////////////////////////////

/**
 * Preference
 * Public API
 **/

// Getters
/*
// object types
- (NSString *)stringValueForPreferenceKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayValueForPreferenceKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictionaryValueForPreferenceKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;
- (NSDate *)dateValueForPreferenceKey:(NSString *)key defaultValue:(NSDate *)defaultValue;

// primitive types
- (int)intValueForPreferenceKey:(NSString *)key defaultValue:(int)defaultValue;
- (double)doubleValueForPreferenceKey:(NSString *)key defaultValue:(double)defaultValue;
- (BOOL)boolValueForPreferenceKey:(NSString *)key defaultValue:(BOOL)defaultValue;

// Setter
- (BOOL)setValue:(id)value forPreferenceKey:(NSString *)key;
*/
//////////////////////////////////////////////////////////////////////

/**
 * Miscellaneous methods
 * Public API
 **/

// minimize or maximize widget
- (BOOL)minimize;
- (BOOL)maximize;

// dismiss widget
- (BOOL)dismiss;

// retrieve theme
- (PWTheme *)theme;

// retrieve image in widget bundle
- (UIImage *)imageNamed:(NSString *)name;

// show message in alert view
/*- (void)showMessage:(NSString *)message;
- (void)showMessage:(NSString *)message title:(NSString *)title;

// show message with a text input in alert view
- (void)prompt:(NSString *)message buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion;
- (void)prompt:(NSString *)message title:(NSString *)title buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion;
*/
// modify navigation stack
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)popViewController;
- (void)popViewControllerAnimated:(BOOL)animated;

- (void)resizeWidgetAnimated:(BOOL)animated forContentViewController:(id<PWContentViewControllerDelegate>)viewController;

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to receive notifications
 * from PWController
 *
 * Do nothing by default
 **/

- (void)willPresent;
- (void)didPresent;

- (void)willDismiss;
- (void)didDismiss;

- (void)keyboardWillShow:(CGFloat)height;
- (void)keyboardWillHide;

// these two methods are only for default layout
- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue;
- (void)submitEventHandler:(NSDictionary *)values;

//////////////////////////////////////////////////////////////////////

// Widget theme
- (BOOL)_hasWidgetTheme;
- (PWTheme *)_widgetTheme;

- (void)_dealloc;

@end