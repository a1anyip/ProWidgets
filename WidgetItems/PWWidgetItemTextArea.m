//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemTextArea.h"

@implementation PWWidgetItemTextArea

+ (Class)valueClass {
	return [NSString class];
}

+ (id)defaultValue {
	return @"";
}

+ (Class)cellClass {
	return [PWWidgetItemTextAreaCell class];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	[self.itemViewController updateLastFirstResponder:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	
	NSString *oldValue = [[self.value copy] autorelease];
	NSString *value = textView.text;
	
	if (oldValue == nil) oldValue = @"";
	if (value == nil) value = @"";
	
	if (![value isEqualToString:oldValue]) {
		[self setItemValue:value];
		[self.itemViewController itemValueChanged:self oldValue:oldValue];
	}
}

@end

@implementation PWWidgetItemTextAreaCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		_textView = [UITextView new];
		_textView.backgroundColor = [UIColor clearColor];
		_textView.editable = YES;
		_textView.dataDetectorTypes = UIDataDetectorTypeNone;
		_textView.font = [UIFont systemFontOfSize:18];
		_textView.textColor = [UIColor blackColor];
		_textView.textContainer.lineFragmentPadding = 0;
		_textView.keyboardAppearance = [PWController activeTheme].wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
		
		// add padding
		CGFloat padding = PWDefaultItemCellPadding;
		_textView.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
		
		[self.contentView addSubview:_textView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_textView.frame = self.contentView.bounds;
}

//////////////////////////////////////////////////////////////////////

- (void)updateItem:(PWWidgetItem *)item {
	_textView.delegate = (PWWidgetItemTextArea *)item;
}

//////////////////////////////////////////////////////////////////////

// no effect on text area
- (void)setTitle:(NSString *)title {}

// change text content in text view
- (void)setValue:(NSString *)value {
	_textView.text = value;
}

//////////////////////////////////////////////////////////////////////

- (void)setInputTextColor:(UIColor *)color {
	_textView.textColor = color;
	_textView.tintColor = [color colorWithAlphaComponent:.3];
}

+ (BOOL)contentCanBecomeFirstResponder {
	return YES;
}

- (void)contentSetFirstResponder {
	if (_textView.superview != nil)
		[_textView becomeFirstResponder];
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	_textView.delegate = nil;
	RELEASE_VIEW(_textView)
	[super dealloc];
}

@end