//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWebRequestFileFormData.h"

@implementation PWWebRequestFileFormData

+ (instancetype)createWithFilename:(NSString *)filename contentType:(NSString *)contentType inBundle:(NSBundle *)bundle {
	
	PWWebRequestFileFormData *instance = [self new];
	
	instance.path = [NSString stringWithFormat:@"%@/%@", [bundle bundlePath], filename];
	instance.filename = filename;
	instance.contentType = contentType;
	
	return [instance autorelease];
}

+ (instancetype)createWithPath:(NSString *)path contentType:(NSString *)contentType {
	
	PWWebRequestFileFormData *instance = [self new];
	
	instance.path = path;
	instance.filename = [path lastPathComponent];
	instance.contentType = contentType;
	
	return [instance autorelease];
}

- (NSData *)readData {
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:_path]) {
		LOG(@"PWWebRequestFileFormData: File does not exist at '%@'.", _path);
		return nil;
	}
	
	return [[NSFileManager defaultManager] contentsAtPath:_path];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	[_path release], _path = nil;
	[_filename release], _filename = nil;
	[_contentType release], _contentType = nil;
	[super dealloc];
}

@end