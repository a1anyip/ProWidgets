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
#import "PWView.h"
#import "PWContainerView.h"
#import "PWWidgetPlistParser.h"
#import "PWTheme.h"
#import "PWThemePlistParser.h"
#import "PWWidgetItem.h"
#import "PWWidgetItemCell.h"
#import "PWAlertView.h"
#import "PWContentItemViewController.h"

#define PW_IMP_PREF_GETTER_OBJECT(name,type) - (type)name##ValueForPreferenceKey:(NSString *)key defaultValue:(type)defaultValue {\
	if (key == nil) {\
		LOG(@"PWWidget: Unable to get value from preference. Reason: 'key' cannot be nil.");\
		return nil;\
	}\
	type _value = _preferenceDict[key];\
	return _value == nil ? defaultValue : _value;\
}

#define PW_IMP_PREF_GETTER_NUMBER(name,type,default) - (type)name##ValueForPreferenceKey:(NSString *)key defaultValue:(type)defaultValue {\
	if (key == nil) {\
		LOG(@"PWWidget: Unable to get value from preference. Reason: 'key' cannot be nil.");\
		return default;\
	}\
	NSNumber *_value = _preferenceDict[key];\
	return _value == nil ? defaultValue : [_value name##Value];\
}

@implementation PWBase

- (NSString *)displayName {
	return _info[@"displayName"];
}

/**
 * Preference
 * Public API
 **/

// Getters

PW_IMP_PREF_GETTER_OBJECT(string, NSString *)
PW_IMP_PREF_GETTER_OBJECT(array, NSArray *)
PW_IMP_PREF_GETTER_OBJECT(dictionary, NSDictionary *)
PW_IMP_PREF_GETTER_OBJECT(date, NSDate *)

PW_IMP_PREF_GETTER_NUMBER(int, NSInteger, 0);
PW_IMP_PREF_GETTER_NUMBER(double, CGFloat, 0.0)
PW_IMP_PREF_GETTER_NUMBER(bool, BOOL, NO)

// Setter
- (BOOL)setValue:(id)value forPreferenceKey:(NSString *)key {
	
	if (key == nil || value == nil) {
		LOG(@"PWWidget: Unable to set value. Reason: 'key' and 'value' cannot be nil.");
		return NO;
	}
	
	// update value in cache
	_preferenceDict[key] = value;
	
	// write to preference file
	return [_preferenceDict writeToFile:_preferencePlistPath atomically:YES];
}

// private method
- (void)_loadPreferenceFromFile:(NSString *)path {
	
	[_preferencePlistPath release];
	
	// set path
	_preferencePlistPath = [path copy];
	
	// set dictionary content
	_preferenceDict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	
	if (_preferenceDict == nil)
		_preferenceDict = [NSMutableDictionary new];
}

//////////////////////////////////////////////////////////////////////

/**
 * Property Getters and Setters
 **/

// only set during initialization
- (void)setName:(NSString *)name {
	if (_name != nil) return;
	_name = [name copy];
}

// only set during initialization
- (void)setBundle:(NSBundle *)bundle {
	if (_bundle != nil) return;
	_bundle = [bundle retain];
}

- (void)setInfo:(NSDictionary *)info {
	
	[_info release];
	_info = [info retain];
	
	// ask the widget to load its preference file
	NSString *defaults = info[@"preferenceDefaults"];
	if (defaults != nil && [defaults length] > 0) {
		NSString *plistPath = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", defaults];
		[self _loadPreferenceFromFile:plistPath];
	}
}

- (void)showMessage:(NSString *)message {
	[self showMessage:message title:nil];
}

- (void)showMessage:(NSString *)message title:(NSString *)title {
	[self showMessage:message title:title handler:nil];
}

- (void)showMessage:(NSString *)message title:(NSString *)title handler:(void(^)(void))handler {
	
	if (title == nil)
		title = self.displayName;
	
	__block void(^handlerCopy)(void) = [handler copy];
	PWAlertViewCompletionHandler completion = ^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
		if (handlerCopy != nil) {
			handlerCopy();
			RELEASE(handlerCopy);
		}
	};
	
	PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:title message:message buttonTitle:nil cancelButtonTitle:CT(@"OK") defaultValue:nil style:UIAlertViewStyleDefault completion:completion];
	[alertView show];
	[alertView release];
}

// show message with a text input in alert view
- (void)prompt:(NSString *)message buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion {
	[self prompt:message title:nil buttonTitle:buttonTitle defaultValue:defaultValue style:style completion:completion];
}

- (void)prompt:(NSString *)message title:(NSString *)title buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion {
	
	if (title == nil)
		title = self.displayName;
	
	PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:title message:message buttonTitle:buttonTitle cancelButtonTitle:CT(@"Cancel") defaultValue:defaultValue style:style completion:completion];
	[alertView show];
	[alertView release];
}

- (void)dealloc {
	DEALLOCLOG;
	
	RELEASE(_name)
	RELEASE(_bundle)
	RELEASE(_info)
	RELEASE(_userInfo)
	
	RELEASE(_preferencePlistPath)
	RELEASE(_preferenceDict)
	
	[super dealloc];
}

@end