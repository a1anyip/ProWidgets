//
//  ProWidgets
//  Notification Center
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "View.h"
#import "PWController.h"
#import "PWWidgetController.h"

NSUInteger iconPerPage = 5; // either 4 or 5

static char SBControlCenterButtonWidgetBundleKey;

CGFloat imageSize = 24.0;

static inline UIImage *scaleImage(UIImage *image) {
	
	if (image == nil || image.size.width == 0 || image.size.height == 0) return nil;
	
	// calculate the scaled image size
	CGFloat width = image.size.width;
	CGFloat height = image.size.height;
	
	if (width > imageSize || height > imageSize) {
		CGFloat factor = imageSize / MAX(width, height);
		width *= factor;
		height *= factor;
	}
	
	CGRect rect = CGRectMake(0, 0, width, height);
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	transform = CGAffineTransformTranslate(transform, 0.0, -image.size.height);
	CGContextConcatCTM(context, transform);
	
	CGRect flippedRect = CGRectApplyAffineTransform(rect, transform);
	CGContextDrawImage(context, flippedRect, image.CGImage);
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

@implementation PWNCView

- (instancetype)init {
	if ((self = [super init])) {
		
		_noVisibleWidgetLabel = [UILabel new];
		_noVisibleWidgetLabel.hidden = YES;
		_noVisibleWidgetLabel.font = [UIFont boldSystemFontOfSize:15.0];
		_noVisibleWidgetLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
		_noVisibleWidgetLabel.numberOfLines = 2;
		
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle new] autorelease];
		[style setLineSpacing:8.0];
		[style setAlignment:NSTextAlignmentCenter];
		
		NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:@"No visible widgets\nConfiguration in preference page"] autorelease];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [attributedString length])];
		_noVisibleWidgetLabel.attributedText = attributedString;
		
		[self addSubview:_noVisibleWidgetLabel];
		
		_scrollView = [UIScrollView new];
		_scrollView.scrollEnabled = YES;
		_scrollView.scrollsToTop = NO;
		_scrollView.pagingEnabled = YES;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.showsVerticalScrollIndicator = NO;
		[self addSubview:_scrollView];
	}
	return self;
}

- (void)layoutSubviews {
	
    [super layoutSubviews];
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	// layout label
	_noVisibleWidgetLabel.frame = self.bounds;
	
	if (_pages == nil || [_pages count] == 0) return;
	
	// layout scroll view
	_scrollView.frame = self.bounds;
	_scrollView.contentSize = CGSizeMake(width * [_pages count], height);
	
	// layout pages
	NSUInteger i = 0;
	for (PWNCButtonLayoutView *page in _pages) {
		CGRect rect = CGRectMake(width * i, 0, width, height);
		page.frame = rect;
		i++;
	}
}

- (void)resetPage {
	[_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)load {
	
	if (_pages != nil) {
		[self unload];
	}
	
	_pages = [NSMutableArray new];
	
	iconPerPage = MAX(1, iconPerPage);
	
	// load all available widgets
	PWController *controller = [PWController sharedInstance];
	NSArray *widgets = [controller visibleWidgets];
	NSUInteger count = [widgets count];
	NSUInteger pageCount = ceil(count / (CGFloat)iconPerPage);
	
	if (pageCount == 0) {
		_noVisibleWidgetLabel.hidden = NO;
		_scrollView.hidden = YES;
		[self setNeedsLayout];
		return;
	} else {
		_noVisibleWidgetLabel.hidden = YES;
		_scrollView.hidden = NO;
	}
	
	if (pageCount == 1) _scrollView.scrollEnabled = NO;
	else _scrollView.scrollEnabled = YES;
	
	PWNCButtonLayoutView *currentPage = nil;
	NSUInteger currentPageIndex = 1;
	NSUInteger currentIcon = 0;
	
	for (NSDictionary *widget in widgets) {
		
		if (currentPage == nil) {
			currentPage = [objc_getClass("PWNCButtonLayoutView") new];
			[_scrollView addSubview:currentPage];
			[_pages addObject:currentPage];
			[currentPage release];
		}
		
		NSBundle *bundle = widget[@"bundle"];
		UIImage *image = nil;
		
		// mask
		NSString *mask = widget[@"maskFile"];
		image = [UIImage imageNamed:mask inBundle:bundle];
		
		// unknown icon (fallback)
		if (image == nil) {
			image = [[PWController sharedInstance] imageResourceNamed:@"unknownMask"];
		}
		
		// make the mask smaller
		image = scaleImage(image);
		
		// create a button
		PWNCButton *button = [objc_getClass("PWNCButton") circularButtonWithGlyphImage:image];
		[button setHighlighted:NO];
		button.delegate = self;
		//button.sortKey = @(currentIcon);
		[currentPage addButton:button];
		
		objc_setAssociatedObject(button, &SBControlCenterButtonWidgetBundleKey, bundle, OBJC_ASSOCIATION_RETAIN);
		
		if (++currentIcon == iconPerPage) {
			
			// reset
			currentIcon = 1;
			currentPageIndex++;
			
			if (currentPageIndex <= pageCount) {
				currentPage = nil;
			}
		}
	}
	
	[self setNeedsLayout];
}

- (void)unload {
	
	for (SBCCButtonLayoutView *page in _pages) {
		[page removeFromSuperview];
	}
	
	[_pages release];
	_pages = nil;
}

- (void)buttonTapped:(SBControlCenterButton *)button {
	// reset the button's alpha
	[button setHighlighted:NO];
	// retrieve the corresponding widget bundle
	NSBundle *bundle = objc_getAssociatedObject(button, &SBControlCenterButtonWidgetBundleKey);
	if (bundle != nil) {
		// user info
		NSDictionary *userInfo = @{ @"from": @"notificationcenter" };
		// dismiss notification center
		[[objc_getClass("SBNotificationCenterController") sharedInstance] dismissAnimated:YES completion:^{
			// present the widget
			[PWWidgetController presentWidgetFromBundle:bundle userInfo:userInfo];
		}];
	}
}

- (void)dealloc {
	RELEASE_VIEW(_noVisibleWidgetLabel)
	RELEASE_VIEW(_scrollView)
	RELEASE(_pages)
	[super dealloc];
}

@end