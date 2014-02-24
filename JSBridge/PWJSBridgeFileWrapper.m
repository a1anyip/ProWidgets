//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeFileWrapper.h"
#import "PWJSBridge.h"
#import "../PWWidget.h"
#import "../PWWidgetJS.h"

#define DFM ([NSFileManager defaultManager])
#define READ_STRING(x) ([[[NSString alloc] initWithData:[DFM contentsAtPath:x] encoding:NSUTF8StringEncoding] autorelease])

@implementation PWJSBridgeFileWrapper

- (NSString *)widgetPath {
	return [_bridge.widgetRef.bundle bundlePath];
}

- (BOOL)existsAt:(JSValue *)path {
	
	if ([path isUndefined]) {
		[_bridge throwException:@"fileExistsAt: requires argument 1 (path)"];
		return NO;
	}
	
	NSString *_path = [self _resolvePath:[path toString]];
	return [DFM fileExistsAtPath:_path isDirectory:NULL];
}

- (NSString *)read:(JSValue *)path {
	
	if ([path isUndefined]) {
		[_bridge throwException:@"read: requires argument 1 (path)"];
		return nil;
	}
	
	NSString *_path = [self _resolvePath:[path toString]];
	return READ_STRING(_path);
}

- (NSDictionary *)readPlist:(JSValue *)path {
	
	if ([path isUndefined]) {
		[_bridge throwException:@"readPlist: requires argument 1 (path)"];
		return [NSDictionary dictionary];
	}
	
	NSString *_path = [self _resolvePath:[path toString]];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:_path];
	if (dict != nil)
		return dict;
	
	return [NSDictionary dictionary];
}

- (BOOL)write:(JSValue *)path :(JSValue *)content {

	if ([path isUndefined] || [content isUndefined]) {
		[_bridge throwException:@"write: requires 2 arguments (path and string content)"];
		return NO;
	}
	
	NSString *_path = [self _resolvePath:[path toString]];
	NSString *_content = [content isNull] ? @"" : [content toString];
	
	return [_content writeToFile:_path atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}

- (BOOL)writePlist:(JSValue *)path :(JSValue *)content {
	
	if ([path isUndefined] || [content isUndefined]) {
		[_bridge throwException:@"writePlist: requires 2 arguments (path and JSON content)"];
		return NO;
	}
	
	NSString *_path = [self _resolvePath:[path toString]];
	NSDictionary *_content = [content toDictionary];
	
	return [_content writeToFile:_path atomically:YES];
}

- (NSString *)_resolvePath:(NSString *)path {
	
	// trim the path
	path = [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// check if it is relative or absolute path
	if (![path hasPrefix:@"/"]) path = [NSString stringWithFormat:@"%@/%@", self.widgetPath, path];
	
	return [path stringByStandardizingPath];
}

@end