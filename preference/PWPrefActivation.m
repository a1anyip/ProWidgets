#import "PWPrefActivation.h"
#import "PWPrefActivationView.h"
#import "PWPrefActivationPreference.h"
#import "PWController.h"
#import "PWPrefController.h"

extern NSBundle *bundle;

@implementation PWPrefActivation

- (Class)viewClass {
	return [PWPrefActivationView class];
}

- (NSString *)navigationTitle {
	return @"Activation Methods";
}

- (BOOL)requiresEditBtn {
	return NO;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// reload activation methods
	[self reloadActivationMethods];
	
	// reload enabled widgets
	[self reloadEnabledWidgets];
	
	// enabled editing (sorting) by default
	[(PWPrefActivationView *)self.view setEditing:YES animated:NO];
}

- (void)reloadActivationMethods {
	// re-fetch available widgets from PWController
	[_activationMethods release];
	_activationMethods = [[[PWController sharedInstance] activationMethods] retain];
	// reload table view
	[(PWPrefActivationView *)self.view reloadData];
}

- (void)reloadEnabledWidgets {
	// re-fetch enabled widgets from PWController
	[_visibleWidgets release];
	[_hiddenWidgets release];
	NSDictionary *enabledWidgets = [[PWController sharedInstance] enabledWidgets];
	_visibleWidgets = [enabledWidgets[@"visible"] mutableCopy];
	_hiddenWidgets = [enabledWidgets[@"hidden"] mutableCopy];
	// reload table view
	[(PWPrefActivationView *)self.view reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? MAX(1, [_activationMethods count]) : MAX(0, [(section == 1 ? _visibleWidgets : _hiddenWidgets) count]);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Activation methods" : (section == 1 ? @"Visible widgets" : @"Hidden widgets");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0 && [_activationMethods count] > 0) {
		return @"You could configure activation methods in this section.";
	} else if (section == 0 && [_activationMethods count] == 0) {
		return @"You may find some activation methods in Cydia, or re-install ProWidgets to restore stock activation methods.";
	} else if (section == 2) {
		return @"You could rearrange or set the visibility of widgets in some activation methods (e.g. Control Center) in this section.\n\nSome widgets are hidden according to their settings.";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	BOOL isMessageCell = (section == 0 && [_activationMethods count] == 0) || (section == 1 && [_visibleWidgets count] == 0) || (section == 2 && [_hiddenWidgets count] == 0);
	
	NSString *identifier = nil;
	
	if (isMessageCell) {
		identifier = @"PWPrefActivationViewMessageCell";
	} else if (section == 0) {
		identifier = @"PWPrefActivationViewMethodCell";
	} else if (section == 1 || section == 2) {
		identifier = @"PWPrefActivationViewWidgetCell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		if (!isMessageCell) style = UITableViewCellStyleSubtitle;
		
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		
		if (isMessageCell) {
			
			cell.textLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
		} else if (section == 0) {
			
			cell.detailTextLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			
		} else if (section == 1 || section == 2) {
			
			cell.detailTextLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	if (!isMessageCell) {
		
		if (section == 0) {
			
			// retrieve the method info
			NSDictionary *info = row < [_activationMethods count] ? _activationMethods[row] : nil;
			
			// extract method info
			NSString *displayName = info[@"displayName"];
			NSString *description = info[@"description"];
			BOOL hasPreference = [info[@"hasPreference"] boolValue];
			
			// set default display name
			if ([displayName length] == 0) displayName = @"Unknown";
			
			// set default description
			if ([description length] == 0) description = nil;//@"No description";
			
			// configure cell
			cell.textLabel.text = displayName;
			cell.detailTextLabel.text = description;
			
			if (hasPreference) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleDefault;
			} else {
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			
		} else if (section == 1 || section == 2) {
			
			// retrieve the widget info
			NSArray *widgets = section == 1 ? _visibleWidgets : _hiddenWidgets;
			NSDictionary *info = row < [widgets count] ? widgets[row] : nil;
			
			// extract widget info
			NSBundle *widgetBundle = info[@"bundle"];
			NSString *displayName = info[@"displayName"];
			NSString *description = info[@"description"];
			NSString *iconFile = info[@"iconFile"];
			UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:widgetBundle] : nil;
			
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
		}
	} else {
		if (section == 0) {
			cell.textLabel.text = @"No installed activation methods";
		} else if (section == 1) {
			cell.textLabel.text = @"No visible widgets";
		} else if (section == 2) {
			cell.textLabel.text = @"No hidden widgets";
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (section == 0) {
		if (row < [_activationMethods count]) {
			
			NSDictionary *info  = _activationMethods[row];
			NSBundle *bundle = info[@"bundle"];
			BOOL hasPreference = [info[@"hasPreference"] boolValue];
			
			if (hasPreference) {
				NSString *prefFile = info[@"preferenceFile"];
				PWPrefActivationPreference *controller = [[[PWPrefActivationPreference alloc] initWithPlist:prefFile inBundle:bundle] autorelease];
				controller.rootController = self.rootController;
				controller.parentController = self;
				[self pushController:controller];
			}
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [indexPath section] > 0 && ([_visibleWidgets count] > 0 || [_hiddenWidgets count] > 0);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [indexPath section] > 0 && ([_visibleWidgets count] > 0 || [_hiddenWidgets count] > 0);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	
	if (proposedDestinationIndexPath.section < 1) {
		return [NSIndexPath indexPathForRow:0 inSection:1];
	}
	
	return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	
	unsigned int fromSection = [sourceIndexPath section];
	unsigned int fromRow = [sourceIndexPath row];
	unsigned int toSection = [destinationIndexPath section];
	unsigned int toRow = [destinationIndexPath row];
	
	NSMutableArray *fromArray = fromSection == 1 ? _visibleWidgets : _hiddenWidgets;
	NSMutableArray *toArray = toSection == 1 ? _visibleWidgets : _hiddenWidgets;
	
	NSDictionary *info = [[fromArray objectAtIndex:fromRow] copy];
	[fromArray removeObjectAtIndex:fromRow];
	
	if (toRow >= [toArray count]) {
		[toArray addObject:info];
	} else {
		[toArray insertObject:info atIndex:toRow];
	}
	
	[info release];
	
	// visible order
	NSMutableArray *visibleOrder = [NSMutableArray array];
	for (NSDictionary *info in _visibleWidgets) {
		[visibleOrder addObject:info[@"name"]];
	}
	
	// hidden order
	NSMutableArray *hiddenOrder = [NSMutableArray array];
	for (NSDictionary *info in _hiddenWidgets) {
		[hiddenOrder addObject:info[@"name"]];
	}
	
	[(PWPrefController *)self.parentController updateValue:visibleOrder forKey:@"visibleWidgetOrder"];
	[(PWPrefController *)self.parentController updateValue:hiddenOrder forKey:@"hiddenWidgetOrder"];
}

- (void)dealloc {
	[_activationMethods release], _activationMethods = nil;
	[_visibleWidgets release], _visibleWidgets = nil;
	[_hiddenWidgets release], _hiddenWidgets = nil;
	[super dealloc];
}

@end