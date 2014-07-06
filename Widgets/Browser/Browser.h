//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetBrowser : PWWidget {
	
	PWWidgetBrowserDefault _defaultBrowser;
	
	NSBundle *_safariBundle;
	UIImage *_reloadIcon;
	UIImage *_stopIcon;
	UIImage *_bookmarkIcon;
	UIImage *_folderIcon;
	
	PWWidgetBrowserInterface _currentInterface;
	NSArray *_webViewControllers;
	NSArray *_bookmarkViewControllers;
}

@property(nonatomic, assign) BOOL shouldAutoFocus;

@property(nonatomic, readonly) PWWidgetBrowserDefault defaultBrowser;

- (NSBundle *)safariBundle;
- (UIImage *)reloadIcon;
- (UIImage *)stopIcon;
- (UIImage *)bookmarkIcon;
- (UIImage *)folderIcon;

- (void)navigateToURL:(NSString *)url;
- (void)addBookmarkFromWebInterfaceWithTitle:(NSString *)title url:(NSString *)url animated:(BOOL)animated;

- (void)switchToWebInterface;
- (void)switchToBookmarkInterface;

+ (NSDictionary *)readChromeBookmarks;

@end