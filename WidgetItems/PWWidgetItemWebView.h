//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"

@interface PWWidgetItemWebView : PWWidgetItem {
	
	UIWebView *_webView;
}

@property (nonatomic, readonly) UIWebView *webView;

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)encodingName baseURL:(NSURL *)baseURL;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadRequest:(NSURLRequest *)request;

@end

@interface PWWidgetItemWebViewCell : PWWidgetItemCell {
	
	UIWebView *_itemWebView;
}

@end