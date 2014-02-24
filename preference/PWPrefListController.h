#import "header.h"

@interface PWPrefListController : PSListController {
	
	NSString *_plist;
	NSBundle *_bundle;
}

@property(nonatomic, copy) NSString *plist;
@property(nonatomic, retain) NSBundle *bundle;

- (instancetype)initWithPlist:(NSString *)plist inBundle:(NSBundle *)bundle;

- (NSArray *)specifiers;

@end