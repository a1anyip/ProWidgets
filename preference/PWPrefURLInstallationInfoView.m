#import "PWPrefURLInstallationInfoView.h"
#import "../PWTheme.h"

extern NSBundle *bundle;

@implementation PWPrefURLInstallationInfoView

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
		
		// add separator
		_separator = [UIView new];
		_separator.backgroundColor = [UIColor colorWithWhite:.8 alpha:1.0];
		[self addSubview:_separator];
		
		// add description text view
		CGFloat padding = 15.0;
		_descriptionTextView = [UITextView new];
		_descriptionTextView.editable = NO;
		_descriptionTextView.selectable = YES;
		_descriptionTextView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:.5];
		_descriptionTextView.textColor = [UIColor colorWithWhite:.3 alpha:1.0];
		_descriptionTextView.font = [UIFont systemFontOfSize:16];
		_descriptionTextView.textContainer.lineFragmentPadding = 0;
		_descriptionTextView.textContainerInset = UIEdgeInsetsMake(padding, padding, padding, padding);
		[self addSubview:_descriptionTextView];
		
		// add confirm button
		_confirmButton = [UIButton new];
		_confirmButton.adjustsImageWhenHighlighted = YES;
		[_confirmButton setTitle:@"Install" forState:UIControlStateNormal];
		[_confirmButton setBackgroundImage:[PWTheme imageFromColor:[PWTheme systemBlueColor]] forState:UIControlStateNormal];
		[self addSubview:_confirmButton];
	}
	return self;
}

- (void)didMoveToSuperview {
	[_confirmButton addTarget:[self.superview nextResponder] action:@selector(confirmInstallation) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	CGFloat iconSize = 25.0;
	CGFloat nameHeight = 40.0;
	CGFloat authorHeight = 40.0;
	CGFloat buttonHeight = 60.0;
	
	CGFloat topMargin = 20.0 + 44.0;
	CGFloat xMargin = 15.0;
	CGFloat yMargin = 10.0;
	CGFloat nameLeftPadding = 15.0;
	CGFloat authorPadding = 3.0;
	
	CGRect iconRect = CGRectMake(xMargin, yMargin + (nameHeight - iconSize) / 2 + topMargin, iconSize, iconSize);
	
	CGRect nameRect = CGRectMake(iconRect.origin.x + iconRect.size.width + nameLeftPadding, yMargin + topMargin, 0, nameHeight);
	nameRect.size.width = width - xMargin - nameRect.origin.x;
	
	CGRect authorRect = CGRectMake(xMargin + authorPadding, iconRect.origin.y + iconRect.size.height, width - xMargin * 2 - authorPadding, authorHeight);
	
	CGRect separatorRect = CGRectMake(0, authorRect.origin.y + authorRect.size.height + yMargin - 1.0, width, 1.0);
	
	CGRect descriptionRect = CGRectMake(0, separatorRect.origin.y + 1.0, width, 0);
	descriptionRect.size.height = height - descriptionRect.origin.y - buttonHeight;
	
	CGRect buttonRect = CGRectMake(0, height - buttonHeight, width, buttonHeight);
	
	_iconView.frame = iconRect;
	_nameLabel.frame = nameRect;
	_authorLabel.frame = authorRect;
	_separator.frame = separatorRect;
	_descriptionTextView.frame = descriptionRect;
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

- (void)dealloc {
	RELEASE_VIEW(_iconView)
	RELEASE_VIEW(_nameLabel)
	RELEASE_VIEW(_authorLabel)
	RELEASE_VIEW(_separator)
	RELEASE_VIEW(_descriptionTextView)
	RELEASE_VIEW(_confirmButton)
	[super dealloc];
}

@end