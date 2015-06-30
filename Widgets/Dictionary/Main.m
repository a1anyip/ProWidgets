//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Main.h"
#import "Dictionary.h"

@implementation PWWidgetDictionaryMainViewController

- (void)load {
	
	self.requiresKeyboard = YES;
	
	[self loadPlist:@"DictionaryMainItems"];
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *word = values[@"word"];
	if (word != nil && [word length] > 0) {
		// look up the word
		[[PWWidgetDictionary widget] lookUp:word animated:YES];
	} else {
		[self setFirstResponder];
	}
}

- (void)configureFirstResponder {
	if ([PWWidgetDictionary widget].shouldAutoFocus) {
		[self setFirstResponder];
	}
}

- (void)setWord:(NSString *)word {
	[self itemWithKey:@"word"].value = word;
}

- (void)setFirstResponder {
	PWWidgetItem *word = [self itemWithKey:@"word"];
	[word becomeFirstResponder];
}

- (void)resignFirstResponder {
	PWWidgetItem *word = [self itemWithKey:@"word"];
	[word resignFirstResponder];
}

@end