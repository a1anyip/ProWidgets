//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "header.h"
#import "PWWidget.h"
#import "PWContentItemViewController.h"

@interface PWWidgetJS : PWWidget {
	
	// JSBridge
	PWJSBridge *_bridge;
	
	// JS file info
	NSString *_filename;
	NSString *_path;
}

@property(nonatomic, retain) PWJSBridge *bridge;
@property(nonatomic, copy) NSString *filename;
@property(nonatomic, copy) NSString *path;

- (instancetype)initWithJSFile:(NSString *)filename withName:(NSString *)name inBundle:(NSBundle *)bundle;

@end

@interface PWContentItemViewControllerJS : PWContentItemViewController {
	
	// JSBridge
	PWJSBridge *_bridge;
}

@property(nonatomic, assign) PWJSBridge *bridge;

@end