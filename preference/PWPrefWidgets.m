#import "PWPrefWidgets.h"
#import "PWPrefWidgetsView.h"
#import "PWPrefWidgetPreference.h"
#import "PWController.h"

extern NSBundle *bundle;

@implementation PWPrefWidgets

- (Class)viewClass {
	return [PWPrefWidgetsView class];
}

- (NSString *)navigationTitle {
	return @"Widgets";
}

- (BOOL)requiresEditBtn {
	return YES;
}

- (PWPrefURLInstallationType)URLInstallationType {
	return PWPrefURLInstallationTypeWidget;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// reload installed widgets
	[self reloadInstalledWidgets];
}

- (void)reloadInstalledWidgets {
	// re-fetch installed widgets from PWController
	[_installedWidgets release];
	_installedWidgets = [[[PWController sharedInstance] installedWidgets] mutableCopy];
	// update enabled state of edit button
	self.navigationItem.rightBarButtonItem.enabled = [_installedWidgets count] > 0;
	// reload table view
	[(PWPrefWidgetsView *)self.view reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? MAX(1, [_installedWidgets count]) : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Installed widgets" : nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0 && [_installedWidgets count] > 0) {
		return @"You could configure widgets in this page, and rearrange them in Activation Methods.";
	} else if (section == 0 && [_installedWidgets count] == 0) {
		return @"You may find some useful widgets in Cydia, or re-install ProWidgets to restore stock widgets.";
	} else if (section == 1) {
		return @"Only widgets installed via URL can be uninstalled in this page.\n\nInstall or Uninstall other widgets in Cydia.";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	BOOL isMessageCell = section == 0 && [_installedWidgets count] == 0;
	
	NSString *identifier = nil;
	
	if (isMessageCell) {
		identifier = @"PWPrefWidgetsViewMessageCell";
	} else if (section == 0) {
		identifier = @"PWPrefWidgetsViewCell";
	} else if (section == 1) {
		identifier = @"PWPrefWidgetsViewInstallCell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		if (!isMessageCell && section == 0) style = UITableViewCellStyleSubtitle;
		
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		
		if (isMessageCell) {
			
			cell.textLabel.text = @"No installed widgets";
			cell.textLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
		} else if (section == 0) {
			
			cell.detailTextLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			
		} else if (section == 1) {
			
			cell.textLabel.text = @"Install widget via URL";
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	if (section == 0 && !isMessageCell) {
		
		// retrieve the widget info
		NSDictionary *info = row < [_installedWidgets count] ? _installedWidgets[row] : nil;
		
		// extract widget info
		NSBundle *widgetBundle = info[@"bundle"];
		NSString *displayName = info[@"displayName"];
		NSString *description = info[@"description"];
		NSString *iconFile = info[@"iconFile"];
		UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:widgetBundle] : nil;
		BOOL hasPreference = [info[@"hasPreference"] boolValue];
		
		// set default display name
		if ([displayName length] == 0) displayName = @"Unknown";
		
		// set default description
		if ([description length] == 0) description = nil;//@"No description";
		
		// set default icon image
		if (iconImage == nil) iconImage = IMAGE(@"icon_widgets");
		
		// configure cell
		cell.textLabel.text = displayName;
		cell.detailTextLabel.text = description;
		cell.imageView.image = iconImage;
		
		if (hasPreference) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (section == 0) {
		if (row < [_installedWidgets count]) {
			
			NSDictionary *info  = _installedWidgets[row];
			NSBundle *bundle = info[@"bundle"];
			BOOL hasPreference = [info[@"hasPreference"] boolValue];
			
			if (hasPreference) {
				NSString *prefFile = info[@"preferenceFile"];
				PWPrefWidgetPreference *controller = [[[PWPrefWidgetPreference alloc] initWithPlist:prefFile inBundle:bundle] autorelease];
				controller.rootController = self.rootController;
				controller.parentController = self;
				[self pushController:controller];
			}
		}
	} else if (section == 1) {
		if (row == 0) {
			[self promptURLInstallation];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	if (section != 0 || row >= [_installedWidgets count]) return NO;
	
	NSDictionary *info = _installedWidgets[row];
	BOOL installedViaURL = [info[@"installedViaURL"] boolValue];
	
	return installedViaURL;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Uninstall";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	if (section != 0 || row >= [_installedWidgets count]) return;
	
	NSDictionary *info = _installedWidgets[row];
	BOOL installedViaURL = [info[@"installedViaURL"] boolValue];
	
	if (installedViaURL) {
		[self uninstallPackage:info completionHandler:^{
			[_installedWidgets removeObjectAtIndex:indexPath.row];
			//[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		}];
	}
}

- (void)dealloc {
	[_installedWidgets release], _installedWidgets = nil;
	[super dealloc];
}

@end