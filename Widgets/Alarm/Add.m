//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Add.h"
#import "Alarm.h"

@implementation PWWidgetAlarmAddViewController

- (void)load {
	
	[self loadPlist:@"AddItems"];
	
	// retrieve default sound and sound type
	NSString *defaultIdentifier = [PWAPIAlarmManager defaultSound];
	ToneType defaultToneType = [PWAPIAlarmManager defaultSoundType] == AlarmSoundTypeSong ? ToneTypeMediaItem : ToneTypeRingtone;
	
	// pass the default values to tone value item
	PWWidgetItemToneValue *item = (PWWidgetItemToneValue *)[self itemWithKey:@"sound"];
	[item setSelectedToneIdentifier:defaultIdentifier toneType:defaultToneType];
	
	[self setItemValueChangedEventHandler:self selector:@selector(itemValueChangedEventHandler:oldValue:)];
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)titleTapped {
	PWWidgetAlarm *widget = (PWWidgetAlarm *)self.widget;
	[widget switchToOverviewInterface];
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(id)oldValue {
	
	NSString *key = item.key;
	
	if ([key isEqualToString:@"sound"]) {
		
		NSDictionary *value = (NSDictionary *)item.value;
		
		// retrieve sound name and type from tone value item
		NSString *soundIdentifier = value[@"identifier"];
		AlarmSoundType soundType = [PWAPIAlarmManager soundTypeFromInteger:[value[@"type"] unsignedIntegerValue]];
		
		LOG(@"itemValueChanged: <%@>", soundIdentifier);
		
		[PWAPIAlarmManager setDefaultSound:soundIdentifier ofType:soundType];
	}
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSDate *time = values[@"time"];
	NSArray *repeat = values[@"repeat"];
	NSString *label = values[@"title"];
	NSDictionary *sound = values[@"sound"];
	BOOL snooze = [values[@"snooze"] boolValue];
	
	// extract hour and minute from time
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:time];
	NSUInteger hour = [components hour];
	NSUInteger minute = [components minute];
	
	// convert repeat values to day setting (bitmask)
	NSUInteger daySetting = [PWWidgetAlarm valuesToDateMask:repeat];
	
	// retrieve sound name and type from tone value item
	NSString *soundIdentifier = sound[@"identifier"];
	NSUInteger soundType = [sound[@"type"] unsignedIntegerValue];
	
	PWAPIAlarm *alarm = [PWAPIAlarmManager addAlarmWithTitle:label active:YES hour:hour minute:minute daySetting:daySetting allowsSnooze:snooze sound:soundIdentifier soundType:soundType];
	
	if (alarm == nil) {
		[self.widget showMessage:@"Unable to add alarm"];
	} else {
		[self.widget dismiss];
	}
}

@end