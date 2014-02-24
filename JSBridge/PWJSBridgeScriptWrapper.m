//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeScriptWrapper.h"
#import "PWJSBridge.h"

@implementation PWJSBridgeScriptWrapper

- (PWScript *)base { return _bridge.scriptRef; }
- (PWScript *)script { return _bridge.scriptRef; }

@end