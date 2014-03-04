//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWController.h"
#import "PWTestBar.h"
#import "PWMiniView.h"

#import "PWWindow.h"
#import "PWView.h"
#import "PWBackgroundView.h"
#import "PWContainerView.h"

#import "PWWidget.h"
#import "PWWidgetJS.h"
#import "PWContentViewController.h"

#import "PWScript.h"

#import "PWTheme.h"
#import "PWThemePlistParser.h"

static PWController *sharedInstance = nil;

static inline void reloadPref(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[PWController sharedInstance] _reloadPreference];
}

@implementation PWController

+ (void)load {
	// add observer to reload preference
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, 0);
}

+ (instancetype)sharedInstance {
	
	@synchronized(self) {
		if (sharedInstance == nil)
			[self new];
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
			LOG(@"PWController: allocated shared instance (%@)", sharedInstance);
			return sharedInstance;
		}
	}
	
	return nil;
}

- (void)activeInterfaceOrientationDidChangeToOrientation:(UIInterfaceOrientation)activeInterfaceOrientation willAnimateWithDuration:(double)duration fromOrientation:(UIInterfaceOrientation)orientation {
	LOG(@"PWController: activeInterfaceOrientationDidChangeToOrientation: %d", (int)activeInterfaceOrientation);
	
	if (_interfaceOrientationIsLocked)
		return;
	
	void(^completionHandler)(BOOL) = ^(BOOL finished) {
		
		LOG(@"PWController: _lastFirstResponder: %@", _lastFirstResponder);
		
		_window.backgroundColor = [UIColor clearColor];
		
		[_lastFirstResponder resignFirstResponder];
		
		if (finished) {
			[_lastFirstResponder becomeFirstResponder];
		}
		
		RELEASE(_lastFirstResponder)
	};
	
	if (!_isAnimating) {
		
		_window.backgroundColor = self.backgroundView.backgroundColor;
		
		[UIView animateWithDuration:duration animations:^{
			[_window adjustLayout];
		} completion:completionHandler];
	} else {
		completionHandler(NO);
	}
}

- (void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)activeInterfaceOrientation {
	LOG(@"PWController: activeInterfaceOrientationWillChangeToOrientation: %d", (int)activeInterfaceOrientation);
	
	if (_interfaceOrientationIsLocked)
		return;
	
	if (_lastFirstResponder != nil) {
		RELEASE(_lastFirstResponder)
	}
	
	_lastFirstResponder = [[_window firstResponder] retain];
	[[objc_getClass("SBUIController") sharedInstance] _hideKeyboard]; // force to hide keyboard
}

//////////////////////////////////////////////////////////////////////

/**
 * Getters
 **/

+ (BOOL)protectedDataAvailable {
	int unlockState = MKBGetDeviceLockState(NULL);
	return unlockState == DeviceLockStateUnlockedWithPasscode || unlockState == DeviceLockStateUnlockedWithoutPasscode;
}

+ (int)version {
	return VERSION;
}

+ (NSBundle *)baseBundle {
	return [PWController sharedInstance].baseBundle;
}

+ (NSString *)basePath {
	return [[PWController sharedInstance].baseBundle bundlePath];
}

+ (BOOL)isIPad {
	
	static BOOL queried = NO;
	static BOOL isIPad = NO;
	
	if (!queried) {
		queried = YES;
		isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
	}
	
	return isIPad;
}

+ (BOOL)isPortrait {
	return [self currentOrientation] == PWWidgetOrientationPortrait;
}

+ (BOOL)isLandscape {
	return [self currentOrientation] == PWWidgetOrientationLandscape;
}

+ (PWWidgetOrientation)currentOrientation {
	return [[PWController sharedInstance] currentOrientation];
}

- (PWWidgetOrientation)currentOrientation {
	return UIInterfaceOrientationIsLandscape([self currentInterfaceOrientation]) ? PWWidgetOrientationLandscape : PWWidgetOrientationPortrait;
}

+ (UIInterfaceOrientation)currentInterfaceOrientation {
	return [[PWController sharedInstance] currentInterfaceOrientation];
}

- (UIInterfaceOrientation)currentInterfaceOrientation {
	
	if (_interfaceOrientationIsLocked)
		return _lockedInterfaceOrientation;
	
	UIApplication *app = [UIApplication sharedApplication];
	if ([app isKindOfClass:objc_getClass("SpringBoard")]) {
		return [(SpringBoard *)app activeInterfaceOrientation];
	} else {
		return [app statusBarOrientation];
	}
}

- (CGFloat)availableWidthInOrientation:(PWWidgetOrientation)orientation {
	
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	CGFloat width = orientation == PWWidgetOrientationPortrait ? screenSize.width : screenSize.height;
	
	if ([PWController isIPad]) // just to make sure the sheet on iPad is not too large
		width /= 2.0;
	
	return MAX(1.0, width - PWSheetHorizontalMargin * 2);
}

- (CGFloat)availableHeightInOrientation:(PWWidgetOrientation)orientation withKeyboard:(BOOL)withKeyboard {
	
	BOOL isLandscape = orientation == PWWidgetOrientationLandscape;
	CGSize screenSize = [[UIScreen mainScreen] bounds].size;
	CGFloat screenHeight = isLandscape ? screenSize.width : screenSize.height;
	CGFloat keyboardHeight = withKeyboard ? [self defaultHeightOfKeyboardInOrientation:orientation] : 0.0;
	CGFloat margin = PWSheetVerticalMargin * 2;
	
	if (isLandscape)
		margin /= 2;
	
	return screenHeight - keyboardHeight - margin;
}

- (CGFloat)heightOfNavigationBarInOrientation:(PWWidgetOrientation)orientation {
	if ([self.class isIPad] || orientation == PWWidgetOrientationPortrait) {
		return 44.0;
	} else {
		return 32.0;
	}
}

- (CGFloat)defaultHeightOfKeyboardInOrientation:(PWWidgetOrientation)orientation {
	
	if ([self.class isIPad]) {
		if ([self.class isPortrait])
			return 264.0;
		else if ([self.class isLandscape])
			return 352.0;
	} else {
		if ([self.class isPortrait])
			return 216.0;
		else if ([self.class isLandscape])
			return 162.0;
	}
	
	return 0.0;
}

- (UIImage *)imageResourceNamed:(NSString *)name {
	if (_resourceBundle == nil) return nil;
	return [UIImage imageNamed:name inBundle:_resourceBundle];
}

- (PWBackgroundView *)backgroundView {
	return self.mainView.backgroundView;
}

- (PWContainerView *)containerView {
	return self.mainView.containerView;
}

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)init {
	if ((self = [super init])) {
		
		// prepare bundles
		_baseBundle = [[NSBundle bundleWithPath:PWBaseBundlePath] retain];
		_resourceBundle = [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Resources/", PWBaseBundlePath]] retain];
		
		// load preference
		[self _loadPreference];
	}
	return self;
}

- (void)configure {
	
	if (objc_getClass("SpringBoard") == nil) {
		LOG(@"PWController can only be configured in SpringBoard.");
		return;
	}
	
	if (_configured) return;
	_configured = YES;
	
	// construct UI
	[self _constructUI];
	
	// remove all observers, just in case (prevent duplicated observers)
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// add notification observers
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShowHandler:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_protectedDataWillBecomeUnavailableHandler:) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_protectedDataDidBecomeAvailableHandler:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dismissWidgetHandler:) name:PWDismissWidgetNotification object:nil];
}

- (void)_constructUI {
	
	// build window
	_window = [PWWindow new];
	
	// build view
	_mainView = (PWView *)self.view; // +1
	
	// add parallax effect
	if (self.enabledParallax)
		[self _applyParallaxEffect];
	
	// add main view to window
	// it will be removed from window when a video is being played
	// so no need to release it after addSubview
	_window.rootViewController = self;
	[_window addSubview:_mainView];
	
	LOG(@"PWController: Constructed window (%@) and main view (%@)", _window, _mainView);
}

// initialize PWView
- (void)loadView {
	self.view = [[PWView new] autorelease];
}

/**
 * Preference loader
 **/

- (void)_loadPreference {
	
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PWPrefPath];
	
	// Parallax Effect
	NSNumber *enabledParallax = dict[@"enabledParallax"];
	_enabledParallax = enabledParallax == nil ? YES : [enabledParallax boolValue];
	
	// Preferred Source
	NSNumber *preferredSource = dict[@"preferredSource"];
	_preferredSource = preferredSource == nil ? 0 : [preferredSource unsignedIntegerValue]; // default is iCloud
	
	// Test Mode
	NSNumber *testMode = dict[@"testMode"];
	_testMode = testMode == nil ? NO : [testMode boolValue];
	
	// Visible widget order
	NSArray *visibleWidgetOrder = dict[@"visibleWidgetOrder"];
	[_visibleWidgetOrder release];
	_visibleWidgetOrder = [visibleWidgetOrder copy];
	
	// Hidden widget order
	NSArray *hiddenWidgetOrder = dict[@"hiddenWidgetOrder"];
	[_hiddenWidgetOrder release];
	_hiddenWidgetOrder = [hiddenWidgetOrder copy];
	
	// Default theme name
	NSString *defaultThemeName = dict[@"defaultThemeName"];
	[_defaultThemeName release];
	_defaultThemeName = [defaultThemeName copy];
	
	[dict release];
}

- (void)_reloadPreference {
	
	[self _loadPreference];
	
	// reset parallax enabled state
	if (self.enabledParallax) {
		[self _applyParallaxEffect];
	} else {
		[self _removeParallaxEffect];
	}
	
	// clear cached theme (if changed)
	if (![_defaultThemeName isEqualToString:_cachedDefaultThemeTheme]) {
		[self reloadDefaultTheme];
	}
}

/**
 * Notification handlers
 **/

- (void)_keyboardWillShowHandler:(NSNotification *)notification {
	
	if (!_isPresenting) return;
	
	NSDictionary *userInfo = [notification userInfo];
	CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat height = [self.class isLandscape] ? rect.size.width : rect.size.height;
	
	LOG(@"PWController: _keyboardWillShowHandler <keyboard height: %.2f>", height);
	
	[self.mainView keyboardWillShow:height];
}

- (void)_keyboardWillHideHandler:(NSNotification *)notification {
	if (!_isPresenting) return;
	[self.mainView keyboardWillHide];
}

- (void)_protectedDataWillBecomeUnavailableHandler:(NSNotification *)notification {
	LOG(@"PWController: _protectedDataWillBecomeUnavailableHandler");
	[self _showProtectedDataUnavailable:[PWController activeWidget] presented:YES];
}

- (void)_protectedDataDidBecomeAvailableHandler:(NSNotification *)notification {
	LOG(@"PWController: _protectedDataDidBecomeAvailableHandler");
}

- (void)_presentWidgetHandler:(NSNotification *)notification {
	
	NSObject *object = [notification object];
	NSDictionary *userInfo = [notification userInfo];
	
	LOG(@"PWController: _presentWidgetHandler: %@, %@", object, userInfo);
	
	BOOL isString = [object isKindOfClass:[NSString class]];
	BOOL isBundle = [object isKindOfClass:[NSBundle class]];
	BOOL isWidget = [object isKindOfClass:[PWWidget class]];
	
	if (object == nil || !(isString || isWidget)) {
		LOG(@"Unable to present widget through notification. Reason: Invalid notification object, must be any of (string, bundle, PWWidget) (%@)", object);
		return;
	}
	
	PWWidget *widget = nil;
	
	if (isString)
		widget = [self _createWidgetNamed:(NSString *)object];
	else if (isBundle)
		widget = [self _createWidgetFromBundle:(NSBundle *)object];
	else if (isWidget)
		widget = (PWWidget *)object;
	
	// all widget instances above are autoreleased
	if (widget != nil)
		[self _presentWidget:widget userInfo:userInfo];
}

- (void)_dismissWidgetHandler:(NSNotification *)notification {
	LOG(@"PWController: _dismissWidgetHandler");
	[self _dismissWidget];
}

//////////////////////////////////////////////////////////////////////

/**
 * General bundle loaders
 **/

- (NSBundle *)_bundleNamed:(NSString *)name ofType:(NSString *)type {
	
#ifdef DEBUG
	NSString *logType = nil;
	if ([type isEqualToString:@"Widgets"]) logType = @"widget";
	else if ([type isEqualToString:@"Themes"]) logType = @"theme";
#endif
	
	// trim the bundle name
	name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// validate the bundle name (to avoid directory traversal)
	if ([name isEqualToString:@"."] ||
		[name rangeOfString:@".."].location != NSNotFound ||
		[name rangeOfString:@"/"].location != NSNotFound ||
		[name rangeOfString:@"\\"].location != NSNotFound) {
		LOG(@"Unable to load %@ (%@). Reason: Invalid bundle name", logType, name);
		return nil;
	}
	
	// get the full path of widget bundle
	NSString *path = [NSString stringWithFormat:@"%@/%@/%@.bundle/", [self.class basePath], type, name];
	
	// check if the folder exists
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		if (bundle != nil) {
			return bundle;
		} else {
			LOG(@"Unable to load %@ (%@). Reason: Fail to load its bundle (%@)", logType, name, bundle);
		}
	} else {
		LOG(@"Unable to load %@ (%@). Reason: Bundle path does not exist (%@)", logType, name, path);
	}
	
	return nil;
}

//////////////////////////////////////////////////////////////////////

/**
 * Theme
 **/

+ (PWTheme *)activeTheme {
	return [[self sharedInstance] activeTheme];
}

- (PWTheme *)activeTheme {
	
	// return widget theme, if loaded in widget
	if (_presentedWidget != nil && [_presentedWidget _hasWidgetTheme]) {
		return [_presentedWidget _widgetTheme];
	}
	
	// else, then return cached default theme
	if (_loadedDefaultTheme) {
		return _cachedDefaultTheme;
	} else {
		// load default theme
		return [self loadDefaultTheme];
	}
}

- (NSString *)defaultThemeName {
	return _defaultThemeName == nil || [_defaultThemeName length] == 0 ? @"Blur" : _defaultThemeName;
}

- (PWTheme *)loadDefaultTheme {
	
	if (_loadedDefaultTheme) return _cachedDefaultTheme;
	
	// release previously-saved stuff
	if (_cachedDefaultThemeTheme != nil) [_cachedDefaultThemeTheme release];
	if (_cachedDefaultTheme != nil) [_cachedDefaultTheme release];
	
	// load default theme
	PWTheme *theme = [self loadThemeNamed:[self defaultThemeName]];
	
	_loadedDefaultTheme = YES;
	_cachedDefaultThemeTheme = [[self defaultThemeName] copy];
	_cachedDefaultTheme = [theme retain];
	
	return _cachedDefaultTheme;
}

- (PWTheme *)reloadDefaultTheme {
	_loadedDefaultTheme = NO;
	return [self loadDefaultTheme];
}

- (PWTheme *)loadThemeNamed:(NSString *)name {
	
	LOG(@"PWController: loadThemeNamed: %@", name);
	
	PWTheme *theme = nil;
	NSBundle *themeBundle = nil;
	
	// perhaps the name is a class name defined in plist
	// it was probably loaded in the widget executable
	Class class = NSClassFromString(name);
	
	if (class != nil && [class isSubclassOfClass:[PWTheme class]]) {
		
		LOG(@"PWController: '%@' is identified as a existing class.", name);
		theme = [class new];
		themeBundle = [NSBundle bundleForClass:class];
		
	} else {
		
		// otherwise, treat name as directory name (Themes/__name__/)
		NSBundle *bundle = [self _bundleNamed:name ofType:@"Themes"];
		
		// try to load the bundle
		[bundle load];
		
		if (bundle != nil) {
			
			// get the principal class
			Class principalClass = [bundle principalClass];
			if (principalClass == nil || ![principalClass isSubclassOfClass:[PWTheme class]]) {
				
				// try to locate the plist file
				NSString *plistPath = [NSString stringWithFormat:@"%@/%@.plist", [bundle bundlePath], name];
				NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
				if (plistPath != nil) {
					LOG(@"PWController: Loaded theme plist at '%@'", plistPath);
					theme = [[PWThemePlistParser parse:plistDict inBundle:bundle] retain];
					themeBundle = bundle;
				} else if (principalClass != nil) {
					LOG(@"PWController: Unable to create theme instance for bundle (%@). Reason: Principal class is not a subclass of PWTheme", [bundle bundleIdentifier]);
				}
				
			} else {
				
				theme = [principalClass new];
				themeBundle = bundle;
			}
		}
	}
		
	if (theme != nil) {
		theme.name = name;
		theme.bundle = themeBundle;
		return [theme autorelease];
	}
	
	return nil;
}

//////////////////////////////////////////////////////////////////////

/**
 * Widget
 **/

+ (PWWidget *)activeWidget {
	return [[self sharedInstance] activeWidget];
}

- (PWWidget *)activeWidget {
	return _presentedWidget;
}

- (NSBundle *)_bundleForWidgetNamed:(NSString *)name {
	
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Widgets"];
	if (bundle == nil) return nil;
	
	LOG(@"PWController: Loaded widget (%@)", name);
	
	return bundle;
}

- (PWWidget *)_createWidgetFromBundle:(NSBundle *)bundle {
	
	PWWidget *widget = nil;
	NSString *widgetName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension]; // get "*.bundle", then remove ".bundle"
	
	// try to load the bundle
	[bundle load];
	
	// get the principal class
	Class principalClass = [bundle principalClass];
	if (principalClass == nil || ![principalClass isSubclassOfClass:[PWWidget class]]) {
		
		// try to locate the JS file
		NSString *JSPath = [NSString stringWithFormat:@"%@/%@.js", [bundle bundlePath], widgetName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:JSPath]) {
			LOG(@"PWController: Loaded widget JavaScript file at '%@'.", JSPath);
			widget = [[[PWWidgetJS alloc] initWithJSFile:[NSString stringWithFormat:@"%@.js", widgetName] withName:widgetName inBundle:bundle] autorelease];
		} else if (principalClass != nil) {
			LOG(@"PWController: Unable to create widget instance for bundle (%@). Reason: Principal class is not a subclass of PWWidget", [bundle bundleIdentifier]);
			return nil;
		}
	}
	
	if (widget == nil) {
		widget = [[principalClass new] autorelease];
		widget.name = widgetName;
		widget.bundle = bundle;
	}
	
	// set the info of the widget
	NSDictionary *info = [self infoOfWidgetInBundle:widget.bundle];
	widget.info = info;
	
	LOG(@"PWController: Created widget instance for bundle (%@). Widget named (%@): %@", [bundle bundleIdentifier], widgetName, widget);
	return widget;
}

- (PWWidget *)_createWidgetNamed:(NSString *)name {
	
	NSBundle *bundle = [self _bundleForWidgetNamed:name];
	
	if (bundle != nil) {
		return [self _createWidgetFromBundle:bundle];
	}
	
	return nil;
}

- (BOOL)_presentWidget:(PWWidget *)widget userInfo:(NSDictionary *)userInfo {
	
	LOG(@"PWController: _presentWidget <widget: %@> <user info: %@>", widget, userInfo);
	
	if (_hasPendingWidget) return NO;
	
	// auto maximize the widget
	if (_isPresenting && _presentedWidget != nil && _isMinimized) {
		
		BOOL sameWidget = [widget.name isEqualToString:_presentedWidget.name];
		
		if (sameWidget) {
			// maximize the widget
			[self _maximizeWidget];
			
			// notify the widget that user info has changed
			NSDictionary *oldUserInfo = _presentedWidget.userInfo;
			if ((oldUserInfo == nil && userInfo != nil) || (oldUserInfo != nil && userInfo == nil) || ![oldUserInfo isEqual:userInfo]) {
				_presentedWidget.userInfo = userInfo;
				[_presentedWidget userInfoChanged:userInfo];
			}
		} else {
			// ask the user whether to dismiss the minimized widget, and
			// then present the new one
			PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:@"Another widget is minimized" message:@"Do you want to dismiss the minimized widget, and then present the new one?" buttonTitle:@"Yes" defaultValue:nil cancelButtonTitle:@"No" style:UIAlertViewStyleDefault completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
				// ensure the status does not change
				if (!cancelled && !_hasPendingWidget && _isPresenting && _presentedWidget != nil && _isMinimized) {
					_hasPendingWidget = YES;
					_pendingWidget = [widget retain];
					_pendingUserInfo = [userInfo retain];
					[self _dismissMinimizedWidget];
				}
			}];
			[alertView show];
			[alertView release];
		}
		
		return YES;
	}
	
	if (_isPresenting || _presentedWidget != nil) {
		LOG(@"PWController: Unable to present widget (%@). Reason: Another widget is currently being presented. (%@)", widget, _presentedWidget);
		return NO;
	}
	
	// block orientation change on non-iPad devices
	if (![self.class isIPad]) {
		_interfaceOrientationIsLocked = NO;
		[[objc_getClass("SBUIController") sharedInstance] _lockOrientationForTransition];
		_lockedInterfaceOrientation = [self currentInterfaceOrientation];
		_interfaceOrientationIsLocked = YES;
	}
	
	_pendingDismissalRequest = NO;
	
	_isPresenting = YES;
	_isMinimized = NO;
	_isAnimating = YES;
	_presentedWidget = [widget retain];
	
	// set user info
	widget.userInfo = userInfo;
	
	// configure widget
	// configure title, widget theme, tint/bar text colors, default item view controller plist
	[widget configure];
	
	// simple check before loading the widget
	if (widget.requiresProtectedDataAccess && ![self.class protectedDataAvailable]) {
		[self _showProtectedDataUnavailable:widget presented:NO];
		[self _manuallyDismissWidget];
		return NO;
	}
	
	[widget _setConfigured];
	
	// create PWContainerView
	// this will also add navigation controller view as its subview
	[self.mainView createContainerView];
	
	// configure active theme
	PWTheme *theme = [PWController activeTheme];
	[theme _setPreferredTintColor:[widget preferredTintColor]];
	[theme _setPreferredBarTextColor:[widget preferredBarTextColor]];
	[theme _configureAppearance];
	[theme setupTheme];
	
	// load the widget
	// e.g. create or push custom view controllers
	[widget load];
	
	// configure for default layout & block further changes
	[widget preparePresentation];
	
	// ensure the widget has already pushed a view controller
	id topViewController = widget.topViewController;
	
	// if the widget does not have a root view controller, or it requests to dismiss in load method, then dismiss it immediately
	if (_pendingDismissalRequest || topViewController == nil) {
		
		// show an error alert
		if (!_pendingDismissalRequest && topViewController == nil) {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Unable to present widget" message:[NSString stringWithFormat:@"The widget \"%@\" does not have a root view controller.", widget.displayName] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
		
		// manually dismiss it
		[self _manuallyDismissWidget];
		return NO;
	}
	
	[widget willPresent];
	
	// update the mask in background view
	[self.backgroundView show:YES];
	
	// show PWWindow
	[_window show];
	
	CALayer *layer = self.containerView.layer;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:PWAnimationDuration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[CATransaction setCompletionBlock:^{
		
		_isAnimating = NO;
		[widget didPresent];
		
		// show test bar
		if (_testMode) {
			[[PWTestBar sharedInstance] show];
		}
		
		if (_pendingDismissalRequest) {
			[self _dismissWidget];
		}
	}];
	
	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithDouble:0.0];
	fade.toValue = [NSNumber numberWithDouble:1.0];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.fromValue = [NSNumber numberWithDouble:1.2];
	scale.toValue = [NSNumber numberWithDouble:1.0];
	scale.fillMode = kCAFillModeForwards;
	scale.removedOnCompletion = NO;
	
	layer.opacity = 1.0;
	
	[layer addAnimation:fade forKey:@"fade"];
	[layer addAnimation:scale forKey:@"scale"];
	[CATransaction commit];
	
	return YES;
}

- (BOOL)_dismissWidget {
	
	LOG(@"PWController: _dismissWidget: %@", _presentedWidget);
	
	// no widget is currently presented, unable to dismiss
	if (!_isPresenting || _presentedWidget == nil) {
		LOG(@"PWController: Unable to dismiss widget. Reason: No widget is presented.");
		return NO;
	}
	
	if (_isAnimating) {
		LOG(@"PWController: Unable to dismiss widget. Widget is being animated.");
		return NO;
	}
	
	if (_isMinimized) {
		LOG(@"PWController: Unable to dismiss widget. Widget is currently minimized.");
		return NO;
	}
	
	_pendingDismissalRequest = NO;
	
	// hide debug bar
	[[PWTestBar sharedInstance] hide];
	
	// update flag
	_isAnimating = YES;
	
	// force hide keyboard
	[_window endEditing:YES];
	
	// notify widget
	[_presentedWidget willDismiss];
	
	// hide background view
	[self.backgroundView hide];
	
	CALayer *layer = self.containerView.layer;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:PWAnimationDuration];
	[CATransaction setCompletionBlock:^{
		
		[_presentedWidget didDismiss];
		
		// remove theme
		[[PWController activeTheme] removeTheme];
		
		// remove container view
		[self.mainView removeContainerView];
		
		// hide window
		// stop blocking user interaction
		[_window hide];
		
		// this is to force release all the event handlers that may retain widget instance (inside block)
		// then widget will never get released
		[_presentedWidget _dealloc];
		[_presentedWidget release];
		
		_isPresenting = NO;
		_isMinimized = NO;
		_isAnimating = NO;
		_presentedWidget = nil;
		
		if (![self.class isIPad]) {
			[[objc_getClass("SBUIController") sharedInstance] _releaseTransitionOrientationLock];
			_interfaceOrientationIsLocked = NO;
		}
		
		// reset auto dim timer
		[[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
	}];
	
	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithFloat:1.0];
	fade.toValue = [NSNumber numberWithFloat:0.0];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.fromValue = [NSNumber numberWithFloat:1.0];
	scale.toValue = [NSNumber numberWithFloat:0.7];
	scale.fillMode = kCAFillModeForwards;
	scale.removedOnCompletion = NO;
	
	layer.opacity = 0.0;
	
	[layer addAnimation:fade forKey:@"fade"];
	[layer addAnimation:scale forKey:@"scale"];
	[CATransaction commit];
	
	return YES;
}

- (BOOL)_dismissMinimizedWidget {
	
	LOG(@"PWController: _dismissMinimizedWidget: %@", _presentedWidget);
	
	// no widget is currently presented, unable to dismiss
	if (!_isPresenting || _presentedWidget == nil) {
		LOG(@"PWController: Unable to dismiss widget. Reason: No widget is presented.");
		return NO;
	}
	
	if (_isAnimating) {
		LOG(@"PWController: Unable to dismiss widget. Widget is being animated.");
		return NO;
	}
	
	if (!_isMinimized) {
		LOG(@"PWController: Unable to dismiss widget. Widget is not minimized.");
		return NO;
	}
	
	_pendingDismissalRequest = NO;
	
	// update flag
	_isAnimating = YES;
	
	// force hide keyboard
	[_window endEditing:YES];
	
	// notify widget
	[_presentedWidget willDismiss];
	
	// remove theme
	[[PWController activeTheme] removeTheme];
	
	// remove container view
	[self.mainView removeContainerView];
	
	// perform animation
	CALayer *layer = self.window.miniView.layer;
	CGFloat scaleTo = PWMinimizationScale * 0.8;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:PWAnimationDuration];
	[CATransaction setCompletionBlock:^{
		
		[_presentedWidget didDismiss];
		
		// hide window
		// stop blocking user interaction
		[_window hide];
		
		// remove mini view
		[self.window removeMiniView];
		
		// show main view
		self.mainView.hidden = NO;
		
		// this is to force release all the event handlers that may retain widget instance (inside block)
		// then widget will never get released
		[_presentedWidget _dealloc];
		[_presentedWidget release];
		
		_isPresenting = NO;
		_isMinimized = NO;
		_isAnimating = NO;
		_presentedWidget = nil;
		
		if (![self.class isIPad]) {
			[[objc_getClass("SBUIController") sharedInstance] _releaseTransitionOrientationLock];
			_interfaceOrientationIsLocked = NO;
		}
		
		// reset auto dim timer
		[[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
		
		// check if there is any pending widget
		if (_hasPendingWidget) {
			_hasPendingWidget = NO;
			[self _presentWidget:_pendingWidget userInfo:_pendingUserInfo];
			RELEASE(_pendingWidget)
			RELEASE(_pendingUserInfo)
		}
	}];
	
	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithFloat:1.0];
	fade.toValue = [NSNumber numberWithFloat:0.0];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.fromValue = [NSNumber numberWithFloat:PWMinimizationScale];
	scale.toValue = [NSNumber numberWithFloat:scaleTo];
	scale.fillMode = kCAFillModeForwards;
	scale.removedOnCompletion = NO;
	
	layer.opacity = 0.0;
	layer.transform = CATransform3DMakeScale(scaleTo, scaleTo, 1.0);
	
	[layer addAnimation:fade forKey:@"fade"];
	[layer addAnimation:scale forKey:@"scale"];
	[CATransaction commit];
	
	return YES;
}

- (BOOL)_minimizeWidget {
	
	LOG(@"PWController: _minimizeWidget: %@", _presentedWidget);
	
	// no widget is currently presented, unable to dismiss
	if (!_isPresenting || _presentedWidget == nil) {
		LOG(@"PWController: Unable to minimize widget. Reason: No widget is presented.");
		return NO;
	}
	
	if (_isAnimating) {
		LOG(@"PWController: Unable to minimize widget. Widget is being animated.");
		return NO;
	}
	
	if (_isMinimized) {
		LOG(@"PWController: Unable to minimize widget. Widget is already minimized.");
		return NO;
	}
	
	_isMinimized = YES;
	_pendingDismissalRequest = NO;
	
	// hide debug bar
	[[PWTestBar sharedInstance] hide];
	
	// update flag
	_isAnimating = YES;
	
	// force hide keyboard
	[_window endEditing:YES];
	
	// generate image for mini view
	UIGraphicsBeginImageContextWithOptions(self.containerView.bounds.size, NO, 0);
	
	PWTheme *theme = [PWController activeTheme];
	[theme enterSnapshotMode];
	[self.containerView drawViewHierarchyInRect:self.containerView.bounds afterScreenUpdates:YES];
	[theme exitSnapshotMode];
	
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// apply gaussian blur to the snapshot
	/*
	CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
	[filter setDefaults];
	[filter setValue:[CIImage imageWithCGImage:[snapshot CGImage]] forKey:kCIInputImageKey];
	[filter setValue:@(3.0) forKey:kCIInputRadiusKey];
	CIImage *outputImage = [filter outputImage];
	snapshot = [UIImage imageWithCIImage:outputImage];
	*/
	
	// hide container view
	self.containerView.hidden = YES;
	
	// hide background view
	[self.backgroundView hide];
	
	// ask window to create a mini view with the snapshot image
	PWMiniView *miniView = [self.window createMiniViewWithSnapshot:snapshot];
	
	// animate the layer
	CALayer *layer = miniView.layer;
	CGFloat fadeTo = .9;
	CGFloat viewScale = PWMinimizationScale;
	CGFloat initialExtraScale = .92;
	CGPoint initialPosition = [self.window getInitialPositionOfMiniView];
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:.3];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[CATransaction setCompletionBlock:^{
		
		// hide main view
		self.mainView.hidden = YES;
		
		// configure its appearance
		[layer setCornerRadius:20.0];
		[layer setBorderColor:[UIColor colorWithWhite:.3 alpha:.8].CGColor];
		[layer setBorderWidth:3.0];
		
		// perform second animation
		[CATransaction begin];
		[CATransaction setAnimationDuration:.15];
		[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		[CATransaction setCompletionBlock:^{
			_isAnimating = NO;
		}];
		
		CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
		scale.fromValue = [NSNumber numberWithFloat:viewScale * initialExtraScale];
		scale.toValue = [NSNumber numberWithFloat:viewScale];
		
		layer.transform = CATransform3DMakeScale(viewScale, viewScale, 1.0);
		
		[layer addAnimation:scale forKey:@"scale"];
		[CATransaction commit];
	}];
	
	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = [NSNumber numberWithFloat:1.0];
	fade.toValue = [NSNumber numberWithFloat:fadeTo];
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.fromValue = [NSNumber numberWithFloat:1.0];
	scale.toValue = [NSNumber numberWithFloat:viewScale * initialExtraScale];
	
	CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.fromValue = [NSValue valueWithCGPoint:layer.position];
	position.toValue = [NSValue valueWithCGPoint:initialPosition];
	
	layer.opacity = fadeTo;
	layer.transform = CATransform3DMakeScale(viewScale * initialExtraScale, viewScale * initialExtraScale, 1.0);
	layer.position = initialPosition;
	
	[layer addAnimation:fade forKey:@"fade"];
	[layer addAnimation:scale forKey:@"scale"];
	[layer addAnimation:position forKey:@"position"];
	[CATransaction commit];
	
	return YES;
}

- (BOOL)_maximizeWidget {
	
	LOG(@"PWController: _maximizeWidget: %@", _presentedWidget);
	
	// no widget is currently presented, unable to dismiss
	if (!_isPresenting || _presentedWidget == nil) {
		LOG(@"PWController: Unable to maximize widget. Reason: No widget is presented.");
		return NO;
	}
	
	if (_isAnimating) {
		LOG(@"PWController: Unable to maximize widget. Widget is being animated.");
		return NO;
	}
	
	if (!_isMinimized) {
		LOG(@"PWController: Unable to maximize widget. Widget is already maximized.");
		return NO;
	}
	
	// update flag
	_isAnimating = YES;
	
	// request key window
	[self.window show];
	
	PWMiniView *miniView = self.window.miniView;
	CGFloat miniViewScale = PWMinimizationScale;
	CGPoint miniViewCenter = miniView.center;
	
	// show main view and container view
	self.containerView.hidden = NO;
	self.mainView.hidden = NO;
	
	// remove mini view
	[self.window removeMiniView];
	
	// animate the layer
	CALayer *layer = self.containerView.layer;
	CGFloat fadeFrom = .8;
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:.2];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[CATransaction setCompletionBlock:^{
		
		// show background view
		[self.backgroundView show:NO];
		
		// force main view to perform layoutSubviews
		[self.mainView setNeedsLayout];
		
		// ask the top view controller to configure first responder (regain keyboard)
		[_presentedWidget.topViewController configureFirstResponder];
		
		// update flags
		_isAnimating = NO;
		_isMinimized = NO;
	}];
	
	CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fade.fromValue = @(fadeFrom);
	fade.toValue = @(1.0);
	
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scale.fromValue = @(miniViewScale);
	scale.toValue = @(1.0);
	
	CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
	position.fromValue = [NSValue valueWithCGPoint:miniViewCenter];
	position.toValue = [NSValue valueWithCGPoint:layer.position];
	
	[layer addAnimation:fade forKey:@"fade"];
	[layer addAnimation:scale forKey:@"scale"];
	[layer addAnimation:position forKey:@"position"];
	[CATransaction commit];
	
	return YES;
}

//////////////////////////////////////////////////////////////////////

/**
 * Script
 **/

- (NSBundle *)_bundleForScriptNamed:(NSString *)name {
	
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Scripts"];
	if (bundle == nil) return nil;
	
	LOG(@"PWController: Loaded script (%@)", name);
	
	return bundle;
}

- (PWScript *)_createScriptFromBundle:(NSBundle *)bundle {
	
	PWScript *script = nil;
	NSString *scriptName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension]; // get "*.bundle", then remove ".bundle"
	
	// try to load the bundle
	[bundle load];
	
	// get the principal class
	Class principalClass = [bundle principalClass];
	if (principalClass == nil || ![principalClass isSubclassOfClass:[PWScript class]]) {
		
		// try to locate the JS file
		NSString *JSPath = [NSString stringWithFormat:@"%@/%@.js", [bundle bundlePath], scriptName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:JSPath]) {
			LOG(@"PWController: Loaded script JavaScript file at '%@'.", JSPath);
			script = [PWScript scriptWithJSFile:[NSString stringWithFormat:@"%@.js", scriptName] withName:scriptName inBundle:bundle];
		} else if (principalClass != nil) {
			LOG(@"PWController: Unable to create script instance for bundle (%@). Reason: Principal class is not a subclass of PWScript", [bundle bundleIdentifier]);
			return nil;
		}
	}
	
	if (script == nil) {
		script = [principalClass scriptWithName:scriptName inBundle:bundle];
	}
	
	// set the info of the script
	NSDictionary *info = [self infoOfScriptInBundle:bundle];
	script.info = info;
	
	// ask the widget to load its preference file
	NSString *defaults = info[@"preferenceDefaults"];
	if (defaults != nil && [defaults length] > 0) {
		NSString *plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaults];
		[script _loadPreferenceFromFile:plistPath];
	}
	
	LOG(@"PWController: Created script instance for bundle (%@). Script named (%@): %@", [bundle bundleIdentifier], scriptName, script);
	
	return script;
}

- (PWScript *)_createScriptNamed:(NSString *)name {
	
	NSBundle *bundle = [self _bundleForScriptNamed:name];
	
	if (bundle != nil) {
		return [self _createScriptFromBundle:bundle];
	}
	
	return nil;
}

- (BOOL)_executeScript:(PWScript *)script userInfo:(NSDictionary *)userInfo {
	
	if (script == nil) return NO;
	
	// the script should be autoreleased
	script.userInfo = userInfo;
	
	// execute the script in background thread
	//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[script _execute];
	//});
	
	return YES;
}

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

- (BOOL)presentWidget:(PWWidget *)widget userInfo:(NSDictionary *)userInfo {
	return [self _presentWidget:widget userInfo:userInfo];
}

- (BOOL)presentWidgetNamed:(NSString *)name userInfo:(NSDictionary *)userInfo {
	PWWidget *widget = [self _createWidgetNamed:name];
	if (widget == nil) return NO;
	return [self _presentWidget:widget userInfo:userInfo];
}

- (BOOL)presentWidgetFromBundle:(NSBundle *)bundle userInfo:(NSDictionary *)userInfo {
	PWWidget *widget = [self _createWidgetFromBundle:bundle];
	if (widget == nil) return NO;
	return [self _presentWidget:widget userInfo:userInfo];
}

- (BOOL)dismissWidget {
	return [self _dismissWidget];
}

- (BOOL)minimizeWidget {
	return [self _minimizeWidget];
}

- (BOOL)maximizeWidget {
	return [self _maximizeWidget];
}

- (BOOL)executeScript:(PWScript *)script userInfo:(NSDictionary *)userInfo {
	return [self _executeScript:script userInfo:userInfo];
}

- (BOOL)executeScriptNamed:(NSString *)name userInfo:(NSDictionary *)userInfo {
	PWScript *script = [self _createScriptNamed:name];
	if (script == nil) return NO;
	return [self _executeScript:script userInfo:userInfo];
}

- (BOOL)executeScriptFromBundle:(NSBundle *)bundle userInfo:(NSDictionary *)userInfo {
	PWScript *script = [self _createScriptFromBundle:bundle];
	if (script == nil) return NO;
	return [self _executeScript:script userInfo:userInfo];
}

- (NSDictionary *)infoOfWidgetNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Widgets"];
	return [self infoOfWidgetInBundle:bundle];
}

- (NSDictionary *)infoOfWidgetInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	// retrieve widget name from bundle path
	NSString *widgetName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
	
	if (widgetName == nil || [widgetName length] == 0) {
		LOG(@"PWController: Unable to retrieve widget name from bundle path (%@).", [bundle bundlePath]);
		return nil;
	}
	
	// info dictionary
	NSString *infoPath = [NSString stringWithFormat:@"%@/Info.plist", [bundle bundlePath]];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	
	// PWInfoType
	NSString *type = [info[@"PWInfoType"] lowercaseString];
	if (![type isEqualToString:@"widget"]) return nil; // invalid type
	
	// PWInfoDisplayName
	NSString *displayName = info[@"PWInfoDisplayName"];
	if (displayName == nil) displayName = widgetName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoDescription
	NSString *description = info[@"PWInfoDescription"];
	if (description == nil) description = @"";
	
	// PWInfoEnableActivation
	NSNumber *enableActivation = info[@"PWInfoEnableActivation"];
	if (enableActivation == nil) enableActivation = @YES;
	
	// PWInfoIconFile
	NSString *iconFile = info[@"PWInfoIconFile"];
	if (iconFile == nil) iconFile = @"icon.png";
	
	// PWInfoMaskFile
	NSString *maskFile = info[@"PWInfoMaskFile"];
	if (maskFile == nil) maskFile = @"mask.png";
	
	// PWInfoPreferenceDefaults
	NSString *preferenceDefaults = info[@"PWInfoPreferenceDefaults"];
	if (preferenceDefaults == nil) preferenceDefaults = @"";
	
	// PWInfoPreferenceFile
	NSString *preferenceFile = info[@"PWInfoPreferenceFile"];
	if (preferenceFile == nil) preferenceFile = @"";
	
	// PWInfoAppIdentifier
	NSString *appIdentifier = info[@"PWInfoAppIdentifier"];
	if (appIdentifier == nil) appIdentifier = @"";
	
	// check if the widget is installed via URL
	NSString *indicatorPath = [NSString stringWithFormat:@"%@/.installed", [bundle bundlePath]];
	NSNumber *installedViaURL = @([[NSFileManager defaultManager] fileExistsAtPath:indicatorPath]);
	
	return @{
			 @"name": widgetName,
			 @"displayName": displayName,
			 @"author": author,
			 @"description": description,
			 @"enableActivation": enableActivation,
			 @"iconFile": iconFile,
			 @"maskFile": maskFile,
			 @"hasPreference": @([preferenceFile length] > 0),
			 @"preferenceDefaults": preferenceDefaults,
			 @"preferenceFile": preferenceFile,
			 @"appIdentifier": appIdentifier,
			 @"bundle": bundle,
			 @"installedViaURL": installedViaURL
			 };
}

- (NSDictionary *)infoOfEnabledWidgetInBundle:(NSBundle *)bundle {
	NSDictionary *info = [self infoOfWidgetInBundle:bundle];
	NSNumber *enableActivation = info[@"enableActivation"];
	return (enableActivation != nil && [enableActivation boolValue]) || enableActivation == nil ? info : nil;
}

- (NSDictionary *)infoOfScriptNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Scripts"];
	return [self infoOfScriptInBundle:bundle];
}

- (NSDictionary *)infoOfScriptInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	// retrieve script name from bundle path
	NSString *scriptName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
	
	if (scriptName == nil || [scriptName length] == 0) {
		LOG(@"PWController: Unable to retrieve script name from bundle path (%@).", [bundle bundlePath]);
		return nil;
	}
	
	// info dictionary
	NSString *infoPath = [NSString stringWithFormat:@"%@/Info.plist", [bundle bundlePath]];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	
	// PWInfoType
	NSString *type = [info[@"PWInfoType"] lowercaseString];
	if (![type isEqualToString:@"script"]) return nil; // invalid type
	
	// PWInfoDisplayName
	NSString *displayName = info[@"PWInfoDisplayName"];
	if (displayName == nil) displayName = scriptName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoDescription
	NSString *description = info[@"PWInfoDescription"];
	if (description == nil) description = @"";
	
	// PWInfoPreferenceDefaults
	NSString *preferenceDefaults = info[@"PWInfoPreferenceDefaults"];
	if (preferenceDefaults == nil) preferenceDefaults = @"";
	
	// PWInfoPreferenceFile
	NSString *preferenceFile = info[@"PWInfoPreferenceFile"];
	if (preferenceFile == nil) preferenceFile = @"";
	
	// check if the widget is installed via URL
	NSString *indicatorPath = [NSString stringWithFormat:@"%@/.installed", [bundle bundlePath]];
	NSNumber *installedViaURL = @([[NSFileManager defaultManager] fileExistsAtPath:indicatorPath]);
	
	return @{
			 @"name": scriptName,
			 @"displayName": displayName,
			 @"author": author,
			 @"description": description,
			 @"hasPreference": @([preferenceFile length] > 0),
			 @"preferenceDefaults": preferenceDefaults,
			 @"preferenceFile": preferenceFile,
			 @"bundle": bundle,
			 @"installedViaURL": installedViaURL
			 };
}

- (NSDictionary *)infoOfThemeNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Themes"];
	return [self infoOfThemeInBundle:bundle];
}

- (NSDictionary *)infoOfThemeInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	// retrieve theme name from bundle path
	NSString *themeName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
	
	if (themeName == nil || [themeName length] == 0) {
		LOG(@"PWController: Unable to retrieve theme name from bundle path (%@).", [bundle bundlePath]);
		return nil;
	}
	
	// info dictionary
	NSString *infoPath = [NSString stringWithFormat:@"%@/Info.plist", [bundle bundlePath]];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	
	// PWInfoType
	NSString *type = [info[@"PWInfoType"] lowercaseString];
	if (![type isEqualToString:@"theme"]) return nil; // invalid type
	
	// PWInfoDisplayName
	NSString *displayName = info[@"PWInfoDisplayName"];
	if (displayName == nil) displayName = themeName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoDescription
	NSString *description = info[@"PWInfoDescription"];
	if (description == nil) description = @"";
	
	// PWInfoIconFile
	NSString *iconFile = info[@"PWInfoIconFile"];
	if (iconFile == nil) iconFile = @"";
	
	// check if the widget is installed via URL
	NSString *indicatorPath = [NSString stringWithFormat:@"%@/.installed", [bundle bundlePath]];
	NSNumber *installedViaURL = @([[NSFileManager defaultManager] fileExistsAtPath:indicatorPath]);
	
	return @{
			 @"name": themeName,
			 @"displayName": displayName,
			 @"author": author,
			 @"description": description,
			 @"iconFile": iconFile,
			 @"bundle": bundle,
			 @"installedViaURL": installedViaURL
			 };
}

- (NSDictionary *)infoOfActivationMethodInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	// retrieve widget name from bundle path
	NSString *methodName = [[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension];
	
	if (methodName == nil || [methodName length] == 0) {
		LOG(@"PWController: Unable to retrieve activation method name from bundle path (%@).", [bundle bundlePath]);
		return nil;
	}
	
	// info dictionary
	NSString *infoPath = [NSString stringWithFormat:@"%@/Info.plist", [bundle bundlePath]];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	
	// PWInfoType
	NSString *type = [info[@"PWInfoType"] lowercaseString];
	if (![type isEqualToString:@"activationmethod"]) return nil; // invalid type
	
	// PWInfoDisplayName
	NSString *displayName = info[@"PWInfoDisplayName"];
	if (displayName == nil) displayName = methodName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoDescription
	NSString *description = info[@"PWInfoDescription"];
	if (description == nil) description = @"";
	
	// PWInfoPreferenceDefaults
	//NSString *preferenceDefaults = info[@"PWInfoPreferenceDefaults"];
	//if (preferenceDefaults == nil) preferenceDefaults = @"";
	
	// PWInfoPreferenceFile
	NSString *preferenceFile = info[@"PWInfoPreferenceFile"];
	if (preferenceFile == nil) preferenceFile = @"";
	
	return @{
			 @"name": methodName,
			 @"displayName": displayName,
			 @"author": author,
			 @"description": description,
			 @"hasPreference": @([preferenceFile length] > 0),
			 //@"preferenceDefaults": preferenceDefaults,
			 @"preferenceFile": preferenceFile,
			 @"bundle": bundle
			 };
}

- (UIImage *)iconOfWidgetNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Widgets"];
	return [self iconOfWidgetInBundle:bundle];
}

- (UIImage *)iconOfWidgetInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	NSDictionary *info = [self infoOfWidgetInBundle:bundle];
	NSString *iconFile = info[@"iconFile"];
	
	if (iconFile == nil || [iconFile length] == 0)
		return nil;
	
	return [UIImage imageNamed:iconFile inBundle:bundle];
}

- (UIImage *)iconOfThemeNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Themes"];
	return [self iconOfThemeInBundle:bundle];
}

- (UIImage *)iconOfThemeInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	NSDictionary *info = [self infoOfThemeInBundle:bundle];
	NSString *iconFile = info[@"iconFile"];
	
	if (iconFile == nil || [iconFile length] == 0)
		return nil;
	
	return [UIImage imageNamed:iconFile inBundle:bundle];
}

- (UIImage *)maskOfWidgetNamed:(NSString *)name {
	NSBundle *bundle = [self _bundleNamed:name ofType:@"Widgets"];
	return [self maskOfWidgetInBundle:bundle];
}

- (UIImage *)maskOfWidgetInBundle:(NSBundle *)bundle {
	
	if (bundle == nil) return nil;
	
	NSDictionary *info = [self infoOfWidgetInBundle:bundle];
	NSString *maskFile = info[@"maskFile"];
	
	if (maskFile == nil || [maskFile length] == 0)
		return nil;
	
	return [UIImage imageNamed:maskFile inBundle:bundle];
}

- (NSArray *)installedWidgets {
	return [self _installedBundlesOfType:@"Widgets" infoSelector:@selector(infoOfWidgetInBundle:)];
}

- (NSDictionary *)enabledWidgets {
	
	NSArray *unsorted = [self _installedBundlesOfType:@"Widgets" infoSelector:@selector(infoOfEnabledWidgetInBundle:)];
	NSArray *visibleOrder = self.visibleWidgetOrder;
	NSArray *hiddenOrder = self.hiddenWidgetOrder;
	
	// extract the visible and hidden widgets from the unsorted list
	NSMutableArray *visibleWidgets = [NSMutableArray array];
	NSMutableArray *hiddenWidgets = [NSMutableArray array];
	for (NSDictionary *info in unsorted) {
		NSString *name = info[@"name"];
		if (name == nil || [hiddenOrder containsObject:name]) {
			[hiddenWidgets addObject:info];
		} else {
			[visibleWidgets addObject:info];
		}
	}
	
	// sort two arrays
	[visibleWidgets sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
		NSString *aName = a[@"name"];
		NSString *bName = b[@"name"];
		NSUInteger aIndex = [visibleOrder indexOfObject:aName];
		NSUInteger bIndex = [visibleOrder indexOfObject:bName];
		return (aIndex > bIndex) ? NSOrderedDescending : (aIndex == bIndex ? NSOrderedSame : NSOrderedAscending);
	}];
	
	[hiddenWidgets sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
		NSString *aName = a[@"name"];
		NSString *bName = b[@"name"];
		NSUInteger aIndex = [hiddenOrder indexOfObject:aName];
		NSUInteger bIndex = [hiddenOrder indexOfObject:bName];
		return (aIndex > bIndex) ? NSOrderedDescending : (aIndex == bIndex ? NSOrderedSame : NSOrderedAscending);
	}];
	
	return @{ @"visible":visibleWidgets, @"hidden":hiddenWidgets };
}

- (NSArray *)visibleWidgets {
	return [self enabledWidgets][@"visible"];
}

- (NSArray *)hiddenWidgets {
	return [self enabledWidgets][@"hidden"];
}

- (NSArray *)installedScripts {
	return [self _installedBundlesOfType:@"Scripts" infoSelector:@selector(infoOfScriptInBundle:)];
}

- (NSArray *)installedThemes {
	return [self _installedBundlesOfType:@"Themes" infoSelector:@selector(infoOfThemeInBundle:)];
}

- (NSArray *)activationMethods {
	return [self _installedBundlesOfType:@"ActivationMethods" infoSelector:@selector(infoOfActivationMethodInBundle:)];
}

//////////////////////////////////////////////////////////////////////

/**
 * Private methods
 **/

+ (BOOL)_shouldDisableLockScreenIdleTimer {
	return [PWController sharedInstance].isPresenting;
}

- (void)_manuallyDismissWidget {
	
	_pendingDismissalRequest = NO;
	_isPresenting = NO;
	_isAnimating = NO;
	
	[_presentedWidget release], _presentedWidget = nil;
	
	[self.mainView removeContainerView];
	
	if (![self.class isIPad]) {
		[[objc_getClass("SBUIController") sharedInstance] _releaseTransitionOrientationLock];
		_interfaceOrientationIsLocked = NO;
	}
	
	// reset auto dim timer
	[[objc_getClass("SBBacklightController") sharedInstance] resetLockScreenIdleTimer];
}

- (void)_showProtectedDataUnavailable:(PWWidget *)widget presented:(BOOL)presented {
	
	if (widget == nil) return;
	
	if (presented) {
		
		// not being dismissed or presented
		if (!_isAnimating) {
			
			BOOL requiresProtectedDataAccess = widget.requiresProtectedDataAccess;
			if (requiresProtectedDataAccess) {
				
				// show the message
				PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:@"Protected Data Unavailable" message:[NSString stringWithFormat:@"As this widget \"%@\" requires access to protected data on your device, it is now dismissed to prevent any data corruption.", widget.displayName] buttonTitle:nil defaultValue:nil cancelButtonTitle:@"Dismiss" style:UIAlertViewStyleDefault completion:nil];
				[alertView show];
				[alertView release];
				
				// dismiss the widget rightaway
				[self _dismissWidget];
			}
		}
		
	} else {
		
		// show the message
		PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:@"Protected Data Unavailable" message:[NSString stringWithFormat:@"Unable to present widget \"%@\" because it requires access to protected data on your device.", widget.displayName] buttonTitle:nil defaultValue:nil cancelButtonTitle:@"Dismiss" style:UIAlertViewStyleDefault completion:nil];
		[alertView show];
		[alertView release];
	}
}

- (void)_recordInitialTime {
	_initialTime = [[NSDate date] retain];
}

- (void)_outputDuration {
	NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:_initialTime];
	DURATIONLOG(@"PWController: _outputDuration: %f", duration);
	[_initialTime release], _initialTime = nil;
}

- (void)_applyParallaxEffect {
	
	if ([_mainView.motionEffects count] > 0) return;
	
	// create vertical effect
	UIInterpolatingMotionEffect *vertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	vertical.minimumRelativeValue = @(-PWSheetMotionEffectDistance);
	vertical.maximumRelativeValue = @(PWSheetMotionEffectDistance);
	
	// create horizontal effect
	UIInterpolatingMotionEffect *horizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontal.minimumRelativeValue = @(-PWSheetMotionEffectDistance);
	horizontal.maximumRelativeValue = @(PWSheetMotionEffectDistance);
	
	// add both effects to the view
	UIMotionEffectGroup *group = [UIMotionEffectGroup new];
	group.motionEffects = @[horizontal, vertical];
	[_mainView addMotionEffect:group];
	[group release];
}

- (void)_removeParallaxEffect {
	if ([_mainView.motionEffects count] > 0) {
		UIMotionEffectGroup *group = _mainView.motionEffects[0];
		[_mainView removeMotionEffect:group];
	}
}

- (NSArray *)_installedBundlesOfType:(NSString *)type infoSelector:(SEL)infoSelector {
	
	NSMutableArray *result = [NSMutableArray array];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *path = [NSString stringWithFormat:@"%@/%@/", [self.class basePath], type];
	
	BOOL isDir = NO;
	if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
		LOG(@"PWController: Directory does not exist at '%@'.", path);
		return result;
	}
	
	NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:[NSURL URLWithString:path]
								 includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
													options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants
											   errorHandler:nil];
	
	for (NSURL *url in enumerator) {
		
		NSString *fileName;
		[url getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
		
		NSNumber *isDir;
		[url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:NULL];
		
		if ([isDir boolValue] && [fileName hasSuffix:@".bundle"]) {
			NSBundle *bundle = [NSBundle bundleWithURL:url];
			if (bundle != nil) {
				NSDictionary *dict = [self performSelector:infoSelector withObject:bundle];
				if (dict != nil) {
					[result addObject:dict];
				}
			}
		}
	}
	
	return [[result copy] autorelease];
}

//////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (oneway void)release {}
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }

@end