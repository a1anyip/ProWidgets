//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "ListValue.h"
#import "Alarm.h"

@implementation PWWidgetAlarmItemListValue

- (NSString *)displayTextForValues:(NSArray *)values {
	NSUInteger dateMask = [PWWidgetAlarm valuesToDateMask:values];
	return DateMaskToString(dateMask, NO, YES, YES);
}

+ (NSString *)A:(NSArray *)values {
	NSUInteger dateMask = [PWWidgetAlarm valuesToDateMask:values];
	return DateMaskToString(dateMask, NO, YES, YES);
}

+ (NSString *)B:(NSArray *)values {
	NSUInteger dateMask = [PWWidgetAlarm valuesToDateMask:values];
	return DateMaskToString(dateMask, NO, YES, NO);
}

+ (NSString *)C:(NSArray *)values {
	NSUInteger dateMask = [PWWidgetAlarm valuesToDateMask:values];
	return DateMaskToString(dateMask, NO, NO, NO);
}

@end