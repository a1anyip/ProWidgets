//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWEventHandler : NSObject {
	
	id _target;
	SEL _selector;
	void(^_block)(id);
}

@property(nonatomic, assign) id target;
@property(nonatomic, assign) SEL selector;
@property(nonatomic, copy) void(^block)(id);

+ (instancetype)eventHandlerWithTarget:(id)target selector:(SEL)selector;
+ (instancetype)eventHandlerWithBlock:(void(^)(id))block;
- (void)triggerWithObject:(id)object;

@end