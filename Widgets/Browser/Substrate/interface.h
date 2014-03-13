@interface BrowserViewController : NSObject

@end

@interface MainController : NSObject

+ (void)test;
- (void)applicationDidBecomeActive:(BOOL)animated;
- (BrowserViewController *)mainBVC;
- (void)addProfileToActiveBVC;
- (void)createBVCWithoutProfileForMode:(int)mode;

@end

@interface BookmarkFolderViewController : NSObject

- (instancetype)initWithBookmarks:(void *)bookmarkModel allowNewfolders:(BOOL)allowNewfolders;
- (void)reloadData;

@end