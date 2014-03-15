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
#import "PWWidgetNavigationController.h"

@interface PWWidget : PWBase<UINavigationControllerDelegate, UIGestureRecognizerDelegate> {
	
	PWWidgetController *_widgetController;
	PWWidgetNavigationController *_navigationController;
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
@property(nonatomic, readonly) PWWidgetNavigationController *navigationController;
@property(nonatomic, readonly) PWTheme *theme;

// inherit from PWBase
@property(nonatomic) BOOL requiresProtectedDataAccess;

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

/**
 *  Retrieve the presented instance of the widget.
 *  You must specify the widget class name instead of calling this method from base class
 *
 *  @return The presented widget instance
 */
+ (instancetype)widget;

/**
 *  Retrieve the theme instance associated with the widget.
 *  You must specify the widget class name instead of calling this method from base class
 *
 *  @return The theme instance
 */
+ (PWTheme *)theme;

/**
 *  Override this method to load custom widget or theme plist files.
 */
- (void)configure;

/**
 *  Override this method to set up custom objects for the widget.
 *  You should not override init method to do so.
 */
- (void)load;

- (void)preparePresentation;
- (void)_setConfigured;
- (BOOL)_checkConfigured:(SEL)selector;

/**
 *  Load the widget plist file.
 *  You can only call this method in configure method.
 *
 *  @param The name of the plist file
 *
 *  @return Return YES if the file is successfully loaded; otherwise, NO.
 */
- (BOOL)loadWidgetPlist:(NSString *)filename;

/**
 *  Load a theme with specified theme name or class name.
 *  You can only call this method in configure method.
 *
 *  @param The name of the theme, or the class name of a theme subclass
 *
 *  @return Return YES if the theme is successfully loaded; otherwise, NO.
 */
- (BOOL)loadThemeNamed:(NSString *)name;

/**
 *  Load the theme plist file.
 *  You can only call this method in configure method.
 *
 *  @param The name of the plist file
 *
 *  @return Return YES if the file is successfully loaded; otherwise, NO.
 */
- (BOOL)loadThemePlist:(NSString *)filename;

- (NSString *)_pathOfPlist:(NSString *)filename;
- (NSDictionary *)_loadPlistAtPath:(NSString *)path;

/**
 *  Minimize the widget
 *
 *  @return YES if the widget is minimized; otherwise, NO.
 */
- (BOOL)minimize;

/**
 *  Maximize the widget
 *
 *  @return YES if the widget is maximized; otherwise, NO.
 */
- (BOOL)maximize;

/**
 *  Dismiss the widget
 *
 *  @return YES if the widget is dismissed; otherwise, NO.
 */
- (BOOL)dismiss;

/**
 *  Retrieve the image in the widget bundle
 *
 *  @param name The name of the file.
 *
 *  @return The image object for the specified file, or nil if the method could not find the specified image.
 */
- (UIImage *)imageNamed:(NSString *)name;

/**
 *  Set the navigation stack using the default fade animation.
 *  You may use this method to switch pages like what some built-in widgets do.
 *
 *  @param viewControllers The new navigation stack.
 */
- (void)setViewControllers:(NSArray *)viewControllers;

/**
 *  Set the navigation stack.
 *
 *  @param viewControllers The new navigation stack.
 *  @param animated        If YES, the navigation stack will be updated using a fade animation.
 */
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

/**
 *  Push a view controller to the navigation stack using an animation.
 *
 *  @param viewController The view controller to be pushed onto the navigation stack.
 */
- (void)pushViewController:(UIViewController *)viewController;

/**
 *  Push a view controller to the navigation stack.
 *
 *  @param viewController The view controller to be pushed onto the navigation stack.
 *  @param animated       If YES, the view controller will be pushed using an animation.
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
 *  Pop the top view controller from the navigation stack using an animation.
 */
- (void)popViewController;

/**
 *  Pop the top view controller from the navigation stack.
 *
 *  @param animated If YES, the top view controller will be poped using an animation.
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 *  Explicitly tell the widget to resize or reposition its container view.
 *  Normally this will be called automatically whenever the navigation stack changes.
 *
 *  @param animated       If YES, the container view will be resized using an animation
 *  @param viewController The content view controller to be asked to provide size information, normally the top view controller in navigation stack
 */
- (void)resizeWidgetAnimated:(BOOL)animated forContentViewController:(id<PWContentViewControllerDelegate>)viewController;

/**
 *  Override this method to perform custom tasks when the widget is ready to be presented.
 *  The default implementation does nothing.
 */
- (void)willPresent;

/**
 *  Override this method to perform custom tasks when the widget finishes its presentation and the animation ends.
 *  The default implementation does nothing.
 */
- (void)didPresent;

/**
 *  Override this method to perform custom tasks when the widget is ready to be dismissed.
 *  The default implementation does nothing.
 */
- (void)willDismiss;

/**
 *  Override this method to perform custom tasks when the widget finished its dismissal.
 *  The default implementation does nothing.
 */
- (void)didDismiss;

- (void)keyboardWillShow:(CGFloat)height;
- (void)keyboardWillHide;

/**
 *  Notifies the widget that its user info is changed.
 *
 *  @param userInfo The new user info dictionary.
 */
- (void)userInfoChanged:(NSDictionary *)userInfo;

/**
 *  Notifies the widget that the value of the specified item is changed.
 *  This is the default event handler only for widgets using default layout.
 *  You must register your own event handler if the widget is configured as using a custom layout.
 *
 *  @param item     The item that triggers the item value changed event.
 *  @param oldValue The old value of the specified item.
 */
- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue;

/**
 *  Notifies the widget that the submit action is triggered.
 *  This is the default event handler only for widgets using default layout.
 *  You must register your own event handler if the widget is configured as using a custom layout.
 *
 *  @param values All the item values with their keys in a dictionary form
 */
- (void)submitEventHandler:(NSDictionary *)values;

- (void)_dealloc;

@end