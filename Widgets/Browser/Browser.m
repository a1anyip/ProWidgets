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
	NSInteger defaultBrowserValue = (NSInteger)[self intValueForPreferenceKey:@"defaultBrowser" defaultValue:(NSInteger)PWWidgetBrowserDefaultSafari];
	_defaultBrowser = defaultBrowserValue == PWWidgetBrowserDefaultChrome ? PWWidgetBrowserDefaultChrome : PWWidgetBrowserDefaultSafari;
	
	/*
	if (_defaultBrowser == PWWidgetBrowserDefaultChrome) {
		[self showMessage:@"Setting Chrome as the default browser is not supported yet."];
		[self dismiss];
		return;
	}
	*/
	
	NSDictionary *userInfo = self.userInfo;
	NSString *url = userInfo[@"url"];
	
	if (url != nil) {
		self.shouldAutoFocus = NO;
	}
	
	PWWidgetBrowserInterface defaultInterface = PWWidgetBrowserInterfaceWeb;
	if (defaultInterface == PWWidgetBrowserInterfaceWeb) {
		[self switchToWebInterface];
	} else {
		[self switchToBookmarkInterface];
	}
}

- (void)userInfoChanged:(NSDictionary *)userInfo {
	
	NSString *from = userInfo[@"from"];
	NSURL *url = userInfo[@"url"];
	NSString *urlString = [url absoluteString];
	if (url == nil || urlString == nil) goto end;
	
	if ([from isEqualToString:@"addBookmark"]) {
		NSString *title = userInfo[@"title"];
		[self addBookmarkFromWebInterfaceWithTitle:title url:urlString animated:NO];
	} else {
		[self navigateToURL:urlString];
	}
	
end:
	self.userInfo = nil; // reset user info
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
	
	if (_defaultBrowser == PWWidgetBrowserDefaultChrome) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Adding bookmark to Chrome is not supported yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		PWWidgetBrowserWebViewController *controller = [_webViewControllers firstObject];
		[controller.webView.textField resignFirstResponder];
		
	} else {
	
		PWWidgetBrowserWebViewController *webViewController = (PWWidgetBrowserWebViewController *)_webViewControllers[0];
		[webViewController configureBackButton];
		
		PWWidgetBrowserAddBookmarkViewController *addViewController = [[[PWWidgetBrowserAddBookmarkViewController alloc] initForWidget:self] autorelease];
		[addViewController updatePrefillTitle:title andAddress:url];
		
		[self pushViewController:addViewController animated:animated];
	}
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

+ (NSArray *)readChromeBookmarks {
	
	SBApplicationController *controller = [objc_getClass("SBApplicationController") sharedInstance];
	SBApplication *chromeApp = [controller applicationWithDisplayIdentifier:ChromeIdentifier];
	if (chromeApp == nil) return nil;
	
	NSString *chromeBookmarkPath = [NSString stringWithFormat:@"%@/Library/Application Support/Google/Chrome/Default/Bookmarks", chromeApp.sandboxPath];
	NSData *data = [NSData dataWithContentsOfFile:chromeBookmarkPath];
	
	NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
	NSDictionary *roots = json[@"roots"];
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	__block NSArray *(^iterateItems)(NSArray *) = ^NSArray *(NSArray *parent) {
		
		if (parent == nil) {
			return nil;
		}
		
		NSMutableArray *items = [NSMutableArray array];
		
		for (NSDictionary *root in parent) {
			
			if (![root isKindOfClass:[NSDictionary class]]) continue;
			
			NSNumber *identifier = [formatter numberFromString:root[@"id"]];
			NSString *name = root[@"name"];
			NSString *type = root[@"type"];
			NSString *url = root[@"url"];
			BOOL isFolder = [type isEqualToString:@"folder"];
			
			if (identifier == nil) continue;
			if (name == nil) name = @"";
			if (url == nil) url = @"";
			
			NSMutableDictionary *row = [[@{ @"identifier": identifier, @"title": name, @"address": url, @"isFolder": @(isFolder) } mutableCopy] autorelease];
			
			NSArray *children = isFolder ? iterateItems(root[@"children"]) : nil;
			if (children != nil) {
				row[@"children"] = children;
			}
			
			[items addObject:row];
		}
		
		return items;
	};
	
	NSMutableArray *rootArray = [NSMutableArray array];
	for (NSString *key in roots) {
		NSDictionary *item = roots[key];
		[rootArray addObject:item];
	}
	
	NSArray *result = iterateItems(rootArray);
	RELEASE(formatter)
	
	return result;
}

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