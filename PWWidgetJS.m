//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetJS.h"
#import "JSBridge/PWJSBridge.h"
#import "JSBridge/PWJSBridgeWidgetWrapper.h"
#import "JSBridge/PWJSBridgeWidgetItemWrapper.h"

#define PW_IMP_HANDLER(ivar) - (void)ivar {\
	JSValue *callback = [_bridge.widget ivar];\
	if (callback != nil)\
		[callback callWithArguments:nil];\
	else\
		[super ivar];\
}

@implementation PWWidgetJS

- (instancetype)initWithJSFile:(NSString *)filename withName:(NSString *)name inBundle:(NSBundle *)bundle {
	if ((self = [super init])) {
		
		// set widget information
		self.name = name;
		self.bundle = bundle;
		
		// set JS file name
		self.filename = filename;
		
		// construct file path
		NSString *path = [NSString stringWithFormat:@"%@/%@", [bundle bundlePath], filename];
		self.path = path;
		
		// initialize JSBridge
		_bridge = [[PWJSBridge alloc] initWithWidget:self];
		
		// read JS file
		[_bridge readJSFile:path];
	}
	return self;
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {
	JSValue *callback = [_bridge.widget itemValueChangedEventHandler];
	if (callback != nil) {
		PWJSBridgeWidgetItemWrapper *wrapper = [PWJSBridgeWidgetItemWrapper wrapperOfItem:item];
		NSArray *arguments = nil;
		if (wrapper != nil && oldValue == nil) arguments = @[wrapper];
		if (wrapper != nil && oldValue != nil) arguments = @[wrapper, oldValue];
		[callback callWithArguments:arguments];
	}
}

- (void)submitEventHandler:(NSDictionary *)values {
	JSValue *callback = [_bridge.widget submitEventHandler];
	if (callback != nil) {
		[callback callWithArguments:(values == nil ? nil : @[values])];
	}
}

// Callback methods
PW_IMP_HANDLER(configure)
PW_IMP_HANDLER(load)
PW_IMP_HANDLER(willPresent)
PW_IMP_HANDLER(didPresent)
PW_IMP_HANDLER(willDismiss)
PW_IMP_HANDLER(didDismiss)

///// JS Bridge /////

- (void)dealloc {
	
	// release JSBridge
	[_bridge widgetDismissed];
	RELEASE(_bridge)
	
	// release file name and path
	RELEASE(_filename)
	RELEASE(_path)
	
	[super dealloc];
}

@end

@implementation PWContentItemViewControllerJS

// Callback method
PW_IMP_HANDLER(configureFirstResponder)

@end