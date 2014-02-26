//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemableTableViewCell.h"
#import "PWController.h"
#import "PWTheme.h"

static UIColor *separatorColor = nil;

@implementation PWThemableTableViewCell

+ (void)setSeparatorColor:(UIColor *)color {
	[separatorColor release];
	separatorColor = [color retain];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		_customSeparatorView = [UIView new];
		_customSeparatorView.userInteractionEnabled = NO;
		[self addSubview:_customSeparatorView];
	}
	return self;
}

//////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
	if (newSuperview != nil)
		[self _configureAppearance];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self _configureAppearance];
	CGSize size = self.bounds.size;
	_customSeparatorView.frame = CGRectMake(0, size.height - .5, size.width, .5);
	_customSeparatorView.backgroundColor = separatorColor;
}

- (void)_configureAppearance {
	
	if (_configuredAppearance) return;
	_configuredAppearance = YES;
	
	PWTheme *theme = [PWController activeTheme];
	PWWidgetOrientation orientation = [PWController currentOrientation];
	
	//LOG(@"PWThemableTableViewCell: configure appearance for active theme: %@", theme);
	
	// cell tint color
	[self setTintColor:[theme cellTintColor]];
	
	// normal state
	[self setBackgroundImage:[theme cellBackgroundImageForOrientation:orientation] forOrientation:orientation];
	[self setBackgroundColor:[theme cellBackgroundColor]];
	[self setTitleTextColor:[theme cellTitleTextColor]];
	[self setValueTextColor:[theme cellValueTextColor]];
	[self setButtonTextColor:[theme cellButtonTextColor]];
	[self setInputTextColor:[theme cellInputTextColor]];
	[self setInputPlaceholderTextColor:[theme cellInputPlaceholderTextColor]];
	[self setPlainTextColor:[theme cellPlainTextColor]];
	
	// selected state
	[self setSelectedBackgroundImage:[theme cellSelectedBackgroundImageForOrientation:orientation] forOrientation:orientation];
	[self setSelectedBackgroundColor:[theme cellSelectedBackgroundColor]];
	[self setSelectedTitleTextColor:[theme cellSelectedTitleTextColor]];
	[self setSelectedValueTextColor:[theme cellSelectedValueTextColor]];
	[self setSelectedButtonTextColor:[theme cellSelectedButtonTextColor]];
	
	// switch
	[self setSwitchOnColor:[theme cellSwitchOnColor]];
	[self setSwitchOffColor:[theme cellSwitchOffColor]];
	
	[self setNeedsLayout];
}

////////// Normal //////////

- (void)setBackgroundImage:(UIImage *)image forOrientation:(PWWidgetOrientation)orientation {
	
	[super setBackgroundColor:[UIColor clearColor]];
	
	if (self.backgroundView != nil && [self.backgroundView isKindOfClass:[UIImageView class]]) {
		// set its image
		UIImageView *backgroundView = (UIImageView *)self.backgroundView;
		backgroundView.image = image;
	} else {
		// create a new image view
		self.backgroundView = [[[UIImageView alloc] initWithImage:image] autorelease];
	}
}

- (void)setBackgroundColor:(UIColor *)color {
	
	//[super setBackgroundColor:[UIColor clearColor]];
	
	if (self.backgroundView == nil) {
		self.backgroundView = [[UIImageView new] autorelease];
	}
	
	self.backgroundView.backgroundColor = color;
}

- (void)setTitleTextColor:(UIColor *)color {
	self.textLabel.textColor = color;
}

- (void)setValueTextColor:(UIColor *)color {
	self.detailTextLabel.textColor = color;
}

- (void)setButtonTextColor:(UIColor *)color {}

- (void)setInputTextColor:(UIColor *)color {}

- (void)setInputPlaceholderTextColor:(UIColor *)color {}

- (void)setPlainTextColor:(UIColor *)color {}

////////// Selected //////////

- (void)setSelectedBackgroundImage:(UIImage *)image forOrientation:(PWWidgetOrientation)orientation {
	
	if (self.selectedBackgroundView != nil && [self.selectedBackgroundView isKindOfClass:[UIImageView class]]) {
		// set its image
		UIImageView *backgroundView = (UIImageView *)self.selectedBackgroundView;
		backgroundView.image = image;
	} else {
		// create a new image view
		self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:image] autorelease];
	}
}

- (void)setSelectedBackgroundColor:(UIColor *)color {
	
	[super setBackgroundColor:[UIColor clearColor]];
	
	if (self.selectedBackgroundView == nil) {
		self.selectedBackgroundView = [[UIImageView new] autorelease];
	}
	
	self.selectedBackgroundView.backgroundColor = color;
}

- (void)setSelectedTitleTextColor:(UIColor *)color {
	self.textLabel.highlightedTextColor = color;
}

- (void)setSelectedValueTextColor:(UIColor *)color {
	self.detailTextLabel.highlightedTextColor = color;
}

- (void)setSelectedButtonTextColor:(UIColor *)color {}

////////// Switch //////////

- (void)setSwitchOnColor:(UIColor *)color {}
- (void)setSwitchOffColor:(UIColor *)color {}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	DEALLOCLOG;
	RELEASE_VIEW(_customSeparatorView)
	[super dealloc];
}

@end