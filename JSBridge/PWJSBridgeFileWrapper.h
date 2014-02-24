//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@protocol PWJSBridgeFileWrapperExport <JSExport>

@property(nonatomic, readonly) NSString *widgetPath;

- (BOOL)existsAt:(JSValue *)path;

- (NSString *)read:(JSValue *)path;
- (NSDictionary *)readPlist:(JSValue *)path;

- (BOOL)write:(JSValue *)path :(JSValue *)content;
- (BOOL)writePlist:(JSValue *)path :(JSValue *)content;

@end

@interface PWJSBridgeFileWrapper : PWJSBridgeWrapper<PWJSBridgeFileWrapperExport>

- (NSString *)_resolvePath:(NSString *)path;

@end