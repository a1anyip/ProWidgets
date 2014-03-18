@interface SBApplication : NSObject

- (NSString *)path;
- (NSString *)sandboxPath;

@end

@interface SBApplicationController : NSObject

+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)identifier;

@end

@interface WebDataSource : NSObject

- (NSURLRequest *)request;

@end

@interface WebView : NSObject

@end

@interface WebFrame : NSObject

- (BOOL)isMainFrame;
- (WebDataSource *)dataSource;
- (WebDataSource *)provisionalDataSource;

@end

@interface UIWebDocumentView : NSObject

// private methods to force allow showing action sheet for all types of links
- (void)setAllowsImageSheet:(BOOL)sheet;
- (void)setAllowsDataDetectorsSheet:(BOOL)sheet;
- (void)setAllowsLinkSheet:(BOOL)sheet;

@end

@interface UIWebView (Private)

- (UIWebDocumentView *)_documentView;

- (void)webView:(WebView *)webView didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)view didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;

@end

@class WebBookmarkCollection, WebBookmarkList, WebBookmark;

@interface WebBookmarkCollection : NSObject

+ (instancetype)safariBookmarkCollection;

- (WebBookmarkList *)listWithID:(NSUInteger)identifier;
- (WebBookmarkList *)rootList;
- (WebBookmark *)rootBookmark;
- (WebBookmark *)readingListFolder;
- (WebBookmark *)bookmarksBarBookmark;
- (NSArray *)subfoldersOfID:(NSUInteger)identifier;

- (WebBookmark *)bookmarkWithID:(NSUInteger)bookmarkID;

- (void)saveBookmark:(id)bookmark;
- (void)deleteBookmark:(id)bookmark postChangeNotification:(BOOL)postChangeNotification;

@end

@interface WebBookmarkList : NSObject

- (NSArray *)bookmarkArray;

@end

@interface WebBookmark : NSObject

- (id)initWithTitle:(id)arg1 address:(id)arg2;

- (BOOL)isFolder;
- (BOOL)isWebFilterWhiteListFolder;
- (BOOL)isReadingListFolder;
- (BOOL)isBookmarksMenuFolder;
- (BOOL)isBookmarksBarFolder;
- (NSString *)localizedTitle;

- (NSUInteger)identifier;
- (NSString *)title;
- (NSString *)address;

- (void)_setParentID:(NSUInteger)parentID;

@end