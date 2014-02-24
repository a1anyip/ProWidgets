//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWAlertView.h"

@interface PWBase : NSObject {
	
	BOOL _requiresProtectedDataAccess;
	
	NSString *_name;
	NSBundle *_bundle;
	NSDictionary *_info;
	NSDictionary *_userInfo;
	
	NSString *_preferencePlistPath;
	NSMutableDictionary *_preferenceDict;
}

@property(nonatomic) BOOL requiresProtectedDataAccess;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, readonly) NSString *displayName;
@property(nonatomic, retain) NSBundle *bundle;
@property(nonatomic, retain) NSDictionary *info;
@property(nonatomic, retain) NSDictionary *userInfo;

@property(nonatomic, readonly) NSString *preferencePlistPath;
@property(nonatomic, readonly) NSMutableDictionary *preferenceDict;

/**
 * Preference
 * Public API
 **/

// Getters

// object types
- (NSString *)stringValueForPreferenceKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray *)arrayValueForPreferenceKey:(NSString *)key defaultValue:(NSArray *)defaultValue;
- (NSDictionary *)dictionaryValueForPreferenceKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue;
- (NSDate *)dateValueForPreferenceKey:(NSString *)key defaultValue:(NSDate *)defaultValue;

// primitive types
- (int)intValueForPreferenceKey:(NSString *)key defaultValue:(int)defaultValue;
- (double)doubleValueForPreferenceKey:(NSString *)key defaultValue:(double)defaultValue;
- (BOOL)boolValueForPreferenceKey:(NSString *)key defaultValue:(BOOL)defaultValue;

// Setter
- (BOOL)setValue:(id)value forPreferenceKey:(NSString *)key;

// private method
- (void)_loadPreferenceFromFile:(NSString *)path;

// show message in alert view
- (void)showMessage:(NSString *)message;
- (void)showMessage:(NSString *)message title:(NSString *)title;
- (void)showMessage:(NSString *)message title:(NSString *)title handler:(void(^)(void))handler;

// show message with a text input in alert view
- (void)prompt:(NSString *)message buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion;
- (void)prompt:(NSString *)message title:(NSString *)title buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion;

@end