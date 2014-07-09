#import "../header.h"
#import "PWPrefConfiguration.h"
#import "PWPrefController.h"
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

- (void)enableAllLivePreviewSettings {
	
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	NSArray *widgets = [[PWController sharedInstance] installedWidgets];
	for (NSDictionary *info in widgets) {
		NSString *name = info[@"name"];
		if (name != nil) {
			settings[name] = @YES;
		}
	}
	
	[(PWPrefController *)self.parentController updateValue:settings forKey:@"livePreviewSettings"];
}

- (void)disableAllLivePreviewSettings {
	[(PWPrefController *)self.parentController updateValue:@{} forKey:@"livePreviewSettings"];
}

- (void)showWelcomeScreen {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(PWShowWelcomeScreenNotification), NULL, NULL, true);
}

- (void)resetPreference {
	
	PWAlertView *alertView = [[PWAlertView alloc] initWithTitle:PTEXT(@"Confirmation") message:PTEXT(@"ResetCoreSettingsConfirmation") buttonTitle:PTEXT(@"Yes") cancelButtonTitle:PTEXT(@"No") defaultValue:nil style:UIAlertViewStyleDefault completion:^(BOOL cancelled, NSString *firstValue, NSString *secondValue) {
		if (!cancelled) {
			
			// write an empty dictionary to preference file
			[[NSDictionary dictionary] writeToFile:PWPrefPath atomically:YES];
			CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
			CFNotificationCenterPostNotification(center, CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, NULL, true);
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ProWidgets" message:PTEXT(@"ResetCoreSettingsMessage") delegate:nil cancelButtonTitle:PTEXT(@"OK") otherButtonTitles:nil];
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