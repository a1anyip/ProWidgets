//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWJSBridgeWrapper.h"

@protocol PWJSBridgeWebRequestWrapperExport <JSExport>

- (PWWebRequest *)send:(JSValue *)url :(JSValue *)method :(JSValue *)params :(JSValue *)headers :(JSValue *)callback;

- (PWWebRequestFileFormData *)createFileFormData:(JSValue *)filename :(JSValue *)contentType;

@end

@interface PWJSBridgeWebRequestWrapper : PWJSBridgeWrapper<PWJSBridgeWebRequestWrapperExport>

@end