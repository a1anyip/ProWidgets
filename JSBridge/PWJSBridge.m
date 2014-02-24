//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridge.h"
#import "PWJSBridgeConsoleWrapper.h"
#import "PWJSBridgeWidgetWrapper.h"
#import "PWJSBridgeScriptWrapper.h"
#import "PWJSBridgeWebRequestWrapper.h"
#import "PWJSBridgeFileWrapper.h"
#import "PWJSBridgePreferenceWrapper.h"
#import "../PWController.h"
#import "../PWWidget.h"
#import "../PWScript.h"

@implementation PWJSBridge

- (instancetype)initWithWidget:(PWWidget *)widget {
	if ((self = [super init])) {
		
		@autoreleasepool {
			
			// keep reference
			_widgetRef = widget;
			
			_consoleWrapper = [PWJSBridgeConsoleWrapper new];
			_widgetWrapper = [PWJSBridgeWidgetWrapper new];
			_requestWrapper = [PWJSBridgeWebRequestWrapper new];
			_fileWrapper = [PWJSBridgeFileWrapper new];
			_preferenceWrapper = [PWJSBridgePreferenceWrapper new];
			
			_consoleWrapper.bridge = self;
			_widgetWrapper.bridge = self;
			_requestWrapper.bridge = self;
			_fileWrapper.bridge = self;
			_preferenceWrapper.bridge = self;
			
			[self setupEnvironment];
			[self setupAPI];
		}
	}
	return self;
}

- (instancetype)initWithScript:(PWScript *)script {
	if ((self = [super init])) {
		
		@autoreleasepool {
			
			// keep reference
			_scriptRef = script;
			
			_consoleWrapper = [PWJSBridgeConsoleWrapper new];
			_scriptWrapper = [PWJSBridgeScriptWrapper new];
			_requestWrapper = [PWJSBridgeWebRequestWrapper new];
			_fileWrapper = [PWJSBridgeFileWrapper new];
			_preferenceWrapper = [PWJSBridgePreferenceWrapper new];
			
			_consoleWrapper.bridge = self;
			_scriptWrapper.bridge = self;
			_requestWrapper.bridge = self;
			_fileWrapper.bridge = self;
			_preferenceWrapper.bridge = self;
			
			[self setupEnvironment];
			[self setupAPI];
		}
	}
	return self;
}

- (void)setupEnvironment {
		
	// setup virtual machine and JS context
	_context = [JSContext new];
	
	// it is important to set an exception handler
	// or it will cause crashes when JSContext is released
	_context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
		LOG(@"PWJSBridge Exception: %@", exception);
	};
	
	// point console to PWJSBridgeConsoleWrapper
	_context[@"console"] = _consoleWrapper;
	
	// point "pw" to JSBridge
	_context[@"pw"] = self;
}

- (void)setupAPI {
	
	if (_api == nil) _api = [NSMutableDictionary new];
	
	NSDictionary *apis = @{@"message": @"PWAPIMessageWrapper",
						   @"mail": @"PWAPIMailWrapper",
						   @"calendar": @"PWAPICalendarWrapper",
						   @"note": @"PWAPINoteWrapper",
						   @"alarm": @"PWAPIAlarmManagerWrapper",
						   @"contact": @"PWAPIContactWrapper"
						   };
	
	for (NSString *apiName in apis) {
		NSString *className = apis[apiName];
		Class class = NSClassFromString(className);
		if (class != nil) {
			PWJSBridgeWrapper *instance = (PWJSBridgeWrapper *)[class new];
			instance.bridge = self;
			_api[apiName] = instance;
			[instance release];
		}
	}
}

- (void)readJSFile:(NSString *)path {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		LOG(@"PWJSBridge: JavaScript file does not exist at path '%@'.", path);
		return;
	}
	
	NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	// evaluate the script content
	[_context evaluateScript:content];
}

- (JSValue *)eval:(NSString *)script {
	return [_context evaluateScript:script];
}

- (PWBase *)baseRef {
	return _scriptRef != nil ? _scriptRef : _widgetRef;
}

- (int)version {
	return [PWController version];
}

- (NSString *)locale {
	NSArray *lang = [NSLocale preferredLanguages];
	return [lang count] > 0 ? lang[0] : nil;
}

- (PWJSBridgeWidgetWrapper *)widget {
	return _widgetWrapper;
}

- (PWJSBridgeScriptWrapper *)script {
	return _scriptWrapper;
}

- (PWJSBridgeWebRequestWrapper *)request {
	return _requestWrapper;
}

- (PWJSBridgeFileWrapper *)file {
	return _fileWrapper;
}

- (PWJSBridgePreferenceWrapper *)preference {
	return _preferenceWrapper;
}

- (NSDictionary *)api {
	return _api;
}

- (void)throwException:(NSString *)exception {
	LOG(@"PWJSBridge Exception: %@", exception);
}

- (void)widgetDismissed {
	LOG(@"PWJSBridge: widgetDismissed");
	[self _clearContext];
}

- (void)scriptExecuted {
	LOG(@"PWJSBridge: scriptExecuted");
	//[self _clearContext];
}

- (void)_clearContext {
	
	// clear reference
	_widgetRef = nil;
	//_scriptRef = nil;
	
	// release context
	_context[@"console"] = nil;
	_context[@"pw"] = nil;
	[_context release], _context = nil;
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	// release wrappers
	RELEASE(_consoleWrapper)
	RELEASE(_requestWrapper)
	RELEASE(_widgetWrapper)
	RELEASE(_fileWrapper)
	RELEASE(_preferenceWrapper)
	RELEASE(_api)
	
	[super dealloc];
}

@end