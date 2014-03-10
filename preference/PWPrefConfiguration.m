#import "../header.h"
#import "PWPrefConfiguration.h"
#import "PWController.h"
#import "PWAlertView.h"

extern NSBundle *bundle;
static BOOL isIPhone4 = NO;

@implementation PWPrefConfiguration

+ (void)load {
	isIPhone4 = IS_IPHONE4;
}

- (instancetype)init {
	return [super initWithPlist:@"PWPrefConfiguration" inBundle:bundle];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
	if (isIPhone4) {
		NSString *key = [specifier propertyForKey:@"key"];
		if ([key isEqualToString:@"disabledBlur"]) {
			return @YES;
		}
	}
	return [super readPreferenceValue:specifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (isIPhone4 && [cell isKindOfClass:[PSTableCell class]]) {
		PSSpecifier *specifier = cell.specifier;
		NSString *key = [specifier propertyForKey:@"key"];
		if ([key isEqualToString:@"disabledBlur"] && [cell isKindOfClass:[PSSwitchTableCell class]]) {
			[(PSSwitchTableCell *)cell setCellEnabled:NO];
		}
	}
	return cell;
}

- (void)showWelcomeScreen {
	
}

- (void)resetPreference {
	
	PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure to reset all core settings of ProWidgets?" buttonTitle:@"Yes" cancelButtonTitle:@"No" defaultValue:nil style:UIAlertViewStyleDefault completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
		if (!cancelled) {
			
			// write an empty dictionary to preference file
			[[NSDictionary dictionary] writeToFile:PWPrefPath atomically:YES];
			CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
			CFNotificationCenterPostNotification(center, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, NULL, true);
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ProWidgets" message:@"Core preference file is reset." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
			[self.navigationController popViewControllerAnimated:YES];
		}
	}];
	[alertView show];
	[alertView release];
}

- (void)respring {
	system("killall -9 backboardd");
}

@end