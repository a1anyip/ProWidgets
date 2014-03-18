//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Browser.h"
#import "Web.h"
#import "Bookmark.h"
#import "Add.h"

#define SAFARI_BUNDLE_PATH @"/Applications/MobileSafari.app/"
#define ChromeIdentifier @"com.google.chrome.ios"

#define ICON_GETTER(ivar, name) - (UIImage *)ivar {\
	if (_##ivar == nil) {\
		_##ivar = [[[UIImage imageNamed:name inBundle:[self safariBundle]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];\
	}\
	return _##ivar;\
}

@implementation PWWidgetBrowser

- (void)load {
	
	// get the preference of default browser
	_defaultBrowser = [self intValueForPreferenceKey:@"defaultBrowser" defaultValue:(NSInteger)PWWidgetBrowserDefaultSafari] == (NSInteger)PWWidgetBrowserDefaultChrome ? PWWidgetBrowserDefaultChrome : PWWidgetBrowserDefaultSafari;
	
	if (_defaultBrowser == PWWidgetBrowserDefaultChrome) {
		[self showMessage:@"Setting Chrome as the default browser is not supported yet."];
		[self dismiss];
		return;
	}
	
	NSDictionary *userInfo = self.userInfo;
	NSString *url = userInfo[@"url"];
	
	if (url != nil) {
		[self navigateToURL:url];
	} else {
		PWWidgetBrowserInterface defaultInterface = PWWidgetBrowserInterfaceWeb;
		if (defaultInterface == PWWidgetBrowserInterfaceWeb) {
			[self switchToWebInterface];
		} else {
			[self switchToBookmarkInterface];
		}
	}
}

- (void)userInfoChanged:(NSDictionary *)userInfo {
	
	NSString *from = userInfo[@"from"];
	NSString *title = userInfo[@"title"];
	NSString *url = userInfo[@"url"];
	
	if (url == nil) return;
	
	if ([from isEqualToString:@"addBookmark"]) {
		[self addBookmarkFromWebInterfaceWithTitle:title url:url animated:NO];
	} else {
		[self navigateToURL:url];
	}
}

- (NSBundle *)safariBundle {
	if (_safariBundle == nil) {
		_safariBundle = [[NSBundle bundleWithPath:SAFARI_BUNDLE_PATH] retain];
	}
	return _safariBundle;
}

ICON_GETTER(reloadIcon, @"NavigationBarReload")
ICON_GETTER(stopIcon, @"NavigationBarStopLoading")
ICON_GETTER(bookmarkIcon, @"Bookmark")
ICON_GETTER(folderIcon, @"BookmarksListFolder")

- (void)navigateToURL:(NSString *)url {
	
	[self switchToWebInterface];
	
	PWWidgetBrowserWebViewController *controller = [_webViewControllers firstObject];
	if (controller != nil) {
		[controller loadURLString:url];
	}
}

- (void)addBookmarkFromWebInterfaceWithTitle:(NSString *)title url:(NSString *)url animated:(BOOL)animated {
	
	if (_currentInterface == PWWidgetBrowserInterfaceBookmark) {
		[self switchToWebInterface];
	}
	
	PWWidgetBrowserWebViewController *webViewController = (PWWidgetBrowserWebViewController *)_webViewControllers[0];
	[webViewController configureBackButton];
	
	PWWidgetBrowserAddBookmarkViewController *addViewController = [[[PWWidgetBrowserAddBookmarkViewController alloc] initForWidget:self] autorelease];
	[addViewController updatePrefillTitle:title andAddress:url];
	
	[self pushViewController:addViewController animated:animated];
}

- (void)switchToWebInterface {
	
	if (_currentInterface == PWWidgetBrowserInterfaceWeb) return;
	
	if (_webViewControllers == nil) {
		PWWidgetBrowserWebViewController *webViewController = [[[PWWidgetBrowserWebViewController alloc] initForWidget:self] autorelease];
		_webViewControllers = [@[webViewController] copy];
	}
	
	// update bookmark view controllers
	if (_bookmarkViewControllers != nil) {
		[_bookmarkViewControllers release];
		_bookmarkViewControllers = [self.navigationController.viewControllers copy];
	}
	
	[self setViewControllers:_webViewControllers animated:YES];
	_currentInterface = PWWidgetBrowserInterfaceWeb;
}

- (void)switchToBookmarkInterface {
	
	if (_currentInterface == PWWidgetBrowserInterfaceBookmark) return;
	
	if (_bookmarkViewControllers == nil) {
		PWWidgetBrowserBookmarkViewController *bookmarkViewController = [[[PWWidgetBrowserBookmarkViewController alloc] initForWidget:self] autorelease];
		bookmarkViewController.isRoot = YES;
		_bookmarkViewControllers = [@[bookmarkViewController] copy];
	}
	
	[self setViewControllers:_bookmarkViewControllers animated:YES];
	_currentInterface = PWWidgetBrowserInterfaceBookmark;
}
/*
+ (NSDictionary *)readChromeBookmarks {
	
	SBApplicationController *controller = [objc_getClass("SBApplicationController") sharedInstance];
	SBApplication *chromeApp = [controller applicationWithDisplayIdentifier:ChromeIdentifier];
	if (chromeApp == nil) return nil;
	
	NSString *chromeBookmarkPath = [NSString stringWithFormat:@"%@/Library/Application Support/Google/Chrome/Default/Bookmarks", chromeApp.sandboxPath];
	NSData *data = [NSData dataWithContentsOfFile:chromeBookmarkPath];
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	NSDictionary *roots = json[@"roots"];
	
	for (NSString *key in roots) {
		
		NSDictionary *rootFolder = roots[key];
		if (![rootFolder isKindOfClass:[NSDictionary class]]) continue;
		
		NSString *name = rootFolder[@"name"];
		NSString *type = rootFolder[@"type"];
		if (![type isEqualToString:@"folder"]) continue;
		
		LOG(@"key: %@", key);
		LOG(@"name: %@", name);
	}
	
	return nil;//json;
}
*/
- (void)dealloc {
	RELEASE(_webViewControllers)
	RELEASE(_bookmarkViewControllers)
	RELEASE(_reloadIcon)
	RELEASE(_stopIcon)
	RELEASE(_bookmarkIcon)
	RELEASE(_folderIcon)
	RELEASE(_safariBundle)
	[super dealloc];
}

@end