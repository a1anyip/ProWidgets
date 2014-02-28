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
#import "substrate.h"

extern NSString *LocStrWithUILanguage(NSString *string);
static NSString *(*original_LocStrWithAssistantLanguage)(NSString *string);

static inline NSString *replaced_LocStrWithAssistantLanguage(NSString *string) {
	LOG(@"Called replaced_LocStrWithAssistantLanguage <%@>", string);
	if (![NSBundle instancesRespondToSelector:@selector(assistantUILocalizedStringForKey:table:)]) {
		LOG(@"NSBundle does not respond to selector assistantUILocalizedStringForKey:table:");
		return LocStrWithUILanguage(string);
	} else {
		LOG(@"NSBundle responds to selector assistantUILocalizedStringForKey:table:");
		return original_LocStrWithAssistantLanguage(string);
	}
}

@implementation PWWidgetAlarmItemListValue

+ (void)load {
	// replace LocStrWithAssistantLanguage function
	MSHookFunction(((void *)MSFindSymbol(NULL, "_LocStrWithAssistantLanguage")), (void *)replaced_LocStrWithAssistantLanguage, (void **)&original_LocStrWithAssistantLanguage);
}

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