//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Cell.h"
#import "PWTheme.h"

@implementation PWWidgetGoogleAuthenticatorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		UIView *selectedBackgroundView = [[UIView new] autorelease];
		selectedBackgroundView.backgroundColor = [PWTheme systemBlueColor];
		self.selectedBackgroundView = selectedBackgroundView;
		
		// copied label
		_copiedLabel = [UILabel new];
		_copiedLabel.text = @"Copied";
		_copiedLabel.font = [UIFont systemFontOfSize:48.0];
		_copiedLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.8];
		_copiedLabel.textColor = [PWTheme systemBlueColor];
		_copiedLabel.alpha = 0.0;
		[self.contentView addSubview:_copiedLabel];
		
		// text label
		_textLabel = [UILabel new];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
		_textLabel.highlightedTextColor = [UIColor whiteColor];
		_textLabel.font = [UIFont systemFontOfSize:14.0];
		[self.contentView addSubview:_textLabel];
		
		// code label
		_codeLabel = [UILabel new];
		_codeLabel.backgroundColor = [UIColor clearColor];
		_codeLabel.textColor = [PWTheme systemBlueColor];
		_codeLabel.highlightedTextColor = [UIColor whiteColor];
		_codeLabel.font = [UIFont systemFontOfSize:44.0];
		[self.contentView addSubview:_codeLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat horizontalPadding = 20.0;
	CGFloat codeHeight = 50.0;
	CGFloat textHeight = 20.0;
	CGFloat contentHeight = codeHeight + textHeight;
	
	CGRect codeRect = CGRectMake(horizontalPadding, (height - contentHeight) / 2, width - horizontalPadding * 2, codeHeight);
	CGRect textRect = CGRectMake(horizontalPadding, codeRect.origin.y + codeRect.size.height, width - horizontalPadding * 2, textHeight);
	
	_copiedLabel.frame = self.contentView.bounds;
	_codeLabel.frame = codeRect;
	_textLabel.frame = textRect;
}

- (void)setName:(NSString *)name issuer:(NSString *)issuer {
	NSString *text = nil;
	if ([issuer length] > 0) {
		text = [NSString stringWithFormat:@"%@  %@", issuer, name];
	} else {
		text = name;
	}
	_textLabel.text = text;
}

- (void)setCode:(NSString *)code {
	_codeLabel.text = code;
}

- (void)setWarning:(BOOL)warning {
	_codeLabel.textColor = warning ? [PWTheme parseColorString:@"#ab1c1c"] : [PWTheme systemBlueColor];
}

- (void)showCopied {
	
	NSString *text = [_textLabel.text copy];
	NSString *copiedText = [@"Copied" copy];
	_textLabel.text = copiedText;
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		// just in case the text is changed after setting 'Copied' text
		if ([_textLabel.text isEqualToString:copiedText]) {
			_textLabel.text = text;
		}
		[text release];
		[copiedText release];
	});
}

- (void)dealloc {
	RELEASE_VIEW(_copiedLabel)
	RELEASE_VIEW(_textLabel)
	RELEASE_VIEW(_codeLabel)
	[super dealloc];
}

@end