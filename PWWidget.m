//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidget.h"
#import "PWController.h"
#import "PWView.h"
#import "PWContainerView.h"
#import "PWWidgetPlistParser.h"
#import "PWTheme.h"
#import "PWThemePlistParser.h"
#import "PWWidgetItem.h"
#import "PWWidgetItemCell.h"
#import "PWAlertView.h"
#import "PWContentItemViewController.h"
#import "PWContentViewControllerDelegate.h"

@implementation PWWidget

//////////////////////////////////////////////////////////////////////

/**
 * Widget initialization
 **/

- (instancetype)init {
	if ((self = [super init])) {
		
		_navigationController = [UINavigationController new];
		_navigationController.edgesForExtendedLayout = UIRectEdgeNone;
		_navigationController.automaticallyAdjustsScrollViewInsets = NO;
		_navigationController.delegate = self;
		_navigationController.builtinTransitionStyle = 1; // set this to non-zero to avoid "layers" in transition
		_navigationController.builtinTransitionGap = 0.0;
		_navigationController.interactiveTransition = NO;
		_navigationController.interactivePopGestureRecognizer.enabled = NO; // just disable the 'pan' gesture to pop view controller
		
		// retrieve navigation bar
		UINavigationBar *navigationBar = _navigationController.navigationBar;
		navigationBar.translucent = NO;
		
		// default settings
		_layout = PWWidgetLayoutCustom;
	}
	return self;
}

- (void)load {
	LOG(@"PWWidget: Load widget (%@)", self);
	[self loadWidgetPlist:[self name]];
}

- (void)preparePresentation {
	
	// block any further changes of some configurations
	_isPresenting = YES;
	
	// if default layout is set, then auto create a content item view controller
	if (_layout == PWWidgetLayoutDefault) {
		
		// create a content item view controller
		PWContentItemViewController *controller = [PWContentItemViewController new];
		controller.shouldAutoConfigureStandardButtons = YES;
		
		// load item view controller plist
		if (self.defaultItemViewControllerPlist != nil) {
			[controller loadPlist:self.defaultItemViewControllerPlist];
		}
		
		// set event handlers
		[controller setItemValueChangedEventHandler:self selector:@selector(itemValueChangedEventHandler:oldValue:)];
		[controller setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
		
		// push it onto navigation stack
		_defaultItemViewController = controller;
		[self pushViewController:controller animated:NO];
	}
}

- (UIViewController *)topViewController {
	return _navigationController.topViewController;
}

//////////////////////////////////////////////////////////////////////

/**
 * Loader
 **/

- (BOOL)loadWidgetPlist:(NSString *)filename {
	
	LOG(@"PWWidget: Load widget plist named (%@)", filename);
	
	NSString *path = [self _pathOfPlist:filename];
	NSDictionary *dict = [self _loadPlistAtPath:path];
	if (dict == nil) return NO;
	
	[PWWidgetPlistParser parse:dict forWidget:self];
	return YES;
}

- (BOOL)loadThemeNamed:(NSString *)name {
	
	// load theme
	PWTheme *theme = [[PWController sharedInstance] loadThemeNamed:name];
	
	// update reference
	[_widgetTheme release];
	_widgetTheme = [theme retain];
	
	return theme != nil;
}

- (BOOL)loadThemePlist:(NSString *)filename {
	
	LOG(@"PWWidget: loadThemePlist (%@)", filename);
	
	NSString *path = [self _pathOfPlist:filename];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if (dict == nil) return NO;
	
	// parse and load theme
	PWTheme *theme = [PWThemePlistParser parse:dict inBundle:_bundle];
	theme.name = _name;
	
	// update reference
	[_widgetTheme release];
	_widgetTheme = [theme retain];
	
	return YES;
}

- (NSString *)_pathOfPlist:(NSString *)filename {
	
	NSString *basePath = [filename hasPrefix:@"/"] ? @"" : [_bundle bundlePath];
	NSString *name;
	
	if ([[[filename pathExtension] lowercaseString] isEqualToString:@"plist"]) {
		name = [filename stringByDeletingPathExtension]; // remove excess .plist
	} else {
		name = filename;
	}
	
	return [NSString stringWithFormat:@"%@/%@.plist", basePath, name];
}

- (NSDictionary *)_loadPlistAtPath:(NSString *)path {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		LOG(@"PWWidget: Unable to load plist at %@. Reason: File does not exist", path);
		return nil;
	}
	
	return [NSDictionary dictionaryWithContentsOfFile:path];
}

//////////////////////////////////////////////////////////////////////

/**
 * Property Getters and Setters
 **/

- (void)setLayout:(PWWidgetLayout)layout {
	if (_isPresenting) return [self _throwSetterError:@"layout"];
	_layout = layout;
}

- (void)setPreferredTintColor:(UIColor *)tintColor {
	if (_isPresenting) return [self _throwSetterError:@"preferred tint color"];
	[_preferredTintColor release];
	_preferredTintColor = [tintColor copy];
}

- (void)setPreferredBarTextColor:(UIColor *)tintColor {
	if (_isPresenting) return [self _throwSetterError:@"preferred bar text color"];
	[_preferredBarTextColor release];
	_preferredBarTextColor = [tintColor copy];
}

//////////////////////////////////////////////////////////////////////

/**
 * Helper methods
 * Public API
 **/

- (BOOL)minimize {
	return [[PWController sharedInstance] _minimizeWidget];
}

- (BOOL)maximize {
	return [[PWController sharedInstance] _maximizeWidget];
}

- (BOOL)dismiss {
	if ([PWController sharedInstance].isAnimating) {
		[PWController sharedInstance].pendingDismissalRequest = YES;
		return YES;
	} else {
		return [[PWController sharedInstance] _dismissWidget];
	}
}

- (PWTheme *)theme {
	return [PWController activeTheme];
}

- (UIImage *)imageNamed:(NSString *)name {
	return [UIImage imageNamed:name inBundle:_bundle];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	if (self.topViewController == nil) animated = NO;
	[_navigationController setViewControllers:viewControllers animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController {
	[self pushViewController:viewController animated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	if (![viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)]) {
		LOG(@"PWWidget: Unable to push view controller (%@). Reason: view controller must conform to PWContentViewControllerDelegate protocol.", viewController);
		return;
	}
	
	if (self.topViewController == nil) animated = NO;
	[_navigationController pushViewController:viewController animated:animated];
}

- (void)popViewController {
	[self popViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
	[_navigationController popViewControllerAnimated:animated];
}

- (void)resizeWidgetAnimated:(BOOL)animated forContentViewController:(id<PWContentViewControllerDelegate>)viewController {
	if (_isPresenting) {
		
		if (viewController == nil || self.topViewController != viewController) {
			LOG(@"PWWidget: Fail to resize widget. Reason: The requestor (content view controller) is not the top view controller.");
			return;
		}
		
		PWView *mainView = [PWController sharedInstance].mainView;
		[mainView _resizeWidgetAnimated:animated];
	}
}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to receive notifications
 * from PWController
 *
 * Do nothing by default
 **/

- (void)willPresent {}
- (void)didPresent {}

- (void)willDismiss {}
- (void)didDismiss {}

- (void)keyboardWillShow:(CGFloat)height {}
- (void)keyboardWillHide {}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {}
- (void)submitEventHandler:(NSDictionary *)values {}

//////////////////////////////////////////////////////////////////////

// Widget theme
- (BOOL)_hasWidgetTheme {
	return _widgetTheme != nil;
}

- (PWTheme *)_widgetTheme {
	return _widgetTheme;
}

// helper method to throw an error
- (void)_throwSetterError:(NSString *)name {
	LOG(@"PWWidget: Unable to change configuration (%@) after the widget is presented.", name);
}

//////////////////////////////////////////////////////////////////////

/**
 * UINavigationControllerDelegate
 **/

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	// fix weird bug in iOS 7
	UINavigationBar *navigationBar = navigationController.navigationBar;
	CGRect rect = navigationBar.frame;
	rect.origin.y = 0.0;
	navigationBar.frame = rect;
	[navigationBar.layer removeAllAnimations];
	
	// call internal method
	if ([viewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *contentViewController = (PWContentViewController *)viewController;
		[contentViewController _willBePresentedInNavigationController:navigationController];
	}
	
	if ([viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)]) {
		
		id<PWContentViewControllerDelegate> contentViewController = (id<PWContentViewControllerDelegate>)viewController;
		
		// auto resize
		if (![PWController sharedInstance].isAnimating)
			[self resizeWidgetAnimated:YES forContentViewController:contentViewController];
		
		// delegate method
		if ([contentViewController respondsToSelector:@selector(willBePresentedInNavigationController:)])
			[contentViewController willBePresentedInNavigationController:navigationController];
	}
	
	// auto set first responder
	// only set in this method when the widget is opening up
	if ([PWController sharedInstance].isAnimating && [viewController respondsToSelector:@selector(configureFirstResponder)]) {
		[viewController performSelector:@selector(configureFirstResponder)];
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	// make title tappable
	UINavigationBar *navigationBar = navigationController.navigationBar;
	UIView *titleView = *(UIView **)instanceVar(navigationBar, "_titleView");
	titleView.userInteractionEnabled = YES;
	
	// call internal method
	if ([viewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *contentViewController = (PWContentViewController *)viewController;
		[contentViewController _presentedInNavigationController:navigationController];
	}
	
	if (titleView != nil && [titleView.gestureRecognizers count] == 0) {
		
		UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleSingleTapped:)] autorelease];
		[titleView addGestureRecognizer:singleTap];
		
		UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleDoubleTapped:)] autorelease];
		doubleTap.numberOfTapsRequired = 2;
		[titleView addGestureRecognizer:doubleTap];
		
		[singleTap requireGestureRecognizerToFail:doubleTap];
	}
	
	// auto set first responder
	if ([viewController respondsToSelector:@selector(configureFirstResponder)]) {
		[viewController performSelector:@selector(configureFirstResponder)];
	}
}

//////////////////////////////////////////////////////////////////////

- (void)titleSingleTapped:(UIGestureRecognizer *)gestureRecognizer {
	if ([self.topViewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *controller = (PWContentViewController *)self.topViewController;
		[controller triggerEvent:[PWContentViewController titleTappedEventName] withObject:gestureRecognizer];
	}
}

- (void)titleDoubleTapped:(UIGestureRecognizer *)gestureRecognizer {
	// minimize widget when double tapped
	[[PWController sharedInstance] _minimizeWidget];
}

- (NSString*) description {
	return [NSString stringWithFormat:@"<%@ %p> Name: %@ / Bundle: %@", [self class], self, _name, _bundle];
}

- (void)_dealloc {
	
	LOG(@"PWWidget: _dealloc");
	
	// ask all pushed view controller to release
	for (id<PWContentViewControllerDelegate> viewController in _navigationController.viewControllers) {
		if ([viewController isKindOfClass:[PWContentViewController class]]) {
			[(PWContentViewController *)viewController _dealloc];
		}
	}
	
	_navigationController.viewControllers = nil;
	
	// release all navigation controller
	RELEASE(_navigationController)
	
	// release widget theme
	RELEASE(_widgetTheme)
	
	// release all configurations
	RELEASE(_title)
	RELEASE(_preferredTintColor)
	RELEASE(_preferredBarTextColor)
	
	// release default item view controller
	RELEASE(_defaultItemViewControllerPlist)
	RELEASE(_defaultItemViewController)
}

- (void)dealloc {
	DEALLOCLOG;
	[self _dealloc];
	[super dealloc];
}

@end