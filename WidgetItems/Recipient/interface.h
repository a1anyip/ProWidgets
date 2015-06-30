@class MFContactsSearchManager, MFContactsSearchResultsModel;

@interface MFContactsSearchManager : NSObject

- (id)initWithAddressBook:(void *)arg1 properties:(NSInteger *)arg2 propertyCount:(NSUInteger)arg3 recentsBundleIdentifier:(id)arg4;

- (NSNumber *)searchForText:(id)arg1 consumer:(id)arg2;
- (void)setSearchTypes:(NSUInteger)arg1;
- (void)cancelTaskWithID:(NSNumber *)arg1;

@end

@interface MFContactsSearchResultsModel : NSObject

- (id)initWithFavorMobileNumbers:(BOOL)arg1;
- (id)initWithResultTypeSortOrderComparator:(id)arg1 resultTypePriorityComparator:(id)arg2 favorMobileNumbers:(BOOL)arg3;

- (void)addResults:(id)arg1 ofType:(NSInteger)arg2;
- (void)processAddedResultsOfType:(NSInteger)arg1 completion:(id)arg2;
- (void)setEnteredRecipients:(id)arg1;
- (void)reset;

@end