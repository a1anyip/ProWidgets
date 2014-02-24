//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "ListValue.h"

@implementation PWWidgetRemindersItemListValue

- (NSString *)displayTextForValues:(NSArray *)values {
	if ([values count] == 1 && [values[0] integerValue] == NSIntegerMax) {
		// Create...
		return @"";
	}
	return [super displayTextForValues:values];
}

@end