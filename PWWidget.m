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
#import "PWWidgetController.h"
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

#define CHECK_CONFIGURED(x) if (![self _checkConfigured:_cmd]) return x;

@interface UINavigationBar (Private)

- (id)backButtonViewAtPoint:(CGPoint)point;

@end

@implementation PWWidget

+ (instancetype)widget {
	if ([self.class isMemberOfClass:[PWWidget class]]) return nil;
	return [PWWidgetController controllerForPresentedWidgetWithPrincipalClass:self.class].widget;
}

+ (PWTheme *)theme {
	return [self.widget theme];
}

- (instancetype)init {
	if ((self = [super init])) {
		// default settings
		_layout = PWWidgetLayoutDefault;
	}
	return self;
}

- (void)configure {
	LOG(@"PWWidget: Configure widget (%@)", self);
	[self loadWidgetPlist:[self name]];
}

- (void)load {}

- (void)preparePresentation {
	
	_isPresenting = YES;
	
	// if default layout is set, then auto create a content item view controller
	if (_layout == PWWidgetLayoutDefault) {
		
		// create a content item view controller
		PWContentItemViewController *controller = [[PWContentItemViewController alloc] initForWidget:self];
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

- (void)_setConfigured {
	
	// set up navigation controller
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
	
	// load default theme
	if (_theme == nil) {
		_theme = [[[PWController sharedInstance] loadDefaultThemeForWidget:self] retain];
	}
	
	// update flag value
	_configured = YES;
}

- (BOOL)_checkConfigured:(SEL)selector {
	if (_configured) {
		LOG(@"PWWidget: You must call \"%@\" in \"configure\" method.", NSStringFromSelector(selector));
		return NO;
	} else {
		return YES;
	}
}

//////////////////////////////////////////////////////////////////////

- (BOOL)loadWidgetPlist:(NSString *)filename {
	
	CHECK_CONFIGURED(NO);
	
	LOG(@"PWWidget: Load widget plist named (%@)", filename);
	
	NSString *path = [self _pathOfPlist:filename];
	NSDictionary *dict = [self _loadPlistAtPath:path];
	if (dict == nil) return NO;
	
	[PWWidgetPlistParser parse:dict forWidget:self];
	return YES;
}

- (BOOL)loadThemeNamed:(NSString *)name {
	
	CHECK_CONFIGURED(NO);
	
	// load theme
	PWTheme *theme = [[PWController sharedInstance] loadThemeNamed:name forWidget:self];
	
	// update reference
	[_theme release];
	_theme = [theme retain];
	
	return theme != nil;
}

- (BOOL)loadThemePlist:(NSString *)filename {
	
	CHECK_CONFIGURED(NO);
	
	LOG(@"PWWidget: loadThemePlist (%@)", filename);
	
	NSString *path = [self _pathOfPlist:filename];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if (dict == nil) return NO;
	
	// parse and load theme
	PWTheme *theme = [PWThemePlistParser parse:dict inBundle:_bundle forWidget:self];
	theme.name = _name;
	
	// update reference
	[_theme release];
	_theme = [theme retain];
	
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

- (void)setLayout:(PWWidgetLayout)layout {
	CHECK_CONFIGURED();
	_layout = layout;
}

- (void)setPreferredTintColor:(UIColor *)tintColor {
	CHECK_CONFIGURED();
	[_preferredTintColor release];
	_preferredTintColor = [tintColor copy];
}

- (void)setPreferredBarTextColor:(UIColor *)tintColor {
	CHECK_CONFIGURED();
	[_preferredBarTextColor release];
	_preferredBarTextColor = [tintColor copy];
}

- (void)setDefaultItemViewControllerPlist:(NSString *)plist {
	CHECK_CONFIGURED();
	[_defaultItemViewControllerPlist release];
	_defaultItemViewControllerPlist = [plist copy];
}

//////////////////////////////////////////////////////////////////////

/**
 * Helper methods
 * Public API
 **/

- (BOOL)minimize {
	return [self.widgetController minimize];
}

- (BOOL)maximize {
	return [self.widgetController maximize];
}

- (BOOL)dismiss {
	if (self.widgetController.isAnimating) {
		self.widgetController.pendingDismissalRequest = YES;
		return YES;
	} else {
		return [self.widgetController dismiss];
	}
}

- (UIImage *)imageNamed:(NSString *)name {
	return [UIImage imageNamed:name inBundle:_bundle];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
	
	if (self.topViewController == nil) animated = NO;
	
	if (animated) {
		applyFadeTransition(_navigationController.view, .2);
	}
	
	[_navigationController setViewControllers:viewControllers animated:NO];
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
		
		[self.widgetController _resizeAnimated:animated];
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

- (void)userInfoChanged:(NSDictionary *)userInfo {}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {}
- (void)submitEventHandler:(NSDictionary *)values {}

//////////////////////////////////////////////////////////////////////


// helper method to throw an error
- (void)_throwSetterError:(NSString *)name {
	LOG(@"PWWidget: Unable to change configuration (%@) after the widget is presented.", name);
}

//////////////////////////////////////////////////////////////////////

/**
 * UINavigationControllerDelegate
 **/

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	// resign first responder
	[viewController.view endEditing:NO];
	
	// fix weird bug in iOS 7
	UINavigationBar *navigationBar = navigationController.navigationBar;
	[navigationBar.layer removeAllAnimations];
	CGRect rect = navigationBar.frame;
	rect.origin.y = 0.0;
	navigationBar.frame = rect;
	
	// call internal method
	if ([viewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *contentViewController = (PWContentViewController *)viewController;
		[contentViewController _willBePresentedInNavigationController:navigationController];
	}
	
	if ([viewController.class conformsToProtocol:@protocol(PWContentViewControllerDelegate)]) {
		
		id<PWContentViewControllerDelegate> contentViewController = (id<PWContentViewControllerDelegate>)viewController;
		
		// auto resize
		if (!self.widgetController.isAnimating)
			[self resizeWidgetAnimated:YES forContentViewController:contentViewController];
		
		// delegate method
		if ([contentViewController respondsToSelector:@selector(willBePresentedInNavigationController:)])
			[contentViewController willBePresentedInNavigationController:navigationController];
	}
	
	// auto set first responder
	// only set in this method when the widget is opening up
	if (self.widgetController.isAnimating && [viewController respondsToSelector:@selector(configureFirstResponder)]) {
		[viewController performSelector:@selector(configureFirstResponder)];
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	
	UINavigationBar *navigationBar = navigationController.navigationBar;
	
	// call internal method
	if ([viewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *contentViewController = (PWContentViewController *)viewController;
		[contentViewController _presentedInNavigationController:navigationController];
	}
	
	if (!_configuredGestureRecognizers) {
		
		if ([PWController supportsDragging]) {
			UIPanGestureRecognizer *pan = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationBarPan:)] autorelease];
			[pan setMinimumNumberOfTouches:1];
			[pan setMaximumNumberOfTouches:1];
			[navigationBar addGestureRecognizer:pan];
		}
		
		UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationBarSingleTap:)] autorelease];
		singleTap.delegate = self;
		
		UITapGestureRecognizer *doubleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleNavigationBarDoubleTap:)] autorelease];
		doubleTap.delegate = self;
		doubleTap.numberOfTapsRequired = 2;
		
		[singleTap requireGestureRecognizerToFail:doubleTap];
		
		_configuredGestureRecognizers = YES;
		
		[navigationBar addGestureRecognizer:singleTap];
		[navigationBar addGestureRecognizer:doubleTap];
	}
	
	// auto set first responder
	if ([viewController respondsToSelector:@selector(configureFirstResponder)]) {
		[viewController performSelector:@selector(configureFirstResponder)];
	}
}

//////////////////////////////////////////////////////////////////////

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	UIView *view = touch.view;
	BOOL isNavigationBar = [view isKindOfClass:[UINavigationBar class]];
	if (!isNavigationBar) {
		return NO;
	} else {
		CGPoint location = [touch locationInView:view];
		if ([(UINavigationBar *)view backButtonViewAtPoint:location] != nil) {
			return NO;
		}
	}
	return YES;
}

- (void)handleNavigationBarPan:(UIPanGestureRecognizer *)sender {
	[self.widgetController handleNavigationBarPan:sender];
}

- (void)handleNavigationBarSingleTap:(UIGestureRecognizer *)sender {
	if ([self.topViewController isKindOfClass:[PWContentViewController class]]) {
		PWContentViewController *controller = (PWContentViewController *)self.topViewController;
		[controller triggerEvent:[PWContentViewController titleTappedEventName] withObject:sender];
	}
}

- (void)handleNavigationBarDoubleTap:(UIGestureRecognizer *)sender {
	[self.widgetController minimize];
}

- (NSString *)description {
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
	
	// release all view controllers on stack
	_navigationController.viewControllers = nil;
	
	// release navigation controller
	RELEASE(_navigationController)
	
	// release widget theme
	RELEASE(_theme)
	
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