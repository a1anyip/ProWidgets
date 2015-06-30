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

+ (Class)cellClass {
	return [PWWidgetItemTextAreaCell class];
}

- (void)textViewDidBeginEditing:(PWUITextView *)textView {
	[self.itemViewController updateLastFirstResponder:self];
}

- (void)textViewDidEndEditing:(PWUITextView *)textView {
	
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

@implementation PWUITextView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	LOG(@"touchesBegan:%@ / %@", touches, event);
	[super touchesBegan:touches withEvent:event];
}

@end

@implementation PWWidgetItemTextAreaCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		_textView = [PWUITextView new];
		_textView.backgroundColor = [UIColor clearColor];
		_textView.editable = YES;
		_textView.alwaysBounceVertical = YES;
		_textView.dataDetectorTypes = UIDataDetectorTypeNone;
		_textView.font = [UIFont systemFontOfSize:18];
		_textView.textColor = [UIColor blackColor];
		_textView.textContainer.lineFragmentPadding = 0;
		
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
	UIView *result = [super hitTest:point withEvent:event];
	
	if (_textView != nil && [result isDescendantOfView:_textView]) {
		if (point.x > _textView.bounds.size.width * .8) {
			return self;
		}
	}
	
	return result;
}

//////////////////////////////////////////////////////////////////////

- (void)updateItem:(PWWidgetItem *)item {
	
	PWWidgetItemTextArea *textAreaItem = (PWWidgetItemTextArea *)item;
	
	_textView.delegate = textAreaItem;
	_textView.keyboardAppearance = textAreaItem.theme.wantsDarkKeyboard ? UIKeyboardAppearanceDark : UIKeyboardAppearanceDefault;
	
	_textView.autocapitalizationType = textAreaItem.autocapitalizationType;
	_textView.autocorrectionType = textAreaItem.autocorrectionType;
	_textView.spellCheckingType = textAreaItem.spellCheckingType;
	_textView.keyboardType = textAreaItem.keyboardType;
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

- (void)contentResignFirstResponder {
	if (_textView.superview != nil)
		[_textView resignFirstResponder];
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	_textView.delegate = nil;
	RELEASE_VIEW(_textView)
	[super dealloc];
}

@end