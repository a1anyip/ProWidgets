//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgePreferenceWrapper.h"
#import "PWJSBridge.h"
#import "../PWBase.h"
#import "../PWWidget.h"
#import "../PWWidgetJS.h"

#define DFM ([NSFileManager defaultManager])
#define READ_STRING(x) ([[[NSString alloc] initWithData:[DFM contentsAtPath:x] encoding:NSUTF8StringEncoding] autorelease])

#define PW_IMP_PREF_JSGETTER_OBJECT(name,toType,type) - (type)name##ValueForKey:(NSString *)key :(JSValue *)defaultValue {\
	type _defaultValue = [defaultValue isUndefined] ? nil : [defaultValue to##toType];\
	return [_bridge.baseRef name##ValueForPreferenceKey:key defaultValue:_defaultValue];\
}

#define PW_IMP_PREF_JSGETTER_NUMBER(name,toType,type,default) - (type)name##ValueForKey:(NSString *)key :(JSValue *)defaultValue {\
	type _defaultValue = [defaultValue isUndefined] ? (default) : [defaultValue to##toType];\
	return [_bridge.baseRef name##ValueForPreferenceKey:key defaultValue:_defaultValue];\
}

@implementation PWJSBridgePreferenceWrapper

- (instancetype)initWithJSBridge:(PWJSBridge *)bridge {
	if ((self = [super init])) {
		_bridge = bridge;
	}
	return self;
}

- (NSString *)plistPath {
	return [_bridge.widgetRef preferencePlistPath];
}

// object types
PW_IMP_PREF_JSGETTER_OBJECT(string, String, NSString *)
PW_IMP_PREF_JSGETTER_OBJECT(array, Array, NSArray *)
PW_IMP_PREF_JSGETTER_OBJECT(dictionary, Dictionary, NSDictionary *)
PW_IMP_PREF_JSGETTER_OBJECT(date, Date, NSDate *)

// primitive types
PW_IMP_PREF_JSGETTER_NUMBER(int, Int32, int, 0)
PW_IMP_PREF_JSGETTER_NUMBER(double, Double, double, 0.0)
PW_IMP_PREF_JSGETTER_NUMBER(bool, Bool, BOOL, NO)

// setter
- (BOOL)setValue:(NSString *)key :(id)value {
	
	if ([key length] == 0) {
		[_bridge throwException:@"setValue: 'key' cannot be empty."];
		return NO;
	}
	
	if (value == nil) {
		[_bridge throwException:@"setValue: 'value' cannot be nil."];
		return NO;
	}
	
	return [_bridge.baseRef setValue:value forPreferenceKey:key];
}

@end