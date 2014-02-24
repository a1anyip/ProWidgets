//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@protocol PWJSBridgeConsoleWrapperExport <JSExport>

- (void)log:(NSString *)message;
- (void)info:(NSString *)message;
- (void)warn:(NSString *)message;
- (void)error:(NSString *)message;

@end

@interface PWJSBridgeConsoleWrapper : PWJSBridgeWrapper<PWJSBridgeConsoleWrapperExport>

@end