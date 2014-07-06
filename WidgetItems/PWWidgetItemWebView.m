//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemWebView.h"

#define SAFE_VALUE(x) (x == nil ? [NSNull null] : x)
#define RETRIEVE_VALUE(x) ([x isKindOfClass:[NSNull class]] ? nil : x)

@implementation PWWidgetItemWebView

+ (Class)cellClass {
	return [PWWidgetItemWebViewCell class];
}

- (instancetype)init {
	if ((self = [super init])) {
		
		_webView = [UIWebView new];
		//_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_webView.allowsInlineMediaPlayback = NO;
		_webView.mediaPlaybackAllowsAirPlay = NO;
		_webView.backgroundColor = [UIColor clearColor];
		_webView.opaque = NO;
	}
	return self;
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
	[_webView loadData:data MIMEType:MIMEType textEncodingName:encodingName baseURL:baseURL];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	[_webView loadHTMLString:string baseURL:baseURL];
}

- (void)loadRequest:(NSURLRequest *)request {
	[_webView loadRequest:request];
}

- (void)dealloc {
	RELEASE_VIEW(_webView);
	[super dealloc];
}

@end

@implementation PWWidgetItemWebViewCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
	[super layoutSubviews];
	_itemWebView.frame = self.bounds;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {}

- (void)updateItem:(PWWidgetItemWebView *)item {
	
	if (item.webView != _itemWebView || item.webView.superview != self.contentView) {
	
		// remove everything in content view
		for (UIView *subview in self.contentView.subviews) {
			[subview removeFromSuperview];
		}
		
		_itemWebView = item.webView;
		[_itemWebView removeFromSuperview];
		[self.contentView addSubview:_itemWebView];
	}
	
	[self setNeedsLayout];
}

//////////////////////////////////////////////////////////////////////

- (void)setInputTextColor:(UIColor *)color {
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	_itemWebView = nil;
	[super dealloc];
}

@end