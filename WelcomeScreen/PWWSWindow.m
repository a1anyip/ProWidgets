//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWSWindow.h"
#import "PWWSTipView.h"
#import "../PWController.h"

#define BUTTON_NORMAL_ALPHA .25
#define BUTTON_HOVER_ALPHA .5

#define TIPS_COUNT 6

@implementation PWWSWindow

- (instancetype)init {
	if (self = [super init]) {
		
		// Window Levels
		// Snapshot Flash                   2201
		// (Cut/Copy) UITextEffectsWindow	2100
		// (Undo/Cancel) ~Alert window		1996
		// Notification Center				1056
		// Control Center					1056
		// === PWWindow ===					1055
		// Lock Alert Window				1050
		// UIWindowLevelStatusBar			1000
		
		self.windowLevel = 2200.9;
		self.backgroundColor = [UIColor whiteColor];
		self.userInteractionEnabled = YES;
		self.frame = [[UIScreen mainScreen] bounds];
		self.hidden = YES;
		
		_blurView = [[objc_getClass("_SBFakeBlurView") alloc] initWithVariant:0];
		_blurView.userInteractionEnabled = NO;
		[_blurView requestStyle:16];
		[self addSubview:_blurView];
		
		UIImage *logoImage = [[PWController sharedInstance] imageResourceNamed:@"WelcomeScreen/logo"];
		_logoView = [UIImageView new];
		_logoView.backgroundColor = [UIColor clearColor];
		_logoView.contentMode = UIViewContentModeScaleAspectFit;
		_logoView.image = logoImage;
		[self addSubview:_logoView];
		
		// welcome views
		_welcomeTitleLabel = [UILabel new];
		_welcomeTitleLabel.font = [UIFont boldSystemFontOfSize:26.0];
		_welcomeTitleLabel.text = CT(@"Welcome");
		_welcomeTitleLabel.textAlignment = NSTextAlignmentCenter;
		_welcomeTitleLabel.textColor = [UIColor blackColor];
		[self addSubview:_welcomeTitleLabel];
		
		_welcomeMessageLabel = [UILabel new];
		_welcomeMessageLabel.font = [UIFont systemFontOfSize:17.0];
		_welcomeMessageLabel.text = CT(@"WelcomeMessage");
		_welcomeMessageLabel.numberOfLines = 0;
		_welcomeMessageLabel.textAlignment = NSTextAlignmentCenter;
		_welcomeMessageLabel.textColor = [UIColor blackColor];
		_welcomeMessageLabel.alpha = .4;
		[self addSubview:_welcomeMessageLabel];
		
		_buttonBackgroundView = [UIView new];
		_buttonBackgroundView.backgroundColor = [UIColor whiteColor];
		_buttonBackgroundView.alpha = BUTTON_NORMAL_ALPHA;
		[self addSubview:_buttonBackgroundView];
		
		_button = [UIButton new];
		_button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22.0];
		_button.backgroundColor = [UIColor clearColor];
		[_button setTitleColor:[UIColor colorWithWhite:0.0 alpha:.6] forState:UIControlStateNormal];
		[_button setTitle:CT(@"Proceed") forState:UIControlStateNormal];
		[_button addTarget:self action:@selector(buttonTouchDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside | UIControlEventTouchDragEnter];
		[_button addTarget:self action:@selector(buttonTouchUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchDragOutside | UIControlEventTouchDragExit | UIControlEventTouchCancel];
		[_button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_button];
		
		// overlay view
		_overlayView = [UIView new];
		_overlayView.backgroundColor = [UIColor whiteColor];
		_overlayView.alpha = 1.0;
		[self addSubview:_overlayView];
		
		[self adjustLayout];
	}
	return self;
}

- (void)adjustLayout {
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	
	CGFloat topMargin = 50.0;
	CGFloat logoHeight = 48.5;
	CGFloat buttonHeight = 70.0;
	
	CGFloat welcomeTitleHeight = 45.0;
	CGFloat welcomeMessageHeight = 120.0;
	CGFloat welcomeMessageMargin = 20.0;
	CGFloat welcomeContentTop = (height - welcomeTitleHeight - welcomeMessageHeight) / 2;
	
	CGFloat bottomMargin = 45.0;
	CGFloat scrollViewTopMargin = 30.0;
	CGFloat scrollViewTop = topMargin + logoHeight + scrollViewTopMargin;
	CGFloat scrollViewHeight = height - (scrollViewTop + bottomMargin);
	
	CGRect welcomeTitleRect = CGRectMake(0, welcomeContentTop, width, welcomeTitleHeight);
	CGRect welcomeMessageRect = CGRectMake(welcomeMessageMargin, welcomeContentTop + welcomeTitleHeight, width - welcomeMessageMargin * 2, welcomeMessageHeight);
	CGRect buttonRect = CGRectMake(0, height - buttonHeight, width, buttonHeight);
	
	CGRect scrollViewRect = CGRectMake(0, scrollViewTop, width, scrollViewHeight);
	CGSize pageControlSize = [_pageControl sizeForNumberOfPages:TIPS_COUNT];
	CGRect pageControlRect = CGRectMake((width - pageControlSize.width) / 2, scrollViewTop + scrollViewHeight + (height - scrollViewTop - scrollViewHeight - pageControlSize.height) / 2, pageControlSize.width, pageControlSize.height);
	
	// global views
	_overlayView.frame = self.bounds;
	_blurView.frame = self.bounds;
	_logoView.frame = CGRectMake(0, topMargin, width, logoHeight);
	
	// welcome views
	_welcomeTitleLabel.frame = welcomeTitleRect;
	_welcomeMessageLabel.frame = welcomeMessageRect;
	_buttonBackgroundView.frame = buttonRect;
	_button.frame = buttonRect;
	
	// tips views
	_scrollView.frame = scrollViewRect;
	_pageControl.frame = pageControlRect;
}

- (void)fadeOutOverlayView {
	_overlayView.alpha = 1.0;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		[UIView animateWithDuration:.5 animations:^{
			_overlayView.alpha = 0.0;
		} completion:^(BOOL finished) {
			RELEASE_VIEW(_overlayView)
		}];
	});
}

- (void)buttonTouchDown {
	[UIView animateWithDuration:.1 animations:^{
		_buttonBackgroundView.alpha = BUTTON_HOVER_ALPHA;
	}];
}

- (void)buttonTouchUp {
	[UIView animateWithDuration:.1 animations:^{
		_buttonBackgroundView.alpha = BUTTON_NORMAL_ALPHA;
	}];
}

- (void)buttonPressed {
	if (!_showingTips) {
		_showingTips = YES;
		[self proceed];
	} else if (_ready) {
		_ready = NO;
		[[PWController sharedInstance] _hideWelcomeScreen];
	}
}

- (void)show {
	self.userInteractionEnabled = YES;
	self.hidden = NO;
	self.alpha = 1.0;
	[self fadeOutOverlayView];
	//[[objc_getClass("SBBacklightController") sharedInstance] setBacklightFactor:1.0 source:0];
}

- (void)hide {
	self.userInteractionEnabled = NO;
	self.alpha = 1.0;
	[UIView animateWithDuration:.4 animations:^{
		self.alpha = 0.0;
	} completion:^(BOOL finished) {
		self.hidden = YES;
	}];
}

- (void)proceed {
	
	[self prepareScrollView];
	
	[UIView animateWithDuration:.3 animations:^{
		
		// hide welcome views
		_welcomeTitleLabel.alpha = 0.0;
		_welcomeMessageLabel.alpha = 0.0;
		_buttonBackgroundView.alpha = 0.0;
		_button.alpha = 0.0;
		
		// show tips views
		_scrollView.alpha = 1.0;
		_pageControl.alpha = 1.0;
	}];
}

- (void)prepareScrollView {
	
	_scrollView = [UIScrollView new];
	_scrollView.alpha = 0.0;
	_scrollView.scrollEnabled = YES;
	_scrollView.pagingEnabled = YES;
	_scrollView.alwaysBounceHorizontal = YES;
	_scrollView.alwaysBounceVertical = NO;
	_scrollView.showsHorizontalScrollIndicator = NO;
	_scrollView.showsVerticalScrollIndicator = NO;
	_scrollView.delegate = self;
	[self addSubview:_scrollView];
	
	_pageControl = [UIPageControl new];
	_pageControl.userInteractionEnabled = NO;
	_pageControl.alpha = 0.0;
	_pageControl.numberOfPages = TIPS_COUNT;
	_pageControl.currentPage = 0;
	_pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:.3];
	_pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:.8];
	[self addSubview:_pageControl];
	
	// adjust layout before adding tip views to scroll view
	[self adjustLayout];
	
	NSUInteger currentPage = 0;
	CGFloat pageWidth = _scrollView.bounds.size.width;
	CGFloat pageHeight = _scrollView.bounds.size.height;
	
	NSArray *tips = [self tips];
	
	for (NSDictionary *tip in tips) {
		
		NSString *title = tip[@"title"];
		NSString *content = tip[@"content"];
		NSString *imageName = tip[@"imageName"];
		
		PWWSTipView *tipView = [[PWWSTipView alloc] initWithTitle:title content:content imageName:imageName];
		tipView.frame = CGRectMake(currentPage * pageWidth, 0, pageWidth, pageHeight);
		[_scrollView addSubview:tipView];
		[tipView release];
		
		currentPage++;
	}
	
	UILabel *hiddenLabel = [UILabel new];
	hiddenLabel.font = [UIFont fontWithName:@"GillSans" size:20.0];
	hiddenLabel.text = @"I love doing this too :p";
	hiddenLabel.textColor = [UIColor blackColor];
	hiddenLabel.textAlignment = NSTextAlignmentCenter;
	hiddenLabel.alpha = 0.3;
	hiddenLabel.bounds = CGRectMake(0, 0, pageWidth, 30.0);
	hiddenLabel.center = CGPointMake(pageWidth * currentPage + pageWidth / 2, pageHeight / 2);
	hiddenLabel.transform = CGAffineTransformMakeRotation(M_PI / 2);
	[_scrollView addSubview:hiddenLabel];
	[hiddenLabel release];
	
	_scrollView.contentSize = CGSizeMake(pageWidth * currentPage, pageHeight);
}

- (NSArray *)tips {
	
#define ADD_TIP(title,content,image) [tips addObject:@{ @"title":CT(title), @"content":CT(content), @"imageName":image }];
	
	NSMutableArray *tips = [NSMutableArray array];
	
	ADD_TIP(@"TipConvenienceTitle", @"TipConvenienceContent", @"TipConvenience")
	ADD_TIP(@"TipUsageTitle", @"TipUsageContent", @"TipUsage")
	ADD_TIP(@"TipMaximizedWidgetTitle", @"TipMaximizedContent", @"TipMaximizedWidget")
	ADD_TIP(@"TipMinimizedWidgetTitle", @"TipMinimizedWidgetContent", @"TipMinimizedWidget")
	ADD_TIP(@"TipThirdPartyAddonsTitle", @"TipThirdPartyAddonsContent", @"TipThirdPartyAddons")
	ADD_TIP(@"TipReadyTitle", @"TipReadyContent", @"TipReady")
	
	return tips;
	
#undef ADD_TIP
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	CGFloat pageWidth = scrollView.bounds.size.width;
	NSInteger currentPage = round(scrollView.contentOffset.x / pageWidth);
	_pageControl.currentPage = currentPage;
	
	_ready = NO;
	[UIView animateWithDuration:.2 animations:^{
		_pageControl.alpha = 1.0;
		_buttonBackgroundView.alpha = 0.0;
		_button.alpha = 0.0;
	}];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	CGFloat pageWidth = scrollView.bounds.size.width;
	NSInteger currentPage = round(scrollView.contentOffset.x / pageWidth);
	if (currentPage == TIPS_COUNT - 1) {
		
		_ready = YES;
		[_button setTitle:@"Continue" forState:UIControlStateNormal];
		
		// last page
		[UIView animateWithDuration:.2 animations:^{
			_pageControl.alpha = 0.0;
			_buttonBackgroundView.alpha = BUTTON_NORMAL_ALPHA;
			_button.alpha = 1.0;
		}];
	}
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE_VIEW(_overlayView)
	RELEASE_VIEW(_blurView)
	RELEASE_VIEW(_logoView)
	RELEASE_VIEW(_buttonBackgroundView)
	RELEASE_VIEW(_button)
	RELEASE_VIEW(_scrollView)
	RELEASE_VIEW(_pageControl)
	[super dealloc];
}

@end