//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWAlertView.h"

@implementation PWAlertView

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue cancelButtonTitle:(NSString *)cancelButtonTitle style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion {
	
	if (title == nil) title = @"";
	if (message == nil) message = @"";
	if (cancelButtonTitle == nil) cancelButtonTitle = @"";

	// prevent errors
	if (buttonTitle == nil) {
		self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
	} else {
		self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:buttonTitle, nil];
	}
	
	if (self) {
		
		self.alertViewStyle = style;
		self.completionHandler = completion;
		
		// set default text value
		if (defaultValue != nil && (style == UIAlertViewStylePlainTextInput || style == UIAlertViewStyleSecureTextInput || style == UIAlertViewStyleLoginAndPasswordInput)) {
			UITextField *firstTextField = [self textFieldAtIndex:0];
			firstTextField.text = defaultValue;
		}
	}
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (_completionHandler == nil) return;
	
	if (buttonIndex == 1) {
		
		UITextField *firstTextField = nil;
		UITextField *secondTextField = nil;
		
		if (self.alertViewStyle == UIAlertViewStyleSecureTextInput || self.alertViewStyle == UIAlertViewStylePlainTextInput) {
			firstTextField = [self textFieldAtIndex:0];
		} else if (self.alertViewStyle == UIAlertViewStyleLoginAndPasswordInput) {
			secondTextField = [self textFieldAtIndex:1];
		}
		
		NSString *firstValue = firstTextField.text;
		NSString *secondValue = secondTextField.text;
		
		_completionHandler(NO, firstValue, secondValue);
		
	} else {
		
		_completionHandler(YES, nil, nil);
	}
}

- (void)dealloc {
	RELEASE(_completionHandler);
	[super dealloc];
}

@end