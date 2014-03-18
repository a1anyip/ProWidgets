//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <notify.h>
#import <sys/utsname.h>
#import <OBJCIPC/IPC.h>

#import "WelcomeScreen/PWWSWindow.h"

#import "PWController.h"
#import "PWTestBar.h"
#import "PWMiniView.h"

#import "PWWindow.h"
#import "PWView.h"
#import "PWBackgroundView.h"

#import "PWWidget.h"
#import "PWWidgetJS.h"
#import "PWContentViewController.h"

#import "PWScript.h"

#import "PWTheme.h"
#import "PWThemePlistParser.h"

#import "PWWidgetController.h"

static BOOL configured = NO;
static PWController *sharedInstance = nil;

static inline void reloadPref(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[PWController sharedInstance] _reloadPreference];
}

static inline void showWelcomeScreen(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[PWController sharedInstance] _showWelcomeScreen];
}

@implementation PWController

+ (void)load {
	
	// add observer to reload preference
	CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
	CFNotificationCenterAddObserver(center, NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, 0);
	
	if (objc_getClass("SpringBoard")) {
		CFNotificationCenterAddObserver(center, NULL, &showWelcomeScreen, CFSTR(PWShowWelcomeScreenNotification), NULL, 0);
	}
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
	
	// prevent this from being called for multiple times
	if (_lastDidChangeToOrientation == activeInterfaceOrientation) {
		return;
	} else {
		_lastDidChangeToOrientation = activeInterfaceOrientation;
	}
	
	if (_interfaceOrientationIsLocked)
		return;
	
	void(^completionHandler)(BOOL) = ^(BOOL finished) {
		
		LOG(@"PWController: _lastFirstResponder: %@", _lastFirstResponder);
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
			
			if (finished) {
				[_lastFirstResponder becomeFirstResponder];
			}
			
			RELEASE(_lastFirstResponder)
		});
	};
	
	[_lastFirstResponder resignFirstResponder];
	[_window endEditing:YES];
	
	[UIView animateWithDuration:duration animations:^{
		[_window adjustLayout];
	} completion:completionHandler];
}

- (void)activeInterfaceOrientationWillChangeToOrientation:(UIInterfaceOrientation)activeInterfaceOrientation {
	LOG(@"PWController: activeInterfaceOrientationWillChangeToOrientation: %d", (int)activeInterfaceOrientation);
	
	// prevent this from being called for multiple times
	if (_lastWillChangeToOrientation == activeInterfaceOrientation) {
		return;
	} else {
		_lastWillChangeToOrientation = activeInterfaceOrientation;
	}
	
	if (!_interfaceOrientationIsLocked) {
	
		if (_lastFirstResponder != nil) {
			RELEASE(_lastFirstResponder)
		}
		
		_lastFirstResponder = [[_window firstResponder] retain];
	}
	
	[_window endEditing:YES];
	[[objc_getClass("SBUIController") sharedInstance] _hideKeyboard]; // force to hide keyboard
}

//////////////////////////////////////////////////////////////////////

/**
 * General bundle loaders
 **/

+ (NSBundle *)bundleNamed:(NSString *)name ofType:(NSString *)type extension:(NSString *)extension {
	
	// trim the bundle name
	name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// validate the bundle name (to avoid directory traversal)
	if ([name isEqualToString:@"."] ||
		[name rangeOfString:@".."].location != NSNotFound ||
		[name rangeOfString:@"/"].location != NSNotFound ||
		[name rangeOfString:@"\\"].location != NSNotFound) {
		LOG(@"Unable to load %@ (%@). Reason: Invalid bundle name", extension, name);
		return nil;
	}
	
	// get the full path of widget bundle
	NSString *path = [NSString stringWithFormat:@"%@/%@/%@.%@/", [self.class basePath], type, name, extension];
	
	// check if the folder exists
	BOOL isDir = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		NSBundle *bundle = [NSBundle bundleWithPath:path];
		if (bundle != nil) {
			return bundle;
		} else {
			LOG(@"Unable to load %@ (%@). Reason: Fail to load its bundle (%@)", extension, name, bundle);
		}
	} else {
		LOG(@"Unable to load %@ (%@). Reason: Bundle path does not exist (%@)", extension, name, path);
	}
	
	return nil;
}

+ (NSBundle *)widgetBundleNamed:(NSString *)name {
	return [self bundleNamed:name ofType:@"Widgets" extension:@"widget"];
}

+ (NSBundle *)scriptBundleNamed:(NSString *)name {
	return [self bundleNamed:name ofType:@"Scripts" extension:@"script"];
}

+ (NSBundle *)themeBundleNamed:(NSString *)name {
	return [self bundleNamed:name ofType:@"Themes" extension:@"theme"];
}

+ (NSBundle *)activationMethodBundleNamed:(NSString *)name {
	return [self bundleNamed:name ofType:@"ActivationMethods" extension:@"bundle"];
}

//////////////////////////////////////////////////////////////////////

+ (BOOL)shouldShowBackgroundView {
	return ![self isIPad];
}

+ (BOOL)shouldMaskBackgroundView {
	return !IS_IPHONE4 && ![PWController sharedInstance]._disabledMask;
}

+ (BOOL)shouldMinimizeAllControllersAutomatically {
	return ![PWController isIPad];
}

+ (BOOL)supportsDragging {
	return [self isIPad];
}

+ (BOOL)supportsMultipleWidgetsOnScreen {
	return [self isIPad];
}

+ (BOOL)protectedDataAvailable {
	int unlockState = MKBGetDeviceLockState(NULL);
	return unlockState == DeviceLockStateUnlockedWithPasscode || unlockState == DeviceLockStateUnlockedWithoutPasscode;
}

+ (NSString *)deviceModel {
	struct utsname systemInfo;
	uname(&systemInfo);
	return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
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

+ (NSBundle *)localizationBundle {
	return [PWController sharedInstance].localizationBundle;
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
	
	if (_interfaceOrientationIsLocked) {
		return _lockedInterfaceOrientation;
	} else {
		// more efficient and reliable way to retrieve latest active interface orientation
		return _lastWillChangeToOrientation;
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
	
	CGFloat availableHeight = screenHeight - keyboardHeight;
	
	// just to make sure the sheet on iPad is not too large
	if ([PWController isIPad]) {
		if (orientation == PWWidgetOrientationPortrait) {
			availableHeight /= 2.0;
		} else if (orientation == PWWidgetOrientationLandscape) {
			availableHeight *= 4.0 / 5.0;
		}
	}
	
	// make the margin smaller on iPhone
	if (![PWController isIPad] && isLandscape)
		margin /= 2.0;
	
	return availableHeight - margin;
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

- (NSString *)commonLocalizedStringForPreferences:(NSArray *)preferences key:(NSString *)key {
	
	if (key == nil) return nil;
	
	NSBundle *localizationBundle = [self localizationBundle];
	
	if (_localizations == nil) {
		_localizations = [localizationBundle.localizations copy];
	}
	
	NSArray *commonPreferredLocalizations = [NSBundle preferredLocalizationsFromArray:_localizations forPreferences:preferences];
	if ([commonPreferredLocalizations count] == 0) return nil;
	
	NSString *locale = commonPreferredLocalizations[0];
	NSMutableDictionary *cache = _cachedCommonLocalizations[locale];
	
	// return cached localized string
	if (cache != nil) {
		LOG(@"*** Return cached localizations in commonLocalizedStringForPreferences");
		return cache[key];
	}
	
	NSString *commonTablePath = [NSString stringWithFormat:@"%@/%@.lproj/Common.strings", localizationBundle.bundlePath, commonPreferredLocalizations[0]];
	NSDictionary *commonBundleLocalization = [NSDictionary dictionaryWithContentsOfFile:commonTablePath];
	NSString *commonLocalizedString = commonBundleLocalization[key];
	
	// cache the retrieved dictionary for a specific locale
	if (commonBundleLocalization != nil) {
		if (_cachedCommonLocalizations == nil) _cachedCommonLocalizations = [NSMutableDictionary new];
		_cachedCommonLocalizations[locale] = commonBundleLocalization;
	}
	
	// return the localized string
	return commonLocalizedString;
}

- (PWView *)mainView {
	return (PWView *)self.view;
}

- (PWBackgroundView *)backgroundView {
	return self.mainView.backgroundView;
}

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)init {
	if ((self = [super init])) {
		
		// prepare bundles
		_baseBundle = [[NSBundle bundleWithPath:PWBaseBundlePath] retain];
		_localizationBundle = [[NSBundle bundleWithPath:[NSString stringWithFormat:@"%@/Localization/", PWBaseBundlePath]] retain];
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
	
	if (configured) return;
	configured = YES;
	
	// construct UI
	[self _constructUI];
	
	// show welcome screen, if needed
	/*if (YES) {
		[self _showWelcomeScreen];
	}*/
	
	// remove all observers, just in case (prevent duplicated observers)
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	// add notification observers
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShowHandler:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_lockStateChangedHandler:) name:@"SBDeviceLockStateChangedNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_protectedDataWillBecomeUnavailableHandler:) name:UIApplicationProtectedDataWillBecomeUnavailable object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_protectedDataDidBecomeAvailableHandler:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
	
	[OBJCIPC registerIncomingMessageFromAppHandlerForMessageName:@"prowidgets.presentwidget" handler:^NSDictionary *(NSDictionary *dict) {
		NSString *name = dict[@"name"];
		NSDictionary *userInfo = dict[@"userInfo"];
		if (name != nil) {
			[PWWidgetController presentWidgetNamed:name userInfo:userInfo];
		}
		return nil;
	}];
}

- (void)_constructUI {
	
	// build window
	_window = [PWWindow new];
	
	// build view
	_mainView = (PWView *)self.view; // +1
	
	// add parallax effect
	if (_enabledParallax)
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
	
	if (dict == nil || [dict[@"showedWelcomeScreen"] boolValue]) {
		_showedWelcomeScreen = YES;
	}
	
	// Lock Action
	NSNumber *lockAction = dict[@"lockAction"];
	_lockAction = [lockAction unsignedIntegerValue] == 1 ? PWLockActionDismiss : PWLockActionMinimize;
	
	// Minimization View Size (miniViewScale)
	NSNumber *miniViewScale = dict[@"miniViewScale"];
	_miniViewScale = miniViewScale == nil || ![miniViewScale isKindOfClass:[NSNumber class]] ? .3 : [miniViewScale doubleValue];
	
	// limit the scale (acceptable range: 0.2 to 0.5)
	_miniViewScale = MAX(.2, MIN(_miniViewScale, .5));
	
	// Parallax Effect
	NSNumber *enabledParallax = dict[@"enabledParallax"];
	_enabledParallax = enabledParallax == nil || ![enabledParallax isKindOfClass:[NSNumber class]] ? YES : [enabledParallax boolValue];
	
	// Disable Blur Effect
	NSNumber *disabledBlur = dict[@"disabledBlur"];
	_disabledBlur = disabledBlur == nil || ![disabledBlur isKindOfClass:[NSNumber class]] ? NO : [disabledBlur boolValue];
	
	if (IS_IPHONE4) {
		// On iPhone 4, all blur effects must be disabled to have better perfomance
		_disabledBlur = YES;
	}
	
	// Better Blur Quality (disabledMask)
	NSNumber *disabledMask = dict[@"disabledMask"];
	_disabledMask = disabledMask == nil || ![disabledMask isKindOfClass:[NSNumber class]] ? NO : [disabledMask boolValue];
	
	// Preferred Source
	NSNumber *preferredSource = dict[@"preferredSource"];
	_preferredSource = preferredSource == nil || ![preferredSource isKindOfClass:[NSNumber class]] ? 0 : [preferredSource unsignedIntegerValue]; // default is iCloud
	
	// Test Mode
	NSNumber *testMode = dict[@"testMode"];
	_testMode = testMode == nil || ![testMode isKindOfClass:[NSNumber class]] ? NO : [testMode boolValue];
	
	// Visible widget order
	NSArray *visibleWidgetOrder = dict[@"visibleWidgetOrder"];
	[_visibleWidgetOrder release];
	_visibleWidgetOrder = [visibleWidgetOrder copy];
	
	if (visibleWidgetOrder == nil) {
		// default set of built-in widgets
		_visibleWidgetOrder = [@[@"Calendar", @"Reminders", @"Notes", @"Browser", @"Messages", @"Mail", @"Dictionary", @"Alarm", @"Timer"] copy];
	}
	
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
	if (_enabledParallax) {
		[self _applyParallaxEffect];
	} else {
		[self _removeParallaxEffect];
	}
}

/**
 * Notification handlers
 **/

- (void)_keyboardWillShowHandler:(NSNotification *)notification {
	
	if (![PWWidgetController isPresentingWidget]) return;
	
	NSDictionary *userInfo = [notification userInfo];
	CGRect rect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat height = [self.class isLandscape] ? rect.size.width : rect.size.height;
	LOG(@"PWController: _keyboardWillShowHandler <keyboard height: %.2f>", height);
	
	for (PWWidgetController *controller in [PWWidgetController allControllers]) {
		[controller _keyboardWillShowHandler:height];
	}
}

- (void)_keyboardWillHideHandler:(NSNotification *)notification {
	if (![PWWidgetController isPresentingWidget]) return;
	for (PWWidgetController *controller in [PWWidgetController allControllers]) {
		[controller _keyboardWillHideHandler];
	}
}

- (void)_lockStateChangedHandler:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSUInteger state = [userInfo[@"kSBNotificationKeyState"] unsignedIntegerValue];
	
	LOG(@"PWController: _lockStateChangedHandler <%d>", (int)state);
	
	// locked
	if (state == DeviceLockStateLocked) {
		
		if (_lockAction == PWLockActionMinimize) {
			[PWWidgetController minimizeAllControllers];
		} else if (_lockAction == PWLockActionDismiss) {
			[PWWidgetController dismissAllControllers:YES];
		}
		
		// unlock the interface orientation immediately
		self.interfaceOrientationIsLocked = NO;
		
		// force window to update orientation
		[_window adjustLayout];
	}
}

- (void)_protectedDataWillBecomeUnavailableHandler:(NSNotification *)notification {
	LOG(@"PWController: _protectedDataWillBecomeUnavailableHandler");
	if (![PWWidgetController isPresentingWidget]) return;
	for (PWWidgetController *controller in [PWWidgetController allControllers]) {
		[controller _protectedDataWillBecomeUnavailableHandler];
	}
}

- (void)_protectedDataDidBecomeAvailableHandler:(NSNotification *)notification {
	LOG(@"PWController: _protectedDataDidBecomeAvailableHandler");
}

/*
- (void)_presentWidgetHandler:(NSNotification *)notification {
	
	NSObject *object = [notification object];
	NSDictionary *userInfo = [notification userInfo];
	
	LOG(@"PWController: _presentWidgetHandler: %@, %@", object, userInfo);
	
	BOOL isString = [object isKindOfClass:[NSString class]];
	BOOL isBundle = [object isKindOfClass:[NSBundle class]];
	BOOL isWidget = [object isKindOfClass:[PWWidget class]];
	
	if (object == nil || !(isString || isBundle || isWidget)) {
		LOG(@"Unable to present widget through notification. Reason: Invalid notification object, must be any of (string, bundle, PWWidget) (%@)", object);
		return;
	}
	
	if (isString)
		[PWWidgetController presentWidgetNamed:(NSString *)object userInfo:userInfo];
	else if (isBundle)
		[PWWidgetController presentWidgetFromBundle:(NSBundle *)object userInfo:userInfo];
	else if (isWidget)
		[PWWidgetController presentWidget:(PWWidget *)object userInfo:userInfo];
}
*/

//////////////////////////////////////////////////////////////////////

/**
 * Theme
 **/

- (NSString *)defaultThemeName {
	return _defaultThemeName == nil || [_defaultThemeName length] == 0 ? @"Blur" : _defaultThemeName;
}

- (PWTheme *)loadDefaultThemeForWidget:(PWWidget *)widget {
	// load default theme
	return [self loadThemeNamed:[self defaultThemeName] forWidget:widget];
}

- (PWTheme *)loadThemeNamed:(NSString *)name forWidget:(PWWidget *)widget {
	
	LOG(@"PWController: loadThemeNamed: %@ forWidget: %@", name, widget);
	
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
		NSBundle *bundle = [self.class themeBundleNamed:name];
		
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
					theme = [[PWThemePlistParser parse:plistDict inBundle:bundle forWidget:widget] retain];
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
		theme.widget = widget;
		theme.disabledBlur = _disabledBlur;
		return [theme autorelease];
	}
	
	return nil;
}

//////////////////////////////////////////////////////////////////////

/**
 * Script
 **/

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
	
	NSBundle *bundle = [self.class scriptBundleNamed:name];
	
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
	NSBundle *bundle = [self.class widgetBundleNamed:name];
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
	NSString *displayName = INFOT(info[@"PWInfoDisplayName"], bundle);
	if (displayName == nil) displayName = widgetName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoShortDescription
	NSString *shortDescription = INFOT(info[@"PWInfoShortDescription"], bundle);
	
	// PWInfoDescription
	NSString *description = INFOT(info[@"PWInfoDescription"], bundle);
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
	
	// PWInfoPreferenceBundle
	NSString *preferenceBundle = info[@"PWInfoPreferenceBundle"];
	if (preferenceBundle == nil) preferenceBundle = @"";
	
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
			 @"shortDescription": (shortDescription == nil ? description : shortDescription),
			 @"description": description,
			 @"enableActivation": enableActivation,
			 @"iconFile": iconFile,
			 @"maskFile": maskFile,
			 @"hasPreference": @([preferenceFile length] > 0 || [preferenceBundle length] > 0),
			 @"preferenceDefaults": preferenceDefaults,
			 @"preferenceFile": preferenceFile,
			 @"preferenceBundle": preferenceBundle,
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
	NSBundle *bundle = [self.class scriptBundleNamed:name];
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
	NSString *displayName = INFOT(info[@"PWInfoDisplayName"], bundle);
	if (displayName == nil) displayName = scriptName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoShortDescription
	NSString *shortDescription = INFOT(info[@"PWInfoShortDescription"], bundle);
	
	// PWInfoDescription
	NSString *description = INFOT(info[@"PWInfoDescription"], bundle);
	if (description == nil) description = @"";
	
	// PWInfoPreferenceDefaults
	NSString *preferenceDefaults = info[@"PWInfoPreferenceDefaults"];
	if (preferenceDefaults == nil) preferenceDefaults = @"";
	
	// PWInfoPreferenceFile
	NSString *preferenceFile = info[@"PWInfoPreferenceFile"];
	if (preferenceFile == nil) preferenceFile = @"";
	
	// PWInfoPreferenceBundle
	NSString *preferenceBundle = info[@"PWInfoPreferenceBundle"];
	if (preferenceBundle == nil) preferenceBundle = @"";
	
	// check if the widget is installed via URL
	NSString *indicatorPath = [NSString stringWithFormat:@"%@/.installed", [bundle bundlePath]];
	NSNumber *installedViaURL = @([[NSFileManager defaultManager] fileExistsAtPath:indicatorPath]);
	
	return @{
			 @"name": scriptName,
			 @"displayName": displayName,
			 @"author": author,
			 @"shortDescription": (shortDescription == nil ? description : shortDescription),
			 @"description": description,
			 @"hasPreference": @([preferenceFile length] > 0 || [preferenceBundle length] > 0),
			 @"preferenceDefaults": preferenceDefaults,
			 @"preferenceFile": preferenceFile,
			 @"preferenceBundle": preferenceBundle,
			 @"bundle": bundle,
			 @"installedViaURL": installedViaURL
			 };
}

- (NSDictionary *)infoOfThemeNamed:(NSString *)name {
	NSBundle *bundle = [self.class themeBundleNamed:name];
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
	NSString *displayName = INFOT(info[@"PWInfoDisplayName"], bundle);
	if (displayName == nil) displayName = themeName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoShortDescription
	NSString *shortDescription = INFOT(info[@"PWInfoShortDescription"], bundle);
	
	// PWInfoDescription
	NSString *description = INFOT(info[@"PWInfoDescription"], bundle);
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
			 @"shortDescription": (shortDescription == nil ? description : shortDescription),
			 @"description": description,
			 @"iconFile": iconFile,
			 @"bundle": bundle,
			 @"installedViaURL": installedViaURL
			 };
}

- (NSDictionary *)infoOfActivationMethodNamed:(NSString *)name {
	NSBundle *bundle = [self.class activationMethodBundleNamed:name];
	return [self infoOfActivationMethodInBundle:bundle];
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
	NSString *displayName = INFOT(info[@"PWInfoDisplayName"], bundle);
	if (displayName == nil) displayName = methodName;
	
	// PWInfoAuthor
	NSString *author = info[@"PWInfoAuthor"];
	if (author == nil) author = @"";
	
	// PWInfoShortDescription
	NSString *shortDescription = INFOT(info[@"PWInfoShortDescription"], bundle);
	
	// PWInfoDescription
	NSString *description = INFOT(info[@"PWInfoDescription"], bundle);
	if (description == nil) description = @"";
	
	// PWInfoPreferenceFile
	NSString *preferenceFile = info[@"PWInfoPreferenceFile"];
	if (preferenceFile == nil) preferenceFile = @"";
	
	// PWInfoPreferenceBundle
	NSString *preferenceBundle = info[@"PWInfoPreferenceBundle"];
	if (preferenceBundle == nil) preferenceBundle = @"";
	
	return @{
			 @"name": methodName,
			 @"displayName": displayName,
			 @"author": author,
			 @"shortDescription": (shortDescription == nil ? description : shortDescription),
			 @"description": description,
			 @"hasPreference": @([preferenceFile length] > 0 || [preferenceBundle length] > 0),
			 @"preferenceFile": preferenceFile,
			 @"preferenceBundle": preferenceBundle,
			 @"bundle": bundle
			 };
}

- (UIImage *)iconOfWidgetNamed:(NSString *)name {
	NSBundle *bundle = [self.class widgetBundleNamed:name];
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
	NSBundle *bundle = [self.class themeBundleNamed:name];
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
	NSBundle *bundle = [self.class widgetBundleNamed:name];
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
	return [self _installedBundlesOfType:@"Widgets" extension:@"widget" infoSelector:@selector(infoOfWidgetInBundle:)];
}

- (NSArray *)enabledWidgets {
	return [self _installedBundlesOfType:@"Widgets" extension:@"widget" infoSelector:@selector(infoOfEnabledWidgetInBundle:)];
}

- (NSDictionary *)enabledWidgetsWithCategories {
	
	NSArray *unsorted = [self enabledWidgets];
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
	return [self enabledWidgetsWithCategories][@"visible"];
}

- (NSArray *)hiddenWidgets {
	return [self enabledWidgetsWithCategories][@"hidden"];
}

- (NSArray *)installedScripts {
	return [self _installedBundlesOfType:@"Scripts" extension:@"script" infoSelector:@selector(infoOfScriptInBundle:)];
}

- (NSArray *)installedThemes {
	return [self _installedBundlesOfType:@"Themes" extension:@"theme" infoSelector:@selector(infoOfThemeInBundle:)];
}

- (NSArray *)activationMethods {
	return [self _installedBundlesOfType:@"ActivationMethods" extension:@"bundle" infoSelector:@selector(infoOfActivationMethodInBundle:)];
}

//////////////////////////////////////////////////////////////////////

/**
 * Private methods
 **/

+ (BOOL)_checkAPIEnvironment {
	static BOOL checked = NO;
	static BOOL result = NO;
	if (!checked) {
		checked = YES;
		result = objc_getClass("SpringBoard") != nil;
	}
	return result;
}

- (BOOL)_showingWelcomeScreen {
	return _showingWelcomeScreen;
}

- (void)_firstTimeShowWelcomeScreen {
	
	if (!_showedWelcomeScreen) {
		
		// update preference file
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PWPrefPath];
		if (dict == nil) dict = [NSMutableDictionary new];
		dict[@"showedWelcomeScreen"] = @(YES);
		[dict writeToFile:PWPrefPath atomically:YES];
		[dict release];
		
		// show welcome screen
		[self _showWelcomeScreen];
	}
}

- (void)_showWelcomeScreen {
	if (!_showingWelcomeScreen) {
		_showingWelcomeScreen = YES;
		_welcomeScreen = [PWWSWindow new];
		[_welcomeScreen show];
	}
}

- (void)_hideWelcomeScreen {
	if (_showingWelcomeScreen) {
		_showingWelcomeScreen = NO;
		[_welcomeScreen hide];
		RELEASE(_welcomeScreen)
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

- (NSArray *)_installedBundlesOfType:(NSString *)type extension:(NSString *)extension infoSelector:(SEL)infoSelector {
	
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
		
		if ([isDir boolValue] && [fileName hasSuffix:[NSString stringWithFormat:@".%@", extension]]) {
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

- (BOOL)_disabledMask {
	return _disabledMask;
}

- (CGFloat)_miniViewScale {
	return _miniViewScale;
}

//////////////////////////////////////////////////////////////////////

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (oneway void)release {}
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }

@end