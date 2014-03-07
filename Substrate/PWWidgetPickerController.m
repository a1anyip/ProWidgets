#import "PWWidgetPickerController.h"
#import "PWController.h"

#define BUNDLE_PATH @"/Library/PreferenceBundles/ProWidgets.bundle/"
#define IMAGE(x) ([UIImage imageNamed:x inBundle:bundle])

static NSBundle *bundle = nil;

@implementation PWWidgetPickerController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (bundle == nil) {
		bundle = [[NSBundle bundleWithPath:BUNDLE_PATH] retain];
	}
	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	NSUInteger row = [indexPath row];
	NSArray *values = [[self specifier] values];
	NSString *name = [values count] > row ? values[row] : nil;
	
	if ([name length] > 0) {
	
		// retrieve icon image
		UIImage *iconImage = [[PWController sharedInstance] iconOfWidgetNamed:name];
		
		// set default icon image
		if (iconImage == nil) iconImage = IMAGE(@"icon_widgets");
		
		cell.imageView.image = iconImage;
	}
	
	return cell;
}

@end