//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@protocol PWJSBridgePreferenceWrapperExport <JSExport>

// getter
@property(nonatomic, readonly) NSString *plistPath;

// object types
- (NSString *)stringValueForKey:(NSString *)key :(JSValue *)defaultValue;
- (NSArray *)arrayValueForKey:(NSString *)key :(JSValue *)defaultValue;
- (NSDictionary *)dictionaryValueForKey:(NSString *)key :(JSValue *)defaultValue;
- (NSDate *)dateValueForKey:(NSString *)key :(JSValue *)defaultValue;

// primitive types
- (NSInteger)intValueForKey:(NSString *)key :(JSValue *)defaultValue;
- (double)doubleValueForKey:(NSString *)key :(JSValue *)defaultValue;
- (BOOL)boolValueForKey:(NSString *)key :(JSValue *)defaultValue;

// setter
- (BOOL)setValue:(NSString *)key :(id)value;

@end

@interface PWJSBridgePreferenceWrapper : PWJSBridgeWrapper<PWJSBridgePreferenceWrapperExport>

@end