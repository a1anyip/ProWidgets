//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWebRequestWrapper.h"
#import "PWJSBridge.h"
#import "../PWWebRequest.h"
#import "../PWWebRequestFileFormData.h"
#import "../PWWidget.h"

@implementation PWJSBridgeWebRequestWrapper

- (instancetype)initWithJSBridge:(PWJSBridge *)bridge {
	if ((self = [super init])) {
		_bridge = bridge;
	}
	return self;
}

- (PWWebRequest *)send:(JSValue *)url :(JSValue *)method :(JSValue *)params :(JSValue *)headers :(JSValue *)callback {
	
	if ([url isUndefined]) {
		[_bridge throwException:@"send: requires argument 1 (url)."];
		return nil;
	}
	
	NSURL *_url = [NSURL URLWithString:[url toString]];
	NSString *_method = [method isString] ? [method toString] : nil;
	id _params = nil;
	NSDictionary *_headers = [headers toDictionary];
	
	if (![params isUndefined]) {
		if ([params isString]) {
			_params = [params toString];
		} else {
			_params = [params toDictionary];
		}
	}
	
	// create JSManagedValue
	JSManagedValue *callbackValue = nil;
	if (![callback isUndefined]) {
		callbackValue = [JSManagedValue managedValueWithValue:callback];
		[_bridge.context.virtualMachine addManagedReference:callbackValue withOwner:_bridge];
	}
	
	PWWebRequest *request = [PWWebRequest new];
	[request _setCallback:callbackValue];
	[request _sendRequestWithURL:_url method:_method params:_params headers:_headers];
	
	return [request autorelease];
}

- (PWWebRequestFileFormData *)createFileFormData:(JSValue *)filename :(JSValue *)contentType {
	
	if ([filename isUndefined]) {
		[_bridge throwException:@"createFileFormData: requires argument 1 (filename)."];
		return nil;
	}
	
	NSString *_filename = [filename toString];
	NSString *_contentType = [contentType isUndefined] ? nil : [contentType toString];
	NSBundle *_bundle = _bridge.widgetRef.bundle;
	
	return [PWWebRequestFileFormData createWithFilename:_filename contentType:_contentType inBundle:_bundle];
}

@end