@class PSSpecifier;

@interface PSViewController : UIViewController

@property(nonatomic) CGSize contentSize;
@property(nonatomic, retain) id rootController;
@property(nonatomic, retain) id parentController;

- (instancetype)initForContentSize:(CGSize)contentSize;
- (void)pushController:(id)controller;

@end

@interface PSListController : PSViewController {
	id _specifiers;
}

- (void)setTitle:(id)arg1;
- (id)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
- (PSSpecifier *)specifierAtIndex:(int)index;
- (void)setSpecifiers:(id)arg1;
- (void)reload;

@end

@interface PSListItemsController : PSListController

- (PSSpecifier *)specifier;
- (id)itemsFromParent;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PSSpecifier : NSObject

@property(retain) id properties;
@property(retain) NSArray *values;
@property(retain) NSDictionary *titleDictionary;
@property(retain) NSDictionary *shortTitleDictionary;

@property(retain, nonatomic) NSString *name;
@property(nonatomic) SEL buttonAction;

+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(int)arg6 edit:(Class)arg7;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
- (id)propertyForKey:(NSString *)key;
- (NSDictionary *)properties;

- (void)setValues:(id)arg1 titles:(id)arg2 shortTitles:(id)arg3 usingLocalizedTitleSorting:(BOOL)arg4;

@end

@interface PSTableCell : UITableViewCell

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *value;

- (void)setSpecifier:(PSSpecifier *)specifier;

@end

@interface UIImage ()

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

@end

@interface UITextView ()

- (void)setLineHeight:(CGFloat)height;

@end