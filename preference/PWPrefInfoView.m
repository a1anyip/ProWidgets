#import "PWPrefInfoView.h"
#import "../PWTheme.h"

extern NSBundle *bundle;

@implementation PWPrefInfoView

- (instancetype)init {
	if ((self = [super init])) {
		
		// set background color
		self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
		
		// add icon view
		_iconView = [UIImageView new];
		[self addSubview:_iconView];
		
		// add name label
		_nameLabel = [UILabel new];
		_nameLabel.textAlignment = NSTextAlignmentLeft;
		_nameLabel.textColor = [UIColor blackColor];
		_nameLabel.font = [UIFont boldSystemFontOfSize:22];
		_nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		[self addSubview:_nameLabel];
		
		// add author label
		_authorLabel = [UILabel new];
		_authorLabel.textAlignment = NSTextAlignmentLeft;
		_authorLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
		_authorLabel.font = [UIFont systemFontOfSize:14];
		_authorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		[self addSubview:_authorLabel];
		
		// add description text view
		CGFloat padding = 12.0;
		_descriptionTextView = [UITextView new];
		_descriptionTextView.editable = NO;
		_descriptionTextView.selectable = YES;
		_descriptionTextView.alwaysBounceVertical = YES;
		_descriptionTextView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.5];
		_descriptionTextView.textColor = [UIColor colorWithWhite:.3 alpha:1.0];
		_descriptionTextView.font = [UIFont systemFontOfSize:16];
		_descriptionTextView.textContainer.lineFragmentPadding = 0;
		_descriptionTextView.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
		_descriptionTextView.dataDetectorTypes = UIDataDetectorTypeAll;
		[self addSubview:_descriptionTextView];
		
		// add live preview row
		_livePreviewLabel = [UILabel new];
		_livePreviewLabel.text = @"Live Preview:";
		_livePreviewLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		_livePreviewLabel.font = [UIFont systemFontOfSize:16];
		_livePreviewLabel.hidden = YES;
		[self addSubview:_livePreviewLabel];
		
		_livePreviewSwitch = [UISwitch new];
		_livePreviewSwitch.hidden = YES;
		[_livePreviewSwitch addTarget:self action:@selector(_livePreviewSwitchHandler) forControlEvents:UIControlEventValueChanged];
		[self addSubview:_livePreviewSwitch];
		
		_livePreviewSeparator = [UIView new];
		_livePreviewSeparator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1.0];
		[self addSubview:_livePreviewSeparator];
		
		// add separator
		_separator = [UIView new];
		_separator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1.0];
		[self addSubview:_separator];
		
		// add confirm button
		_confirmButton = [UIButton new];
		_confirmButton.adjustsImageWhenHighlighted = YES;
		[_confirmButton addTarget:self action:@selector(_confirmButtonHandler) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_confirmButton];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
	
	CGFloat iconSize = 25.0;
	CGFloat nameHeight = 40.0;
	CGFloat authorHeight = 40.0;
	CGFloat livePreviewHeight = _showLivePreview ? (isLandscape ? 35.0 : 40.0) : 0.0;
	CGFloat buttonHeight = isLandscape ? 35.0 : 50.0;
	CGFloat navigationBarHeight = isLandscape ? 32.0 : 44.0;
	
	CGFloat topMargin = 20.0 + navigationBarHeight;
	CGFloat xMargin = 15.0;
	CGFloat yMargin = isLandscape ? 6.0 : 8.0;
	CGFloat nameLeftPadding = 12.0;
	CGFloat authorPadding = 3.0;
	
	CGRect iconRect = CGRectMake(xMargin, yMargin + (nameHeight - iconSize) / 2 + topMargin, iconSize, iconSize);
	
	CGRect nameRect = CGRectMake(iconRect.origin.x + iconRect.size.width + nameLeftPadding, yMargin + topMargin, 0, nameHeight);
	nameRect.size.width = width - xMargin - nameRect.origin.x;
	
	CGRect authorRect = CGRectMake(xMargin + authorPadding, iconRect.origin.y + iconRect.size.height, width - xMargin * 2 - authorPadding, authorHeight);
	
	CGRect separatorRect = CGRectMake(0, authorRect.origin.y + authorRect.size.height + yMargin - .5, width, .5);
	
	CGRect descriptionRect = CGRectMake(0, separatorRect.origin.y + .5, width, 0);
	descriptionRect.size.height = height - descriptionRect.origin.y - buttonHeight - livePreviewHeight;
	
	CGRect livePreviewLabelRect = CGRectMake(10.0, height - buttonHeight - livePreviewHeight, 200.0, livePreviewHeight);
	
	[_livePreviewSwitch sizeToFit];
	CGRect livePreviewSwitchRect = _livePreviewSwitch.frame;
	livePreviewSwitchRect.origin.x = width - xMargin / 2 - livePreviewSwitchRect.size.width;
	livePreviewSwitchRect.origin.y = height - buttonHeight - livePreviewHeight + (livePreviewHeight - livePreviewSwitchRect.size.height) / 2;
	
	CGRect livePreviewSeparatorRect = CGRectMake(0, height - buttonHeight - livePreviewHeight, width, .5);
	
	CGRect buttonRect = CGRectMake(0, height - buttonHeight, width, buttonHeight);
	
	_iconView.frame = iconRect;
	_nameLabel.frame = nameRect;
	_authorLabel.frame = authorRect;
	_separator.frame = separatorRect;
	_descriptionTextView.frame = descriptionRect;
	_livePreviewLabel.frame = livePreviewLabelRect;
	_livePreviewSwitch.frame = livePreviewSwitchRect;
	_livePreviewSeparator.frame = livePreviewSeparatorRect;
	_confirmButton.frame = buttonRect;
}

- (void)setIcon:(UIImage *)icon {
	_iconView.image = icon;
}

- (void)setName:(NSString *)name {
	_nameLabel.text = name;
}

- (void)setAuthor:(NSString *)author {
	_authorLabel.text = [NSString stringWithFormat:@"By %@", author];
}

- (void)setDescription:(NSString *)description {
	_descriptionTextView.text = description;
}

- (void)setLivePreviewHidden:(BOOL)hidden {
	_showLivePreview = !hidden;
	_livePreviewLabel.hidden = hidden;
	_livePreviewSwitch.hidden = hidden;
	_livePreviewSeparator.hidden = hidden;
	[self setNeedsLayout];
}

- (void)setLivePreviewEnabledState:(BOOL)state {
	_livePreviewSwitch.on = state;
}

- (void)setLivePreviewSwitchTarget:(id)target action:(SEL)action {
	_livePreviewSwitchTarget = target;
	_livePreviewSwitchAction = action;
}

- (void)setLivePreviewSwitchInfo:(NSDictionary *)info {
	[_livePreviewSwitchInfo release];
	_livePreviewSwitchInfo = [info retain];
}

- (void)_livePreviewSwitchHandler {
	[_livePreviewSwitchTarget performSelector:_livePreviewSwitchAction withObject:_livePreviewSwitch withObject:_livePreviewSwitchInfo];
}

- (void)setConfirmButtonType:(PWPrefInfoViewConfirmButtonType)type {
	
	UIColor *color = nil;
	
	switch (type) {
		case PWPrefInfoViewConfirmButtonTypeNormal:
			_confirmButton.userInteractionEnabled = YES;
			_confirmButton.alpha = 1.0;
			color = [PWTheme systemBlueColor];
			break;
		case PWPrefInfoViewConfirmButtonTypeWarning:
			_confirmButton.userInteractionEnabled = YES;
			_confirmButton.alpha = 1.0;
			color = [UIColor redColor];
			break;
		case PWPrefInfoViewConfirmButtonTypeDisabled:
			_confirmButton.userInteractionEnabled = NO;
			_confirmButton.alpha = .5;
			color = [UIColor colorWithWhite:.5 alpha:1.0];
			break;
	}
	
	[_confirmButton setBackgroundImage:[PWTheme imageFromColor:color] forState:UIControlStateNormal];
}

- (void)setConfirmButtonTitle:(NSString *)title {
	[_confirmButton setTitle:title forState:UIControlStateNormal];
}

- (void)setConfirmButtonTarget:(id)target action:(SEL)action {
	_confirmButtonTarget = target;
	_confirmButtonAction = action;
}

- (void)setConfirmButtonInfo:(NSDictionary *)info {
	[_confirmButtonInfo release];
	_confirmButtonInfo = [info retain];
}

- (void)_confirmButtonHandler {
	if (_confirmButtonTarget != nil && _confirmButtonAction != NULL) {
		[_confirmButtonTarget performSelector:_confirmButtonAction withObject:_confirmButtonInfo];
	}
}

- (void)dealloc {
	RELEASE_VIEW(_iconView)
	RELEASE_VIEW(_nameLabel)
	RELEASE_VIEW(_authorLabel)
	RELEASE_VIEW(_separator)
	RELEASE_VIEW(_descriptionTextView)
	RELEASE_VIEW(_livePreviewLabel)
	RELEASE_VIEW(_livePreviewSwitch)
	RELEASE_VIEW(_confirmButton)
	RELEASE(_livePreviewSwitchInfo)
	RELEASE(_confirmButtonInfo)
	[super dealloc];
}

@end