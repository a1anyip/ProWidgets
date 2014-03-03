//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PrivateWebView.h"
#import <objc/message.h>

@implementation PWWidgetBrowserPrivateWebView

- (void)webView:(WebView *)webView didStartProvisionalLoadForFrame:(WebFrame *)frame {
	
	if ([super respondsToSelector:@selector(webView:didStartProvisionalLoadForFrame:)]) {
		[super webView:webView didStartProvisionalLoadForFrame:frame];
	}
	
	if ([self.delegate respondsToSelector:@selector(webView:didStartProvisionalLoadForFrame:)]) {
		[(id)self.delegate webView:webView didStartProvisionalLoadForFrame:frame];
	}
}

- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame {
	
	if ([super respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
		[super webView:webView didCommitLoadForFrame:frame];
	}
	
	if ([self.delegate respondsToSelector:@selector(webView:didCommitLoadForFrame:)]) {
		[(id)self.delegate webView:webView didCommitLoadForFrame:frame];
	}
}

- (void)webView:(WebView *)webView didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
	
	if ([super respondsToSelector:@selector(webView:didReceiveTitle:forFrame:)]) {
		[super webView:webView didReceiveTitle:title forFrame:frame];
	}
	
	if ([self.delegate respondsToSelector:@selector(webView:didReceiveTitle:forFrame:)]) {
		[(id)self.delegate webView:webView didReceiveTitle:title forFrame:frame];
	}
}

@end