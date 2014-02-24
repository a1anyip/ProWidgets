//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@protocol PWJSBridgeBaseWrapperExport <JSExport>

// getter
@property(nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSString *displayName;
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) NSDictionary *userInfo;

// helper methods
- (void)showMessage:(JSValue *)message :(JSValue *)title;
- (void)prompt:(JSValue *)message :(JSValue *)title :(JSValue *)buttonTitle :(JSValue *)defaultValue :(JSValue *)style :(JSValue *)completion;

@end

@interface PWJSBridgeBaseWrapper : PWJSBridgeWrapper<PWJSBridgeBaseWrapperExport>

- (PWBase *)base;

@end