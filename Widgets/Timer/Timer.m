//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "substrate/interface.h"
#import "PWContentItemViewController.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "WidgetItems/items.h"
#import "DatePicker.h"
#import <objcipc/IPC.h>

#define TimerIdentifier @"com.apple.mobiletimer"
#define MessageName @"PWWidgetTimer"

typedef enum {
	TimerStateStopped = 1,
	TimerStatePaused = 2,
	TimerStateStarted = 3
} TimerState;

@interface PWWidgetTimer : PWWidget {
	
	BOOL _retrievedState;
	TimerState _state;
	
	NSTimer *_timer;
	NSTimeInterval _fireTime;
	NSTimeInterval _remainingTime;
}

- (NSString *)defaultSound;
- (void)scheduleWithDuration:(NSTimeInterval)duration sound:(NSString *)sound;

- (void)resume;
- (void)pause;
- (void)cancel;
- (void)reloadState:(NSString *)subaction;

- (void)updateState:(TimerState)state;

@end

@implementation PWWidgetTimer

- (void)load {
	
	[OBJCIPC registerIncomingMessageHandlerForAppWithIdentifier:TimerIdentifier andMessageName:MessageName handler:^NSDictionary *(NSDictionary *dict) {
		NSString *notification = dict[@"notification"];
		if ([notification isEqualToString:@"LocalNotificationChanged"]) {
			LOG(@"PWWidgetTimer: Local notification changed");
			[self reloadState:nil];
		}
		return nil;
	}];
	
	// retrieve default sound
	NSString *defaultIdentifier = [self defaultSound];
	
	// pass the default values to tone value item
	PWWidgetItemToneValue *item = (PWWidgetItemToneValue *)[self.defaultItemViewController itemWithKey:@"sound"];
	[item setSelectedToneIdentifier:defaultIdentifier toneType:ToneTypeRingtone];
	
	self.defaultItemViewController.requiresKeyboard = NO;
	self.defaultItemViewController.shouldMaximizeContentHeight = NO;
	
	[self.defaultItemViewController setCloseEventHandler:self selector:@selector(closeButtonPressed)];
	[self.defaultItemViewController setSubmitEventHandler:self selector:@selector(actionButtonPressed)];
	[self reloadState:nil];
}

- (void)willPresent {
	
	[self.defaultItemViewController configureActionButton];
	self.defaultItemViewController.navigationItem.rightBarButtonItem.possibleTitles = [NSSet setWithObjects:@"Start", @"Resume", @"Pause", @"", nil];
	
	if (!_retrievedState)
		self.defaultItemViewController.actionButtonText = @"";
}

- (void)willDismiss {
	
	[self invalidateTimer];
	
	[OBJCIPC unregisterIncomingMessageHandlerForAppWithIdentifier:TimerIdentifier andMessageName:MessageName];
}

- (NSString *)defaultSound {
	
	[objc_getClass("ClockManager") loadUserPreferences];
	TimerManager *manager = [objc_getClass("TimerManager") sharedManager];
	return [manager defaultSound];
}

- (void)scheduleWithDuration:(NSTimeInterval)duration sound:(NSString *)sound {
	NSDictionary *dict;
	
	if (sound == nil) {
		dict = @{ @"action": @"schedule", @"duration": @(duration) };
	} else {
		dict = @{ @"action": @"schedule", @"duration": @(duration), @"sound": sound };
	}
	
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:MessageName dictionary:dict replyHandler:^(NSDictionary *dict) {
		if (dict != nil) {
			
			_fireTime = [dict[@"fireTime"] doubleValue];
			_remainingTime = 0.0;
			
			NSNumber *stateNumber = dict[@"state"];
			if (stateNumber != nil) {
				TimerState state = (TimerState)[stateNumber unsignedIntegerValue];
				[self updateState:state];
			}
			
		} else {
			[self showMessage:@"Unable to start the timer."];
		}
	}];
}

- (void)resume {
	[self reloadState:@"resume"];
}

- (void)pause {
	[self reloadState:@"pause"];
}

- (void)cancel {
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:MessageName dictionary:@{ @"action": @"cancel" }];
}

- (void)reloadState:(NSString *)subaction {
	[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:MessageName dictionary:@{ @"action": @"query", @"subaction": (subaction == nil ? @"" : subaction) } replyHandler:^(NSDictionary *dict) {
		
		_fireTime = [dict[@"fireTime"] doubleValue];
		_remainingTime = [dict[@"remainingTime"] doubleValue];
		
		NSNumber *stateNumber = dict[@"state"];
		if (stateNumber != nil) {
			TimerState state = (TimerState)[stateNumber unsignedIntegerValue];
			[self updateState:state];
		}
	}];
}

- (void)closeButtonPressed {
	if (_state != TimerStateStopped) {
		PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:@"Timer is started" message:@"Do you want to stop the timer or just close the widget?" buttonTitle:@"Stop" cancelButtonTitle:@"Close" defaultValue:nil style:UIAlertViewStyleDefault completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
			if (!cancelled) {
				[self cancel];
			}
			[self dismiss];
		}];
		[alertView show];
		[alertView release];
	} else {
		[self dismiss];
	}
}

- (void)itemValueChangedEventHandler:(PWWidgetItem *)item oldValue:(NSDictionary *)oldValue {
	if ([item.key isEqualToString:@"sound"]) {
		
		NSString *toneIdentifier = item.value[@"identifier"];
		if (toneIdentifier == nil) toneIdentifier = @"";
		
		NSDictionary *dict = @{ @"action": @"setDefaultSound", @"sound": toneIdentifier };
		[OBJCIPC sendMessageToAppWithIdentifier:TimerIdentifier messageName:MessageName dictionary:dict replyHandler:nil];
	}
}

- (void)actionButtonPressed {
	
	if (!_retrievedState) return;
	
	if (_state == TimerStateStopped) {
		
		self.defaultItemViewController.actionButtonText = @"Start";
		
		PWWidgetTimerItemDatePicker *item = (PWWidgetTimerItemDatePicker *)[self.defaultItemViewController itemWithKey:@"datePicker"];
		PWWidgetTimerItemDatePickerCell *cell = (PWWidgetTimerItemDatePickerCell *)item.activeCell;
		NSTimeInterval duration = cell.countDownDuration;
		
		PWWidgetItemToneValue *sound = (PWWidgetItemToneValue *)[self.defaultItemViewController itemWithKey:@"sound"];
		NSString *toneIdentifier = sound.selectedToneIdentifier;
		
		[self scheduleWithDuration:duration sound:toneIdentifier];
		
	} else if (_state == TimerStatePaused) {
		[self resume];
	} else if (_state == TimerStateStarted) {
		[self pause];
	}
}

- (void)timerTick {
	
	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
	NSTimeInterval fireTime = _fireTime;
	NSTimeInterval remainingTime = _remainingTime;
	NSTimeInterval time = remainingTime > 0.0 ? remainingTime : MAX(0, fireTime - currentTime);
	
	PWWidgetTimerItemDatePicker *item = (PWWidgetTimerItemDatePicker *)[self.defaultItemViewController itemWithKey:@"datePicker"];
	PWWidgetTimerItemDatePickerCell *cell = (PWWidgetTimerItemDatePickerCell *)item.activeCell;
	
	if (time == 0.0) {
		[cell showDatePicker];
		[self updateState:TimerStateStopped];
	} else {
		[cell setRemainingTime:time];
	}
}

- (void)updateState:(TimerState)state {
	
	_retrievedState = YES;
	_state = state;
	
	PWWidgetTimerItemDatePicker *item = (PWWidgetTimerItemDatePicker *)[self.defaultItemViewController itemWithKey:@"datePicker"];
	PWWidgetTimerItemDatePickerCell *cell = (PWWidgetTimerItemDatePickerCell *)item.activeCell;
	
	if (state == TimerStateStarted) {
		if (_timer == nil) {
			_timer = [[NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(timerTick) userInfo:nil repeats:YES] retain];
			[self timerTick];
		}
	} else {
		[self invalidateTimer];
	}
	
	if (state == TimerStateStopped) {
		self.defaultItemViewController.actionButtonText = @"Start";
		[cell showDatePicker];
	} else if (state == TimerStatePaused) {
		self.defaultItemViewController.actionButtonText = @"Resume";
		[cell showRemainingTime];
	} else if (state == TimerStateStarted) {
		self.defaultItemViewController.actionButtonText = @"Pause";
		[cell showRemainingTime];
	}
}

- (void)invalidateTimer {
	[_timer invalidate];
	RELEASE(_timer);
}

- (void)dealloc {
	DEALLOCLOG;
	[super dealloc];
}

@end