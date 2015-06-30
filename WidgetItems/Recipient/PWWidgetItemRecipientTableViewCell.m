//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipientTableViewCell.h"
#import "../../PWController.h"
#import "../../PWTheme.h"

static UIImage *recipientRemoveButtonImage = nil;

char PWWidgetItemRecipientTableViewCellRecipientKey;

@implementation PWWidgetItemRecipientTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		self.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
		
		_showingRemoveButton = NO;
		[self _configureAddButton];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	//CGFloat height = size.height;
	//CGFloat horizontalPadding = 8.0;
	
	UIView *accessoryView = self.accessoryView;
	CGRect accessoryViewRect = accessoryView.frame;
	accessoryViewRect.origin.x = width - accessoryViewRect.size.width - 10.0;
	accessoryView.frame = accessoryViewRect;
}

/*- (MFComposeRecipient *)buttonRecipient {
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		return objc_getAssociatedObject(button, &PWWidgetItemRecipientTableViewCellRecipientKey);
	}
	return nil;
}*/

- (void)setButtonRecipient:(MFComposeRecipient *)recipient {
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		objc_setAssociatedObject(button, &PWWidgetItemRecipientTableViewCellRecipientKey, recipient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
}

- (void)setButtonTarget:(id)target action:(SEL)action {
	UIButton *button = (UIButton *)self.accessoryView;
	LOG(@"setButtonTarget:%@ <button: %@>", target, button);
	if (button != nil) {
		[button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)setTitleTextColor:(UIColor *)color {
	
	UIColor *detailTextColor = [PWTheme translucentColor:color];
	
	self.textLabel.textColor = color;
	self.detailTextLabel.textColor = detailTextColor;
}

- (void)setSelectedTitleTextColor:(UIColor *)color {
	
	UIColor *detailTextColor = [PWTheme translucentColor:color];
	
	self.textLabel.highlightedTextColor = color;
	self.detailTextLabel.highlightedTextColor = detailTextColor;
}

- (void)setValueTextColor:(UIColor *)color {}

- (void)setName:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setType:(NSString *)type address:(NSString *)address {
	
	CGFloat fontSize = 14.0;
	UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
	UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
	UIColor *detailTextColor = self.detailTextLabel.textColor;
	if (detailTextColor == nil) detailTextColor = [UIColor blackColor];
	
	NSDictionary *attrs = @{ NSFontAttributeName: regularFont };
	NSDictionary *boldAttrs = @{ NSFontAttributeName: boldFont };
	
	NSString *text = [NSString stringWithFormat:@"%@%@%@", (type == nil ? @"" : type), ([type length] == 0 ? @"" : @"  "), (address == nil ? @"" : address)];
	NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:attrs];
	
	if ([type length] > 0) {
		[attributedText setAttributes:boldAttrs range:NSMakeRange(0, [type length])];
	}
	
	[self.detailTextLabel setAttributedText:attributedText];
	[attributedText release];
}

- (void)setShowingRemoveButton:(BOOL)showing {
	if (_showingRemoveButton != showing) {
		
		if (showing) {
			[self _configureRemoveButton];
		} else {
			[self _configureAddButton];
		}
		
		_showingRemoveButton = showing;
	}
}

- (void)_configureAddButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
	button.userInteractionEnabled = NO;
	self.accessoryView = button;
}

- (void)_configureRemoveButton {
	
	if (recipientRemoveButtonImage == nil) {
		recipientRemoveButtonImage = [[[[PWController sharedInstance] imageResourceNamed:@"recipientRemoveButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
	}
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, 0, 44.0, 44.0); // fixed size
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
	button.userInteractionEnabled = YES;
	[button setImage:recipientRemoveButtonImage forState:UIControlStateNormal];
	
	self.accessoryView = button;
}

- (void)dealloc {
	
	UIButton *button = (UIButton *)self.accessoryView;
	if (button != nil) {
		[button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	}
	
	[super dealloc];
}

@end