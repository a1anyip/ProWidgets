//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeBaseWrapper.h"
#import "PWJSBridge.h"
#import "../PWBase.h"

@implementation PWJSBridgeBaseWrapper

// Getters

- (NSString *)name {
	return [self.base name];
}

- (NSString *)displayName {
	return [self.base displayName];
}

- (NSDictionary *)info {
	return [self.base info];
}

- (NSDictionary *)userInfo {
	return [self.base userInfo];
}

// Helper methods
- (void)showMessage:(JSValue *)message :(JSValue *)title {
	
	if ([message isUndefined]) {
		[_bridge throwException:@"showMessage: requires argument 1 (message)."];
		return;
	}
	
	NSString *_message = [message toString];
	
	if ([title isUndefined]) {
		return [self.base showMessage:_message];
	}
	
	NSString *_msgTitle = [title toString];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.base showMessage:_message title:_msgTitle];
	});
}

- (void)prompt:(JSValue *)message :(JSValue *)title :(JSValue *)buttonTitle :(JSValue *)defaultValue :(JSValue *)style :(JSValue *)completion {
	
	if ([message isUndefined]) {
		[_bridge throwException:@"prompt: requires argument 1 (message)."];
		return;
	}
	
	// message
	NSString *_message = [message isNull] ? @"" : [message toString];
	
	// title
	NSString *_title = nil;
	if (![title isUndefined] && ![title isNull]) {
		_title = [title toString];
	}
	
	// button title
	NSString *_buttonTitle = nil;
	if (![buttonTitle isUndefined] && ![buttonTitle isNull]) {
		_buttonTitle = [buttonTitle toString];
	}
	
	// default value
	NSString *_defaultValue = nil;
	if (![defaultValue isUndefined] && ![defaultValue isNull]) {
		_defaultValue = [defaultValue toString];
	}
	
	// style
	NSUInteger _style = [style toUInt32];
	if (_style > 3) _style = 0; // reset
	UIAlertViewStyle alertViewStyle = (UIAlertViewStyle)_style;
	
	// completion
	PWAlertViewCompletionHandler handler = nil;
	if ([completion isObject]) {
		
		//__block PWBase *base = [self.base retain];
		__block PWJSBridge *bridge = [_bridge retain];
		__block JSContext *context = [_bridge.context retain];
		__block JSManagedValue *completionValue = [[JSManagedValue managedValueWithValue:completion] retain];
		[context.virtualMachine addManagedReference:completionValue withOwner:_bridge];
		
		handler = ^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
			
			if (completionValue != nil) {
				
				JSValue *callback = [completionValue value];
				
				if (callback != nil) {
					NSArray *arguments = nil;
					if (firstValue != nil && secondValue == nil) arguments = @[firstValue];
					else if (firstValue != nil && secondValue != nil) arguments = @[firstValue, secondValue];
					[callback callWithArguments:arguments];
				}
				
				[context.virtualMachine removeManagedReference:completionValue withOwner:bridge];
				[completionValue release], completionValue = nil;
			}
			
			//LOG(@"%@", base);
			/*[context release], context = nil;
			[bridge release], bridge = nil;
			[base release], base = nil;*/
		};
	}
	
	//dispatch_async(dispatch_get_main_queue(), ^{
		[self.base prompt:_message title:_title buttonTitle:_buttonTitle defaultValue:_defaultValue style:alertViewStyle completion:handler];
	//});
}

- (PWBase *)base { return nil; }

@end