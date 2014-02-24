//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWEventHandler.h"

@implementation PWEventHandler

+ (instancetype)eventHandlerWithTarget:(id)target selector:(SEL)selector {
	PWEventHandler *handler = [self new];
	handler.target = target;
	handler.selector = selector;
	return [handler autorelease];
}

+ (instancetype)eventHandlerWithBlock:(void(^)(id))block {
	PWEventHandler *handler = [self new];
	handler.block = block;
	return [handler autorelease];
}

- (void)triggerWithObject:(id)object {
	if (_block != nil) {
		_block(object);
	} else {
		if (_selector != NULL && [_target respondsToSelector:_selector]) {
			[_target performSelector:_selector withObject:object];
		}
	}
}

- (void)dealloc {
	DEALLOCLOG;
	_target = nil;
	_selector = NULL;
	RELEASE(_block)
	[super dealloc];
}

@end