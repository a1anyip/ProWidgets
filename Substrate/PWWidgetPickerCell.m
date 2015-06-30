#import "PWWidgetPickerCell.h"

@implementation PWWidgetPickerCell

- (void)setSpecifier:(PSSpecifier *)specifier {
	[super setSpecifier:specifier];
	LOG(@"PWWidgetPickerCell =====> setSpecifier:%@", specifier);
	
	//NSString *value = [specifier propertyForKey:@"PWTest"];
	//[self setValue:value];
}

@end