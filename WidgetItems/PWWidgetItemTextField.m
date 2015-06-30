//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemTextField.h"

@implementation PWWidgetItemTextField

+ (Class)cellClass {
	return [PWWidgetItemTextFieldCell class];
}

/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	LOG(@"textFieldShouldBeginEditing: <item: %@>", self);
	PWContentItemViewController *controller = self.itemViewController;
	PWWidgetItem *lastFirstResponder = controller.lastFirstResponder;
	BOOL shouldUpdateLastFirstResponder = controller.shouldUpdateLastFirstResponder;
	if (!shouldUpdateLastFirstResponder && lastFirstResponder != nil && lastFirstResponder != self) {
		return NO;
	} else {
		return YES;
	}
}*/

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	LOG(@"textFieldDidBeginEditing: %@ <%@>", textField, self);
	/*
	PWContentItemViewController *controller = self.itemViewController;
	PWWidgetItem *lastFirstResponder = controller.lastFirstResponder;
	BOOL shouldUpdateLastFirstResponder = controller.shouldUpdateLastFirstResponder;
	if (!shouldUpdateLastFirstResponder && lastFirstResponder != nil && lastFirstResponder != self) {
		[textField resignFirstResponder];
		return;
	}*/
	
	BOOL success = [self.itemViewController updateLastFirstResponder:self];
	if (!success) {
		[textField resignFirstResponder];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	NSString *oldValue = [[self.value copy] autorelease];
	NSString *value = textField.text;
	
	if (oldValue == nil) oldValue = @"";
	if (value == nil) value = @"";
	
	if (![value isEqualToString:oldValue]) {
		[self setItemValue:value];
		[self.itemViewController itemValueChanged:self oldValue:oldValue];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.itemViewController setNextResponder:self];
	return NO;
}

@end

@implementation PWWidgetItemTextFieldCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		_textField = [UITextField new];
		_textField.textColor = [UIColor blackColor];
		_textField.borderStyle = UITextBorderStyleNone;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		
		_iconView = [UIImageView new];
		_iconView.backgroundColor = [UIColor clearColor];
		
		[self.contentView addSubview:_textField];
		[self.contentView addSubview:_iconView];
	}
	return self;
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	BOOL hasIcon = _iconView.image != nil;
	CGFloat cellWidth = self.contentView.bounds.size.width;
	CGFloat cellHeight = self.contentView.bounds.size.height;
	CGRect iconViewRect = CGRectZero;
	CGRect textFieldRect = CGRectZero;
	
	if (hasIcon) {
		CGFloat iconSize = MIN(cellHeight - 2.0 * 2 /* padding */, 20.0);
		CGFloat iconMargin = PWDefaultItemCellPadding;
		iconViewRect = CGRectMake(PWDefaultItemCellPadding, (cellHeight - iconSize) / 2, iconSize, iconSize);
		textFieldRect = CGRectMake(iconViewRect.origin.x + iconSize + iconMargin, 0, 0, cellHeight);
		textFieldRect.size.width = cellWidth - textFieldRect.origin.x - PWDefaultItemCellPadding;
	} else {
		textFieldRect = CGRectInset(self.contentView.bounds, PWDefaultItemCellPadding, 0);
	}
	
	_iconView.frame = iconViewRect;
	_textField.frame = textFieldRect;
}

//////////////////////////////////////////////////////////////////////

- (void)updateItem:(PWWidgetItem *)item {
	
	PWWidgetItemTextField *textFieldItem = (PWWidgetItemTextField *)item;
	
	if (_textField.delegate != textFieldItem && [_textField isFirstResponder]) {
		[_textField resignFirstResponder];
	}
	
	_textField.delegate = textFieldItem;
	_textField.keyboardAppearance = textFieldItem.theme.wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
	
	_textField.autocapitalizationType = textFieldItem.autocapitalizationType;
	_textField.autocorrectionType = textFieldItem.autocorrectionType;
	_textField.spellCheckingType = textFieldItem.spellCheckingType;
	_textField.keyboardType = textFieldItem.keyboardType;
	_textField.secureTextEntry = textFieldItem.secure;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	_textField.placeholder = title;
}

- (void)setIcon:(UIImage *)icon {
	_iconView.image = icon;
	[self setNeedsLayout];
}

// change text content in text field
- (void)setValue:(NSString *)value {
	_textField.text = value;
}

//////////////////////////////////////////////////////////////////////

- (void)setInputTextColor:(UIColor *)color {
	_textField.textColor = color;
	_textField.tintColor = [color colorWithAlphaComponent:.3];
}

- (void)setInputPlaceholderTextColor:(UIColor *)color {
	[_textField setValue:color forKeyPath:@"_placeholderLabel.textColor"];
}

+ (BOOL)contentCanBecomeFirstResponder {
	return YES;
}

- (void)contentSetFirstResponder {
	if (_textField.superview != nil)
		[_textField becomeFirstResponder];
}

- (void)contentResignFirstResponder {
	if (_textField.superview != nil)
		[_textField resignFirstResponder];
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	_textField.delegate = nil;
	RELEASE_VIEW(_textField)
	RELEASE_VIEW(_iconView)
	[super dealloc];
}

@end