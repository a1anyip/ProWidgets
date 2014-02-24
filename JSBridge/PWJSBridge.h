//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "../header.h"

@protocol PWJSBridgeExport <JSExport>

@property(nonatomic, readonly) int version;
@property(nonatomic, readonly) NSString *locale;

@property(nonatomic, readonly) PWJSBridgeWidgetWrapper *widget;
@property(nonatomic, readonly) PWJSBridgeScriptWrapper *script;
@property(nonatomic, readonly) PWJSBridgeWebRequestWrapper *request;
@property(nonatomic, readonly) PWJSBridgeFileWrapper *file;
@property(nonatomic, readonly) PWJSBridgePreferenceWrapper *preference;
@property(nonatomic, readonly) NSDictionary *api;

@end

@interface PWJSBridge : NSObject<PWJSBridgeExport> {
	
	// JavaScript environment
	JSContext *_context;
	
	// widget reference
	PWWidget *_widgetRef;
	
	// script reference
	PWScript *_scriptRef;
	
	// wrappers
	PWJSBridgeConsoleWrapper *_consoleWrapper;
	PWJSBridgeWidgetWrapper *_widgetWrapper;
	PWJSBridgeScriptWrapper *_scriptWrapper;
	PWJSBridgeWebRequestWrapper *_requestWrapper;
	PWJSBridgeFileWrapper *_fileWrapper;
	PWJSBridgePreferenceWrapper *_preferenceWrapper;
	NSMutableDictionary *_api;
}

@property(nonatomic, readonly) PWBase *baseRef;
@property(nonatomic, assign) PWWidget *widgetRef;
@property(nonatomic, assign) PWScript *scriptRef;
@property(nonatomic, readonly) JSContext *context;

- (instancetype)initWithWidget:(PWWidget *)widget;
- (instancetype)initWithScript:(PWScript *)script;

- (void)setupEnvironment;
- (void)setupAPI;
- (void)readJSFile:(NSString *)path;
- (JSValue *)eval:(NSString *)script;

- (void)throwException:(NSString *)exception;
- (void)widgetDismissed;
- (void)scriptExecuted;

- (void)_clearContext;

@end