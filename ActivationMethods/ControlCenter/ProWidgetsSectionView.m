//
//  ProWidgetsSectionView.m
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "header.h"
#import "ProWidgetsSectionView.h"
#import "PWController.h"

NSUInteger iconPerPage = 4; // either 4 or 5

static char SBControlCenterButtonWidgetBundleKey;

@implementation ProWidgetsSectionView

- (instancetype)init {
	if ((self = [super init])) {
		
		_noVisibleWidgetLabel = [UILabel new];
		_noVisibleWidgetLabel.hidden = YES;
		_noVisibleWidgetLabel.font = [UIFont boldSystemFontOfSize:15.0];
		_noVisibleWidgetLabel.textColor = [UIColor colorWithWhite:0 alpha:0.5];
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
	for (PWButtonLayoutView *page in _pages) {
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
	
	PWButtonLayoutView *currentPage = nil;
	NSUInteger currentPageIndex = 1;
	NSUInteger currentIcon = 0;
	
	for (NSDictionary *widget in widgets) {
		
		if (currentPage == nil) {
			currentPage = [objc_getClass("PWButtonLayoutView") new];
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
		
		// create a button
		SBControlCenterButton *button = [objc_getClass("SBControlCenterButton") roundRectButtonWithGlyphImage:image];
		button.delegate = self;
		button.sortKey = @(currentIcon);
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
	// make the button glow
	[button setSelected:YES];
	// retrieve the corresponding widget bundle
	NSBundle *bundle = objc_getAssociatedObject(button, &SBControlCenterButtonWidgetBundleKey);
	if (bundle != nil) {
		// user info
		NSDictionary *userInfo = @{ @"from": @"controlcenter" };
		// dismiss control center
		[[objc_getClass("SBControlCenterController") sharedInstance] dismissAnimated:YES];
		// present the widget
		[[PWController sharedInstance] presentWidgetFromBundle:bundle userInfo:userInfo];
	}
}

- (void)dealloc {
	RELEASE_VIEW(_noVisibleWidgetLabel)
	RELEASE_VIEW(_scrollView)
	RELEASE(_pages)
	[super dealloc];
}

@end
