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
	
	PWWidgetController *_widgetController;
	UINavigationController *_navigationController;
	PWTheme *_theme;
	
	BOOL _configured;
	BOOL _configuredGestureRecognizers;
	BOOL _isPresenting;
	
	PWWidgetLayout _layout;
	NSString *_title;
	UIColor *_preferredTintColor;
	UIColor *_preferredBarTextColor;
	
	// for default layout
	// developers have to push their own view controller in custom layout
	NSString *_defaultItemViewControllerPlist;
	PWContentItemViewController *_defaultItemViewController;
}

@property(nonatomic, assign) PWWidgetController *widgetController;
@property(nonatomic, readonly) UINavigationController *navigationController;
@property(nonatomic, readonly) PWTheme *theme;

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

+ (instancetype)widget;
+ (PWTheme *)theme;

- (void)configure;
- (void)load;
- (void)preparePresentation;

- (void)_setConfigured;
- (BOOL)_checkConfigured:(SEL)selector;

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

- (BOOL)loadWidgetPlist:(NSString *)filename;
- (BOOL)loadThemeNamed:(NSString *)name;
- (BOOL)loadThemePlist:(NSString *)filename;
- (NSString *)_pathOfPlist:(NSString *)filename;
- (NSDictionary *)_loadPlistAtPath:(NSString *)path;

// minimize or maximize widget
- (BOOL)minimize;
- (BOOL)maximize;

// dismiss widget
- (BOOL)dismiss;

// retrieve image in widget bundle
- (UIImage *)imageNamed:(NSString *)name;

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

- (void)userInfoChanged:(NSDictionary *)userInfo;

// these two methods are only for default layout
- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue;
- (void)submitEventHandler:(NSDictionary *)values;

- (void)_dealloc;

@end