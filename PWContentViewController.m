//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWContentViewController.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import "PWWidget.h"
#import "PWEventHandler.h"
#import "PWWidgetPlistParser.h"

@implementation PWContentViewController

+ (NSString *)actionEventName {
	return @"PWContentViewControllerActionEvent";
}

+ (NSString *)titleTappedEventName {
	return @"PWContentViewControllerTitleTappedEvent";
}

- (BOOL)_viewControllerUnderlapsStatusBar {
	return NO;
}

- (float)_statusBarHeightAdjustmentForCurrentOrientation {
	return 0.0;
}

- (instancetype)init {
	LOG(@"PWContentViewController: Instance must be initialized with initForWidget: method");
	[self release];
	return nil;
}

- (instancetype)initForWidget:(PWWidget *)widget {
	if ((self = [self _initForWidget:widget])) {
		[self load];
	}
	return self;
}

- (instancetype)_initForWidget:(PWWidget *)widget {
	if ((self = [super init])) {
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.edgesForExtendedLayout = UIRectEdgeNone;
		self.extendedLayoutIncludesOpaqueBars = NO;
		[self _setWidget:widget];
	}
	return self;
}

- (void)_setWidget:(PWWidget *)widget {
	if (_widget != nil) return;
	_widget = widget;
}

- (PWWidget *)widget {
	return _widget;
}

- (PWTheme *)theme {
	return _widget.theme;
}

- (void)load {}

- (BOOL)loadPlist:(NSString *)filename {
	
	LOG(@"PWContentViewController: Load plist named (%@)", filename);
	
	PWWidget *widget = self.widget;
	NSString *path = [widget _pathOfPlist:filename];
	NSDictionary *dict = [widget _loadPlistAtPath:path];
	if (dict == nil) return NO;
	
	[PWWidgetPlistParser parse:dict forContentViewController:self];
	return YES;
}

- (BOOL)isTopViewController {
	return self.widget.topViewController == self;
}

- (void)keyboardWillShow:(CGFloat)height {}
- (void)keyboardWillHide {}
- (void)configureFirstResponder {}

// title
- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	self.navigationItem.title = title;
}

// button configurations
- (NSString *)closeButtonText {
	return _closeButtonText == nil ? @"Close" : _closeButtonText;
}

- (void)setCloseButtonText:(NSString *)buttonText {
	
	LOG(@"PWWidget: Set close button text to (%@)", buttonText);
	
	// update configuration
	[_closeButtonText release];
	_closeButtonText = [buttonText copy];
	
	// pass to container view
	_closeButtonItem.title = buttonText;
}

- (NSString *)actionButtonText {
	return _actionButtonText == nil ? @"Done" : _actionButtonText;
}

- (void)setActionButtonText:(NSString *)buttonText {
	
	LOG(@"PWWidget: Set action button text to (%@)", buttonText);
	
	// update configuration
	[_actionButtonText release];
	_actionButtonText = [buttonText copy];
	
	// pass to container view
	_actionButtonItem.title = buttonText;
}

- (void)configureCloseButton {
	
	if (_closeButtonItem != nil && [self.navigationItem.leftBarButtonItems containsObject:_closeButtonItem]) return;
	
	UIBarButtonItem *spacing = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	spacing.width = PWDefaultButtonMargin;
	
	if (_closeButtonItem == nil)
		_closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.closeButtonText style:UIBarButtonItemStylePlain target:self action:@selector(triggerClose)];
	
	// add the buttons and spacing to navigation bar
	self.navigationItem.leftBarButtonItems = @[spacing, _closeButtonItem];
}

- (void)configureActionButton {
	
	if (_actionButtonItem != nil && [self.navigationItem.rightBarButtonItems containsObject:_actionButtonItem]) return;
	
	UIBarButtonItem *spacing = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	spacing.width = PWDefaultButtonMargin;
	
	if (_actionButtonItem == nil)
		_actionButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.actionButtonText style:UIBarButtonItemStylePlain target:self action:@selector(triggerAction)];
	
	// add the buttons and spacing to navigation bar
	self.navigationItem.rightBarButtonItems = @[spacing, _actionButtonItem];
}

- (void)configureBackButton {
	if (self.navigationItem.backBarButtonItem == nil) {
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	}
}

- (void)configureStandardButtons {
	[self configureCloseButton];
	[self configureActionButton];
}

- (void)triggerClose {
	[self.widget dismiss];
}

- (void)triggerAction {
	[self triggerEvent:[self.class actionEventName] withObject:nil];
}

- (void)triggerEvent:(NSString *)event withObject:(id)object {
	
	if (event == nil || _eventHandlers == nil) return;
	
	LOG(@"PWContentViewController: Trigger event <name: %@> <object: %@>", event, object);
	PWEventHandler *handler = _eventHandlers[event];
	[handler triggerWithObject:object];
}

- (void)setHandlerForEvent:(NSString *)event target:(id)target selector:(SEL)selector {
	
	if (event == nil) return;
	if (_eventHandlers == nil) _eventHandlers = [NSMutableDictionary new];
	
	PWEventHandler *handler = [PWEventHandler eventHandlerWithTarget:target selector:selector];
	_eventHandlers[event] = handler;
}

- (void)setHandlerForEvent:(NSString *)event block:(void(^)(id))block {
	
	if (event == nil) return;
	if (_eventHandlers == nil) _eventHandlers = [NSMutableDictionary new];
	
	PWEventHandler *handler = [PWEventHandler eventHandlerWithBlock:block];
	_eventHandlers[event] = handler;
}

- (void)setActionEventHandler:(id)target selector:(SEL)selector {
	[self setHandlerForEvent:[self.class actionEventName] target:target selector:selector];
}

- (void)setActionEventBlockHandler:(void(^)(id))block {
	[self setHandlerForEvent:[self.class actionEventName] block:block];
}

// content width
- (CGFloat)contentWidthForOrientation:(PWWidgetOrientation)orientation {
	if (self.wantsFullscreen) {
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		return orientation == PWWidgetOrientationLandscape ? screenRect.size.height : screenRect.size.width;
	} else {
		return [[PWController sharedInstance] availableWidthInOrientation:orientation];
	}
}

// content height
// any sub class of PWContentViewController must override this method to return its content height
- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation {
	if (self.wantsFullscreen) {
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		return orientation == PWWidgetOrientationLandscape ? screenRect.size.width : screenRect.size.height;
	} else if (self.shouldMaximizeContentHeight) {
		PWController *controller = [PWController sharedInstance];
		CGFloat maxHeight = [controller availableHeightInOrientation:orientation withKeyboard:self.requiresKeyboard];
		CGFloat navigationBarHeight = [controller heightOfNavigationBarInOrientation:orientation];
		CGFloat availableHeight = MAX(1.0, maxHeight - navigationBarHeight);
		return availableHeight;
	} else {
		return 0.0;
	}
}

- (void)setWantsFullscreen:(BOOL)wantsFullscreen {
	if (_wantsFullscreen != wantsFullscreen) {
		_wantsFullscreen = wantsFullscreen;
		PWWidget *widget = self.widget;
		[widget resizeWidgetAnimated:YES forContentViewController:self];
	}
}

- (void)setShouldMaximizeContentHeight:(BOOL)shouldMaximizeContentHeight {
	if (_shouldMaximizeContentHeight != shouldMaximizeContentHeight) {
		_shouldMaximizeContentHeight = shouldMaximizeContentHeight;
		PWWidget *widget = self.widget;
		[widget resizeWidgetAnimated:YES forContentViewController:self];
	}
}

- (BOOL)requiresKeyboard {
	return _requiresKeyboard && !_wantsFullscreen;
}

- (void)setRequiresKeyboard:(BOOL)requiresKeyboard {
	if (_requiresKeyboard != requiresKeyboard) {
		_requiresKeyboard = requiresKeyboard;
		PWWidget *widget = self.widget;
		[widget resizeWidgetAnimated:YES forContentViewController:self];
	}
}

- (void)_willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	// auto update title
	PWWidget *widget = self.widget;
	NSString *title = self.title == nil ? widget.title : self.title;
	self.navigationItem.title = title;
	
	// auto configure standard buttons if needed
	if (self.shouldAutoConfigureStandardButtons) {
		[self configureStandardButtons];
	}
	
	// configure back button
	[self configureBackButton];
}

- (void)_presentedInNavigationController:(UINavigationController *)navigationController {}

- (void)_dealloc {
	LOG(@"PWContentViewController: _dealloc");
	_widget = nil;
	RELEASE(_closeButtonItem)
	RELEASE(_actionButtonItem)
	RELEASE(_closeButtonText)
	RELEASE(_actionButtonText)
	RELEASE(_eventHandlers)
}

- (void)dealloc {
	DEALLOCLOG;
	[self _dealloc];
	[super dealloc];
}

@end