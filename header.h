#import "objc/objc.h"
#import "objc/runtime.h"
#import "interface.h"

#ifndef HEADER
#define HEADER

//////////////////////////////////////////////////////////////////////

// Configuration
#define LOG_DEBUG 1
#define LOG_DEALLOC 1
//#define LOG_DURATION 1

#define VERSION 100
#define PWPrefPath @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.plist"

#define PWMinimizationScale .3

#define PWBackgroundViewFadeDuration 0.1
#define PWBackgroundViewAlpha 0.5

#define PWAnimationDuration .28
#define PWMaxMinimizationDuration .3
#define PWTransitionAnimationDuration .15

#define PWSheetMotionEffectDistance 10.0
#define PWSheetHorizontalMargin 6.0
#define PWSheetVerticalMargin 6.0

#define PWDefaultButtonMargin 4.0
#define PWDefaultItemCellPadding 10.0

//////////////////////////////////////////////////////////////////////

// Handy marcos

#define CT(key) T(key,[PWController localizationBundle])
#define T(key,bundle)  ([bundle localizedStringForKey:key value:nil table:nil])
#define INFOT(key,bundle) ((key) == nil ? nil : (T(key,bundle)))

#define IS_IPHONE4 ([[PWController deviceModel] hasPrefix:@"iPhone3,"])
#define CHECK_API(x) if (![PWController _checkAPIEnvironment]) return x;

#define RELEASE(x) [x release], x = nil;
#define RELEASE_VIEW(x) [x removeFromSuperview], [x release], x = nil;

#ifdef LOG_DEBUG
#define LOG(x,...) NSLog(@"***** [ProWidgets] %@",[NSString stringWithFormat:(x), ##__VA_ARGS__])
#define METHODLOG LOG(@"---> [%@ %@]", self.class, NSStringFromSelector(_cmd))
#else
#define LOG(x,...)
#define METHODLOG
#endif

#ifdef LOG_DEALLOC
#define DEALLOCLOG NSLog(@"***** [ProWidgets] dealloc '%@' <%p>", self.class, self)
#else
#define DEALLOCLOG
#endif

#ifdef LOG_DURATION
#define DURATIONLOG(x,...) NSLog(@"***** [ProWidgets] %@",[NSString stringWithFormat:(x), ##__VA_ARGS__])
#else
#define DURATIONLOG(x,...)
#endif

//////////////////////////////////////////////////////////////////////

// Path
#define PWPrefPath @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.plist"
#define PWBaseBundlePath @"/Library/ProWidgets/"

// Notification names
#define PWShowWelcomeScreenNotification "PWShowWelcomeScreenNotification"
#define PWPresentWidgetNotification @"PWPresentWidgetNotification"
#define PWDismissWidgetNotification @"PWDismissWidgetNotification"

//////////////////////////////////////////////////////////////////////

// Controller
@class PWController, PWWidgetController, PWWidgetNavigationController;

// Core
@class PWTestBar, PWMiniView, PWBase, PWWindow, PWWSWindow, PWBackgroundView, PWView, PWContainerView, PWContentViewController, PWContentItemViewController, PWContentListViewController, PWEventHandler, PWThemableTableView, PWThemableTableViewCell, PWAlertView;

// Widget
@class PWWidget, PWWidgetJS, PWWidgetPlistParser, PWWidgetItem, PWWidgetItemCell;

// Script
@class PWScript;

// Theme Support
@class PWTheme, PWThemeParsed, PWThemePlistParser;

// Web Request
@class PWWebRequest, PWWebRequestFileFormData;

// JavaScript Bridge
@class PWJSBridge, PWJSBridgeWrapper, PWJSBridgeBaseWrapper, PWJSBridgeConsoleWrapper, PWJSBridgeWidgetWrapper, PWJSBridgeWidgetItemWrapper, PWJSBridgeScriptWrapper, PWJSBridgeWebRequestWrapper, PWJSBridgeFileWrapper, PWJSBridgePreferenceWrapper;

// API
@class PWAPIMailWrapper, PWAPIMail;
@class PWAPIMessageWrapper, PWAPIMessage;
@class PWAPIAlarmManagerWrapper, PWAPIAlarmWrapper, PWAPIAlarmManager, PWAPIAlarm;

//////////////////////////////////////////////////////////////////////

typedef enum {
	PWWidgetOrientationPortrait,
	PWWidgetOrientationLandscape
} PWWidgetOrientation;

typedef enum {
	PWWidgetLayoutDefault,
	PWWidgetLayoutCustom
} PWWidgetLayout;

typedef enum {
	PWWidgetCellTypeNormal,
	PWWidgetCellTypeTextArea
} PWWidgetCellType;

typedef enum {
	PWWidgetItemEventTextChanged,
	PWWidgetItemEventValueChanged,
	PWWidgetItemEventSwitchValueChanged
} PWWidgetItemEvent;

typedef enum {
	PWWidgetItemCellStyleNone,	// [                   ]
	PWWidgetItemCellStyleText,	// [ Title             ]
	PWWidgetItemCellStyleValue	// [ Title       Value ]
} PWWidgetItemCellStyle;

typedef enum {
	PWWidgetPresentationStyleZoom = 0,
	PWWidgetPresentationStyleFade = 1,
	PWWidgetPresentationStyleSlideUp = 2,
	PWWidgetPresentationStyleSlideDown = 3
} PWWidgetPresentationStyle;

//////////////////////////////////////////////////////////////////////

typedef enum {
	
	PWLockActionMinimize = 0,
	PWLockActionDismiss = 1
	
} PWLockAction;

enum  {
	DeviceLockStateUnlockedWithPasscode = 0,
	DeviceLockStateLocked = 1,
	DeviceLockStateTemporarilyUnlockedWithPasscode = 2, // still locked technically; will change to 1 soon
	DeviceLockStateUnlockedWithoutPasscode = 3
};

extern int MKBGetDeviceLockState(void *unknown);

extern int CalculatePerformExpression(const char* expr,
									  int significantDigits,
									  int flags,
									  char* answer);

static inline void applyFadeTransition(UIView *view, CGFloat duration) {
	CATransition *transition = [CATransition animation];
	transition.duration = duration;
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	transition.type = kCATransitionFade;
	[view.layer addAnimation:transition forKey:@"fade"];
}

static inline void *instanceVar(id object, const char *name) {
	Ivar ivar = object_getInstanceVariable(object, name, NULL);
	if (ivar) {
		return (void *)((char *)object + ivar_getOffset(ivar));
	}
	return NULL;
}

#endif