//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWBase.h"

@interface PWScript : PWBase {
	
	BOOL _isJS;
	BOOL _executed;
	
	// JSBridge
	PWJSBridge *_bridge;
	
	// JS file info
	NSString *_filename;
	NSString *_path;
}

@property(nonatomic) BOOL isJS;
@property(nonatomic, retain) PWJSBridge *bridge;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *path;

// inherit from PWBase
@property(nonatomic, copy) NSString *name;
@property(nonatomic, retain) NSBundle *bundle;
@property(nonatomic, retain) NSDictionary *info;
@property(nonatomic, retain) NSDictionary *userInfo;

// inherit from PWBase
@property(nonatomic, copy) NSString *title;

// inherit from PWBase
@property(nonatomic, readonly) NSString *preferencePlistPath;
@property(nonatomic, readonly) NSMutableDictionary *preferenceDict;

+ (instancetype)scriptWithName:(NSString *)name inBundle:(NSBundle *)bundle;
+ (instancetype)scriptWithJSFile:(NSString *)filename withName:(NSString *)name inBundle:(NSBundle *)bundle;

- (void)execute;
- (void)_execute;

@end