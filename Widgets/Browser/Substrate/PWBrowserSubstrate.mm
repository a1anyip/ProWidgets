//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

#define PREF_PATH @"/var/mobile/Library/Preferences/cc.tweak.prowidgets.widget.browser.plist"

@interface UIWebClip : NSObject

- (NSURL *)pageURL;

@end

@interface SBBookmarkIcon : NSObject

- (UIWebClip *)webClip;

@end

static BOOL enabledOpenInApp = NO;
static BOOL enabledOpenFromIcon = NO;
static BOOL enabledAddToBookmark = NO;

static inline BOOL openBrowserWithURL(NSString *url, NSString *from) {
	if (url == nil) return NO;
	NSDictionary *userInfo = @{ @"from": @"app", @"url": url };
	return [objc_getClass("PWWidgetController") presentWidgetNamed:@"Browser" userInfo:userInfo];
}

static inline NSString *ReplaceReadingListTitle(NSString *title) {
	
	if (enabledAddToBookmark) {
		if ([title isEqualToString:@"Add to Reading List"]) {
			return @"Bookmark";
		}
	}
	
	return title;
}

%group App

%hook UIActionSheet

- (void)addButtonWithTitle:(NSString *)title {
	%orig(ReplaceReadingListTitle(title));
}

%end

%hook SSReadingList

- (void)_addReadingListItemWithURL:(NSURL *)url title:(NSString *)title previewText:(NSString *)previewText {
	%log;
	//%orig;
	NSString *urlString = [url absoluteString];
	if (urlString != nil) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			
			NSDictionary *userInfo = @{ @"from": @"addBookmark", @"title": (title == nil ? @"" : title), @"url": urlString };
			
			if (objc_getClass("SpringBoard") != nil) {
				[objc_getClass("PWWidgetController") presentWidgetNamed:@"Browser" userInfo:userInfo];
			} else {
				[objc_getClass("OBJCIPC") sendMessageToSpringBoardWithMessageName:@"prowidgets.presentwidget" dictionary:@{ @"name": @"Browser", @"userInfo":userInfo } replyHandler:nil];
			}
		});
	}
}

%end

%end

%group SpringBoard

%hook SpringBoard

- (void)applicationOpenURL:(NSURL *)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating needsPermission:(BOOL)permission additionalActivationFlags:(id)flags activationHandler:(id)handler {
	
	// restore to original URL
	BOOL fromWidget = NO;
	NSString *urlString = url.absoluteString;
	if ([urlString hasSuffix:@"***PWBROWSERWIDGET"]) {
		fromWidget = YES;
		urlString = [urlString substringToIndex:[urlString length] - [@"***PWBROWSERWIDGET" length]];
		url = [NSURL URLWithString:urlString];
	}
	
	if (enabledOpenInApp && !fromWidget) {
		NSString *scheme = [[url scheme] lowercaseString];
		if (([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) && urlString != nil) {
			openBrowserWithURL(urlString, @"app");
			return;
		}
	}
	
	%orig;
}

%end

%hook SBBookmark

- (BOOL)icon:(SBBookmarkIcon *)icon launchFromLocation:(int)location {
	
	if (enabledOpenFromIcon) {
		UIWebClip *webClip = icon.webClip;
		NSURL *url = webClip.pageURL;
		NSString *urlString = [url absoluteString];
		return openBrowserWithURL(urlString, @"icon");
	}
	
	return %orig;
}

%end

%end

#include <string>
#include <vector>

struct BookmarkModel {
    /*void *_field1;
    void *_field2;
    void *_field3;
    void *_field4;
    void *_field5;
    BOOL _field6;
    void * _field7;
    struct BookmarkPermanentNode *_field8;
    struct BookmarkPermanentNode *_field9;
    struct BookmarkPermanentNode *_field10;
    long long _field11;
    struct ObserverList<BookmarkModelObserver, false> _field12;
    struct multiset<BookmarkNode *, BookmarkModel::NodeURLComparator, std::allocator<BookmarkNode *>> _field13;
    struct Lock _field14;
    struct CancelableTaskTracker _field15;
    struct scoped_refptr<BookmarkStorage> _field16;
    struct scoped_ptr<BookmarkIndex, base::DefaultDeleter<BookmarkIndex>> _field17;
    struct WaitableEvent _field18;
    int _field19;
    struct scoped_ptr<BookmarkExpandedStateTracker, base::DefaultDeleter<BookmarkExpandedStateTracker>> _field20;*/
};

struct Component {
    int begin;
    int len;
};

struct Parsed {
    struct Component scheme;
    struct Component username;
    struct Component password;
    struct Component host;
    struct Component port;
    struct Component path;
    struct Component query;
    struct Component ref;
    struct Parsed *inner_parsed_;
};
/*
struct GURL {
	std::basic_string spec_;
    BOOL is_valid_;
    struct Parsed parsed_;
    struct scoped_ptr<GURL, base::DefaultDeleter<GURL>> inner_url_;
};
*/

struct GURL {
	std::basic_string<char> spec_;
    BOOL is_valid_;
    Parsed parsed_;
	void *inner_url_;
};

struct BookmarkNode;

struct ScopedVectorBookmarkNode {
    std::vector<BookmarkNode *, std::allocator<BookmarkNode *> > _field1;
};

struct BookmarkNode {
    void *_field1;
	std::basic_string<char> _field2;
    struct BookmarkNode *_field3;
    struct ScopedVectorBookmarkNode _field4;
    long long _field5;
    struct GURL _field6;
    int _field7;
    void *_field8;
    void *_field9;
    void *_field10;
    int _field11;
    struct GURL _field12;
    int _field13;
    long long _field14;
	void *_field15;
    long long _field16;
};

static GURL createGURL(NSString *url) {
	
	struct GURL *newURL = new GURL;
	
	// set spec
	std::basic_string<char> *newSpec = new std::basic_string<char>([url UTF8String]);
	memcpy(&(newURL->spec_), newSpec, sizeof(std::basic_string<char>));
	
	// set parsed
	struct Parsed parsed;
	memset(&parsed, 0, sizeof(Parsed));
	memcpy(&(newURL->parsed_), &parsed, sizeof(Parsed));
	
	// set other parameters
	newURL->is_valid_ = YES;
	newURL->inner_url_ = NULL;
	
	return *newURL;
}

%group Chrome

%hook MainController

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	BOOL result = %orig;
	LOG(@"didFinishLaunchingWithOptions");
	
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		//[self.class test];
	//});
	
	return result;
}

%new
+ (void)test {
	
	UIApplication *app = [UIApplication sharedApplication];
	MainController *delegate = (MainController *)app.delegate;
	//[delegate createBVCWithoutProfileForMode:0];
	[delegate retain];
	BrowserViewController *bvc = *(BrowserViewController **)instanceVar(delegate, "mainBVC_");
	[bvc retain];
	[delegate addProfileToActiveBVC];
	
	[delegate applicationDidBecomeActive:YES];
	
	LOG(@"delegate: %@", delegate);
	LOG(@"bvc: %@", bvc);
	
	if (bvc != nil) {
		
		LOG(@"before retrieving bookmarkModel");
		
		
		
		 void *bookmarkModel = *(void **)instanceVar(bvc, "bookmarkModel_");
		
		if (YES)return;
		
		if (bookmarkModel == NULL) {
			LOG(@"bookmarkModel IS NULL");
			return;
		} else {
			LOG(@"bookmarkModel IS NOT NULL");
			return;
		}
		
		BookmarkFolderViewController *folderViewController = [[objc_getClass("BookmarkFolderViewController") alloc] initWithBookmarks:bookmarkModel allowNewfolders:NO];
		
		LOG(@"folderViewController: %@", folderViewController);
		
		//[folderViewController reloadData];
		
		void *_folders = instanceVar(folderViewController, "folders_");
		if (_folders != NULL) {
			std::vector<void *> folders = *(std::vector<void *> *)_folders;
			NSUInteger size = folders.size();
			LOG(@"folder size: %d", (int)size);
			/*
			 for (NSUInteger i = 0; i < size; i++) {
			 void *node = folders.at(i);
			 }*/
		} else {
			LOG(@"folders is NULL");
		}
	}
}

%end

%hook BookmarkInteractionControllerImpl

// - (void)bookmarkEditor:(id)arg1 didFinish:(const struct BookmarkNode *)arg2 withTitle:(id)arg3 url:(struct GURL)arg4 folder:(const struct BookmarkNode *)arg5 shouldDelete:(BOOL)arg6;
- (void)bookmarkEditor:(id)viewController didFinish:(struct BookmarkNode)bookmarkNode withTitle:(NSString *)title url:(struct GURL)url folder:(struct BookmarkNode)folder shouldDelete:(BOOL)shouldDelete {
	%log;
	/*
	title = @"Modified Title";
	
	GURL newURL = createGURL(@"http://www.yahoo.com/");
	url = newURL;
	
	std::basic_string<char> spec = (std::basic_string<char>)url.spec_;
	NSString *specString = [NSString stringWithCString:spec.c_str() encoding:NSUTF8StringEncoding];
	LOG(@"spec string: <%@>", specString);
	*/
	
	//struct GURL gurl = folder._field6;
	std::basic_string<char> spec = (std::basic_string<char>)folder._field2;//gurl.spec_;
	NSString *specString = [NSString stringWithCString:spec.c_str() encoding:NSUTF8StringEncoding];
	LOG(@"folder URL string: <%@>", specString);
	
	%orig;
	%orig(nil, bookmarkNode, @"New Bookmark", createGURL(@"http://www.yahoo.com"), folder, NO);
}

%end

%end

// Loading preference
static inline void loadPref() {
	
	NSDictionary *pref = [[NSDictionary alloc] initWithContentsOfFile:PREF_PATH];
	
#define PREF_BOOL(x,y) NSNumber *_##x = pref[@"x"];\
	x = _##x == nil || ![_##x isKindOfClass:[NSNumber class]] ? y : [_##x boolValue];
	
	PREF_BOOL(enabledOpenInApp, YES)
	PREF_BOOL(enabledOpenFromIcon, YES)
	PREF_BOOL(enabledAddToBookmark, YES)
	
#undef PREF_BOOL
	
	[pref release];
}

static inline void reloadPref(CFNotificationCenterRef center,
							  void *observer,
							  CFStringRef name,
							  const void *object,
							  CFDictionaryRef userInfo) {
	loadPref();
}

static __attribute__((constructor)) void init() {
	
	// load preferences
	loadPref();
	
	// distributed notification center
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadPref, CFSTR("cc.tweak.prowidgets.widget.browser.preferencechanged"), NULL, 0);
	
	if (objc_getClass("SpringBoard") != nil) {
		%init(SpringBoard)
	}
	
	if (objc_getClass("BookmarkInteractionControllerImpl") != nil) {
		%init(Chrome)
	}
	
	%init(App)
}