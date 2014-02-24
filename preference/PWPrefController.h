#import "header.h"

@interface PWPrefController : PSViewController<UITableViewDataSource, UITableViewDelegate> {
	
	NSMutableDictionary *_pref;
}

- (void)readPreference;
- (id)valueForKey:(NSString *)key;
- (void)updateValue:(id)value forKey:(NSString *)key;

@end