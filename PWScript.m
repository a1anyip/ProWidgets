//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWScript.h"
#import "JSBridge/PWJSBridge.h"

@implementation PWScript

+ (instancetype)scriptWithName:(NSString *)name inBundle:(NSBundle *)bundle {
	PWScript *script = [self new];
	script.isJS = NO;
	script.name = name;
	script.bundle = bundle;
	return [script autorelease];
}

+ (instancetype)scriptWithJSFile:(NSString *)filename withName:(NSString *)name inBundle:(NSBundle *)bundle {
	PWScript *script = [self new];
	script.isJS = YES;
	script.name = name;
	script.bundle = bundle;
	script.filename = filename;
	script.path = [NSString stringWithFormat:@"%@/%@", [bundle bundlePath], filename];
	script.bridge = [[[PWJSBridge alloc] initWithScript:script] autorelease];
	return [script autorelease];
}

- (void)execute {
	if (_isJS && _path != nil) {
		LOG(@"PWScript: execute JavaScript file at '%@'", _path);
		// read JS file
		[_bridge readJSFile:_path];
		// tell bridge to clear JSContext
		//[_bridge scriptExecuted];
	}
}

- (void)_execute {
	if (_executed) return;
	LOG(@"PWScript: execute script");
	[self retain]; // retain myself while executing the script in background
	[self execute];
	_executed = YES;
	//[self release]; // release myself after executing the script
}

- (void)dealloc {
	DEALLOCLOG;
	
	// release JSBridge
	if (_bridge != nil) {
		[_bridge scriptExecuted];
		RELEASE(_bridge)
	}
	
	RELEASE(_filename)
	RELEASE(_path)
	
	[super dealloc];
}

@end