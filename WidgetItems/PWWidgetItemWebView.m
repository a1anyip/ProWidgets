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

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL {
	[self _setPendingContent:@{
		@"type": @"data",
		@"data": SAFE_VALUE(data),
		@"mime": SAFE_VALUE(MIMEType),
		@"encoding": SAFE_VALUE(encodingName),
		@"baseURL": SAFE_VALUE(baseURL)
	}];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
	[self _setPendingContent:@{
		@"type": @"string",
		@"string": SAFE_VALUE(string),
		@"baseURL": SAFE_VALUE(baseURL)
	}];
}

- (void)loadRequest:(NSURLRequest *)request {
	[self _setPendingContent:@{
		@"type": @"request",
		@"request": SAFE_VALUE(request)
	}];
}

- (void)_setPendingContent:(NSDictionary *)content {
	[_pendingContent release];
	_pendingContent = [content retain];
	[self setCellValue:nil];
}

- (void)_clearPendingContent {
	[_pendingContent release], _pendingContent = nil;
}

- (void)dealloc {
	RELEASE(_pendingContent)
	[super dealloc];
}

@end

@implementation PWWidgetItemWebViewCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier theme:(PWTheme *)theme {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier theme:theme])) {
		
		_webView = [UIWebView new];
		_webView.allowsInlineMediaPlayback = NO;
		_webView.mediaPlaybackAllowsAirPlay = NO;
		_webView.backgroundColor = [UIColor clearColor];
		_webView.opaque = NO;
		
		[self.contentView addSubview:_webView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_webView.frame = self.contentView.bounds;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {}

- (void)setValue:(id)value {
	
	PWWidgetItemWebView *item = (PWWidgetItemWebView *)self.item;
	
	if (item.pendingContent != nil) {
		
		NSDictionary *content = item.pendingContent;
		NSString *type = content[@"type"];
		
		if ([type isEqualToString:@"data"]) {
			
			NSData *data = RETRIEVE_VALUE(content[@"data"]);
			NSString *mime = RETRIEVE_VALUE(content[@"mime"]);
			NSString *encoding = RETRIEVE_VALUE(content[@"encoding"]);
			NSURL *baseURL = RETRIEVE_VALUE(content[@"baseURL"]);
			[_webView loadData:data MIMEType:mime textEncodingName:encoding baseURL:baseURL];
			
		} else if ([type isEqualToString:@"string"]) {
			
			NSString *string = RETRIEVE_VALUE(content[@"string"]);
			NSURL *baseURL = RETRIEVE_VALUE(content[@"baseURL"]);
			[_webView loadHTMLString:string baseURL:baseURL];
			
		} else if ([type isEqualToString:@"request"]) {
			
			NSURLRequest *request = RETRIEVE_VALUE(content[@"request"]);
			[_webView loadRequest:request];
		}
		
		//[item _clearPendingContent];
	}
}

//////////////////////////////////////////////////////////////////////

- (void)setInputTextColor:(UIColor *)color {
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	RELEASE_VIEW(_webView)
	[super dealloc];
}

@end