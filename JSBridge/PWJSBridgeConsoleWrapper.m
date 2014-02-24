//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeConsoleWrapper.h"
#import "PWJSBridge.h"

@implementation PWJSBridgeConsoleWrapper

- (void)log:(NSString *)message {
	[self _output:message type:@"Log"];
}

- (void)info:(NSString *)message {
	[self _output:message type:@"Info"];
}

- (void)warn:(NSString *)message {
	[self _output:message type:@"Warning"];
}

- (void)error:(NSString *)message {
	[self _output:message type:@"Error"];
}

- (void)_output:(NSString *)message type:(NSString *)type {
	NSLog(@"[Console] <%@> %@", type, message);
}

@end