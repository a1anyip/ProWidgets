//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Dictionary.h"

@implementation PWWidgetDictionary

- (void)load {
	self.shouldAutoFocus = YES;
	_mainViewController = [[PWWidgetDictionaryMainViewController alloc] initForWidget:self];
	[self pushViewController:_mainViewController];
}

- (void)userInfoChanged:(NSDictionary *)userInfo {
	
    BOOL fromApp = [userInfo[@"from"] isEqualToString:@"app"];
	
	if (fromApp) {
		NSString *term = userInfo[@"term"];
		if (term.length > 0) {
			[_mainViewController setWord:term];
			self.pendingTerm = term;
			self.userInfo = nil;
		}
	}
}

- (void)didPresent {
	[self handlePendingTerm];
}

- (void)didMaximize {
	[self handlePendingTerm];
}

- (void)handlePendingTerm {
	if (self.pendingTerm != nil) {
		self.shouldAutoFocus = NO;
		[self lookUp:self.pendingTerm animated:YES];
		self.pendingTerm = nil;
	}
}

- (void)lookUp:(NSString *)word animated:(BOOL)animated {
	
	_UIDictionaryManager *manager = [objc_getClass("_UIDictionaryManager") assetManager];
	NSArray *values = [manager _definitionValuesForTerm:word];
	
	if ([values count] > 0) {
		
		if (_resultViewController == nil) {
			_resultViewController = [[PWWidgetDictionaryResultViewController alloc] initForWidget:self];
		}
		
		_UIDefinitionValue* value = values[0];
		[_resultViewController updateDefinition:value];
		
		if (![_resultViewController isTopViewController]) {
			[self pushViewController:_resultViewController animated:animated];
		}
		
		self.shouldAutoFocus = YES;
		
	} else {
		
		// pop to main view controller
		if ([_resultViewController isTopViewController]) {
			self.shouldAutoFocus = NO;
			[self popViewControllerAnimated:YES];
		}
		
		[_mainViewController resignFirstResponder];
		
		[[PWWidgetDictionary widget] showMessage:@"No definition found. Please check that you have installed at least one dictionary asset. Manage dictionary assets in the preference page of Dictionary widget." title:nil handler:^{
			
			self.shouldAutoFocus = YES;
			
			if ([_mainViewController isTopViewController]) {
				[_mainViewController setFirstResponder];
			}
		}];
	}
}

- (void)pronounce:(NSString *)word {
	
	if (_synthesizer == nil) {
		_synthesizer = [[AVSpeechSynthesizer alloc] init];
	}
	
	AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:word];
	utterance.rate = [self doubleValueForPreferenceKey:@"pronunciationRate" defaultValue:.3];
	
	[_synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
	[_synthesizer speakUtterance:utterance];
}

- (void)dealloc {
	RELEASE(_pendingTerm);
	RELEASE(_mainViewController)
	RELEASE(_resultViewController)
	RELEASE(_synthesizer);
	[super dealloc];
}

@end