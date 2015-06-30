//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "_PWWidgetItemTextInputTraits.h"

@implementation _PWWidgetItemTextInputTraits

+ (Class)valueClass {
	return [NSString class];
}

+ (id)defaultValue {
	return @"";
}

#define CONVERT(suffix,type) else if ([keyboardType hasSuffix:@"suffix"]) _keyboardType = type;

- (void)setExtraAttributes:(NSDictionary *)attributes {
	
	// secure
	NSNumber *secure = attributes[@"secure"];
	_secure = NO;
	if (secure != nil && [secure isKindOfClass:[NSNumber class]]) {
		_secure = [secure boolValue];
	}
	
	// keyboardType
	NSString *keyboardType = [attributes[@"keyboardType"] lowercaseString];
	_keyboardType = UIKeyboardTypeDefault;
	
	if (false) return;
	CONVERT(@"default", UIKeyboardTypeDefault)
	CONVERT(@"asciicapable", UIKeyboardTypeASCIICapable)
	CONVERT(@"numbersandpunctuation", UIKeyboardTypeNumbersAndPunctuation)
	CONVERT(@"url", UIKeyboardTypeURL)
	CONVERT(@"numberpad", UIKeyboardTypeNumberPad)
	CONVERT(@"namephonepad", UIKeyboardTypeNamePhonePad)
	CONVERT(@"phonepad", UIKeyboardTypePhonePad)
	CONVERT(@"decimalpad", UIKeyboardTypeDecimalPad)
	CONVERT(@"emailaddress", UIKeyboardTypeEmailAddress)
	CONVERT(@"twitter", UIKeyboardTypeTwitter)
	CONVERT(@"websearch", UIKeyboardTypeWebSearch)
	CONVERT(@"alphabet", UIKeyboardTypeAlphabet)
	
	// spellChecking
	NSNumber *spellChecking = attributes[@"spellChecking"];
	_spellCheckingType = UITextSpellCheckingTypeDefault;
	if (spellChecking != nil && [spellChecking isKindOfClass:[NSNumber class]]) {
		_spellCheckingType = [spellChecking boolValue] ? UITextSpellCheckingTypeYes : UITextSpellCheckingTypeNo;
	}
	
	// autocapitalizationType
	NSString *autoCapitalization = attributes[@"autoCapitalization"];
	_autocapitalizationType = UITextAutocapitalizationTypeSentences;
	if (autoCapitalization != nil && [autoCapitalization isKindOfClass:[NSString class]]) {
		autoCapitalization = [autoCapitalization lowercaseString];
		if ([autoCapitalization hasSuffix:@"none"]) _autocapitalizationType = UITextAutocapitalizationTypeNone;
		else if ([autoCapitalization hasSuffix:@"words"]) _autocapitalizationType = UITextAutocapitalizationTypeWords;
		else if ([autoCapitalization hasSuffix:@"sentences"]) _autocapitalizationType = UITextAutocapitalizationTypeSentences;
		else if ([autoCapitalization hasSuffix:@"allcharacters"]) _autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
	}
	
	// autoCorrection
	NSNumber *autoCorrection = attributes[@"autoCorrection"];
	_autocorrectionType = UITextAutocorrectionTypeDefault;
	if (autoCorrection != nil && [autoCorrection isKindOfClass:[NSNumber class]]) {
		_autocorrectionType = [autoCorrection boolValue] ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;
	}
}

@end