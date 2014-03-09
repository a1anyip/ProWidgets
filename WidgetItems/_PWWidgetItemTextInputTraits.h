//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"

@interface _PWWidgetItemTextInputTraits : PWWidgetItem {
	
	BOOL _secure;
	UIKeyboardType _keyboardType;
	UITextSpellCheckingType _spellCheckingType;
	UITextAutocapitalizationType _autocapitalizationType;
	UITextAutocorrectionType _autocorrectionType;
}

@property(nonatomic, assign) BOOL secure;
@property(nonatomic, assign) UIKeyboardType keyboardType;
@property(nonatomic, assign) UITextSpellCheckingType spellCheckingType;
@property(nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic, assign) UITextAutocorrectionType autocorrectionType;

@end