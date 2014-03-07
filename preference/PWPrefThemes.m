#import "PWPrefThemes.h"
#import "PWPrefThemesView.h"
#import "PWController.h"
#import "PWPrefController.h"
#import "PWPrefInfoViewController.h"

extern NSBundle *bundle;

@implementation PWPrefThemes

- (Class)viewClass {
	return [PWPrefThemesView class];
}

- (NSString *)navigationTitle {
	return @"Themes";
}

- (BOOL)requiresEditBtn {
	return YES;
}

- (PWPrefURLInstallationType)URLInstallationType {
	return PWPrefURLInstallationTypeTheme;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	// reload installed themes
	[self reloadInstalledThemes];
	
	// retrieve default theme
	self.defaultThemeName = [[PWController sharedInstance] defaultThemeName];
}

- (void)reloadInstalledThemes {
	// re-fetch installed themes from PWController
	[_installedThemes release];
	_installedThemes = [[[PWController sharedInstance] installedThemes] mutableCopy];
	// update enabled state of edit button
	self.navigationItem.rightBarButtonItem.enabled = [_installedThemes count] > 0;
	// reload table view
	[(PWPrefThemesView *)self.view reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? MAX(1, [_installedThemes count]) : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 0 ? @"Installed themes" : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0 && [_installedThemes count] > 0) {
		return @"You could choose the default theme in this page.\n\nTap on icons to view details.";
	} else if (section == 0 && [_installedThemes count] == 0) {
		return @"You may find some themes in Cydia, or re-install ProWidgets to restore stock themes.";
	} else if (section == 1) {
		return @"Only themes installed via URL can be uninstalled in this page.\n\nInstall or Uninstall other themes in Cydia.";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	BOOL isMessageCell = section == 0 && [_installedThemes count] == 0;
	
	NSString *identifier = nil;
	
	if (isMessageCell) {
		identifier = @"PWPrefThemesViewMessageCell";
	} else if (section == 0) {
		identifier = @"PWPrefThemesViewCell";
	} else if (section == 1) {
		identifier = @"PWPrefThemesViewInstallCell";
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		
		UITableViewCellStyle style = UITableViewCellStyleDefault;
		if (!isMessageCell && section == 0) style = UITableViewCellStyleSubtitle;
		
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:identifier] autorelease];
		
		// set tint color
		cell.tintColor = [UIColor colorWithWhite:.5 alpha:1.0];
		
		if (isMessageCell) {
			
			cell.textLabel.text = @"No installed themes";
			cell.textLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.textLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
		} else if (section == 0) {
			
			cell.detailTextLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
			cell.imageView.userInteractionEnabled = YES;
			
			UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_cellImageViewTapHandler:)] autorelease];
			tap.numberOfTapsRequired = 1;
			[cell.imageView addGestureRecognizer:tap];
			
		} else if (section == 1) {
			
			cell.textLabel.text = @"Install theme via URL";
			cell.textLabel.textAlignment = NSTextAlignmentCenter;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	if (section == 0 && !isMessageCell) {
		
		// retrieve the widget info
		NSDictionary *info = row < [_installedThemes count] ? _installedThemes[row] : nil;
		
		// extract widget info
		NSBundle *themeBundle = info[@"bundle"];
		NSString *themeName = info[@"name"];
		NSString *displayName = info[@"displayName"];
		NSString *shortDescription = info[@"shortDescription"];
		NSString *iconFile = info[@"iconFile"];
		UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:themeBundle] : nil;
		
		// set default display name
		if ([displayName length] == 0) displayName = @"Unknown";
		
		// set default description
		if ([shortDescription length] == 0) shortDescription = nil;
		
		// set default icon image
		if (iconImage == nil) iconImage = IMAGE(@"icon_themes");
		
		// configure cell
		cell.textLabel.text = displayName;
		cell.detailTextLabel.text = shortDescription;
		cell.imageView.image = iconImage;
		
		if ([themeName isEqualToString:self.defaultThemeName]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (section == 0) {
		if (row < [_installedThemes count]) {
			
			// update checkmark
			for (NSIndexPath *path in [tableView indexPathsForVisibleRows]) {
				if (path.section != 0) continue;
				UITableViewCell *cell = [tableView cellForRowAtIndexPath:path];
				cell.accessoryType = indexPath.row == path.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			}
			
			// update preference
			NSDictionary *info = row < [_installedThemes count] ? _installedThemes[row] : nil;
			NSString *themeName = info[@"name"];
			self.defaultThemeName = themeName;
			[(PWPrefController *)self.parentController updateValue:themeName forKey:@"defaultThemeName"];
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
	
	if (section != 0 || row >= [_installedThemes count]) return NO;
	
	NSDictionary *info = _installedThemes[row];
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
	
	if (section != 0 || row >= [_installedThemes count]) return;
	[self _uninstallThemeAtIndex:row];
}

- (void)_cellImageViewTapHandler:(UITapGestureRecognizer *)sender {
	
	UIView *superview = sender.view;
	while ((superview = superview.superview) && superview != nil && ![superview isKindOfClass:[UITableViewCell class]]);
	
	UITableViewCell *cell = (UITableViewCell *)superview;
	if ([cell isKindOfClass:[UITableViewCell class]]) {
		UITableView *tableView = (UITableView *)self.view;
		NSIndexPath *indexPath = [tableView indexPathForCell:cell];
		NSUInteger row = [indexPath row];
		if (row != NSNotFound && [_installedThemes count] > row) {
			
			PWPrefInfoViewController *infoViewController = [[PWPrefInfoViewController new] autorelease];
			
			NSDictionary *info = _installedThemes[row];
			NSBundle *themeBundle = info[@"bundle"];
			
			// prepare icon
			NSString *iconFile = info[@"iconFile"];
			UIImage *iconImage = [iconFile length] > 0 ? [UIImage imageNamed:iconFile inBundle:themeBundle] : nil;
			if (iconImage == nil) iconImage = IMAGE(@"icon_themes");
			
			// configure info view
			PWPrefInfoView *infoView = infoViewController.infoView;
			[infoView setIcon:iconImage];
			[infoView setName:info[@"displayName"]];
			[infoView setAuthor:info[@"author"]];
			[infoView setDescription:info[@"description"]];
			[infoView setConfirmButtonTitle:@"Uninstall"];
			
			if ([info[@"installedViaURL"] boolValue]) {
				[infoView setConfirmButtonType:PWPrefInfoViewConfirmButtonTypeWarning];
				[infoView setConfirmButtonTarget:self action:@selector(_infoViewConfirmButtonHandler:)];
				[infoView setConfirmButtonInfo:@{ @"index":@(row) }];
			} else {
				[infoView setConfirmButtonType:PWPrefInfoViewConfirmButtonTypeDisabled];
			}
			
			[self presentViewController:infoViewController animated:YES completion:nil];
		}
	}
}

- (void)_infoViewConfirmButtonHandler:(NSDictionary *)info {
	
	[self dismissViewControllerAnimated:YES completion:nil];
	
	NSNumber *_index = info[@"index"];
	if (_index != nil) {
		NSUInteger index = [_index unsignedIntegerValue];
		[self _uninstallThemeAtIndex:index];
	}
}

- (void)_uninstallThemeAtIndex:(NSUInteger)index {
	
	NSDictionary *info = _installedThemes[index];
	BOOL installedViaURL = [info[@"installedViaURL"] boolValue];
	
	if (installedViaURL) {
		[self uninstallPackage:info completionHandler:^{
			
			// reset default theme value
			NSString *name = info[@"name"];
			if ([_defaultThemeName isEqualToString:name]) {
				
				NSString *replacedDefaultThemeName = nil;
				
				// seek another suitable default theme
				for (NSDictionary *themeInfo in _installedThemes) {
					NSString *themeName = themeInfo[@"name"];
					if ([themeName isEqualToString:name]) continue;
					replacedDefaultThemeName = themeName;
					break;
				}
				
				if (replacedDefaultThemeName != nil) {
					self.defaultThemeName = replacedDefaultThemeName;
				} else {
					self.defaultThemeName = nil;
					replacedDefaultThemeName = @"";
				}
				
				[(PWPrefController *)self.parentController updateValue:replacedDefaultThemeName forKey:@"defaultThemeName"];
			}
			
			[_installedThemes removeObjectAtIndex:index];
			[(UITableView *)self.view reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
		}];
	}
}

- (void)dealloc {
	[_defaultThemeName release], _defaultThemeName = nil;
	[_installedThemes release], _installedThemes = nil;
	[super dealloc];
}

@end