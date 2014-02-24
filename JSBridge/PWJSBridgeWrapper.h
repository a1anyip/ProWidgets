//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "../header.h"
#import "PWJSBridge.h"

@interface PWJSBridgeWrapper : NSObject {
	
	PWJSBridge *_bridge;
}

@property(nonatomic, assign) PWJSBridge *bridge;

- (instancetype)initWithJSBridge:(PWJSBridge *)bridge;

@end