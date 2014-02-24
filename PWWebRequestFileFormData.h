//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWebRequestFileFormData : NSObject {
	
	NSString *_path;
	NSString *_filename;
	NSString *_contentType;
}

@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *contentType;

+ (instancetype)createWithFilename:(NSString *)filename contentType:(NSString *)contentType inBundle:(NSBundle *)bundle;
+ (instancetype)createWithPath:(NSString *)path contentType:(NSString *)contentType;

- (NSData *)readData;

@end