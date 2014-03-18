#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface PSListController : UIViewController {
	id _specifiers;
}

- (id)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;

@end

@interface _UIRemoteDictionaryViewController : UIViewController

@end

@interface PWWidgetDictionaryPref: PSListController

- (void)manageDictionaryAssets;

@end

@implementation PWWidgetDictionaryPref

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PWWidgetDictionary" target:self] retain];
	}
	return _specifiers;
}

- (void)manageDictionaryAssets {
	_UIRemoteDictionaryViewController *viewController = [[objc_getClass("_UIRemoteDictionaryViewController") new] autorelease];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end