
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
- (id)specifierAtIndex:(int)index;
- (void)setSpecifiers:(id)arg1;
- (void)reload;

@end

@interface PSSpecifier : NSObject

@property(retain, nonatomic) NSString *name;
@property(nonatomic) SEL buttonAction;

+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(Class)arg5 cell:(int)arg6 edit:(Class)arg7;
- (void)setProperty:(id)arg1 forKey:(id)arg2;
- (id)propertyForKey:(NSString *)key;
- (NSDictionary *)properties;

@end

@interface UIImage ()

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

@end

@interface UITextView ()

- (void)setLineHeight:(CGFloat)height;

@end