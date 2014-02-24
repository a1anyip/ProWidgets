#import "PWPrefPageViewController.h"
#import "PWPrefURLInstallation.h"

@implementation PWPrefPageViewController

- (Class)viewClass { return nil; }
- (NSString *)navigationTitle { return nil; }
- (BOOL)requiresEditBtn { return NO; }
- (PWPrefURLInstallationType)URLInstallationType { return PWPrefURLInstallationTypeNone; }

- (void)loadView {
	UIView *view = (UIView *)[[self viewClass] new];
	if ([view isKindOfClass:[UITableView class]]) {
		UITableView *tableView = (UITableView *)view;
		tableView.delegate = (id<UITableViewDelegate>)self;
		tableView.dataSource = (id<UITableViewDataSource>)self;
		tableView.allowsSelectionDuringEditing = YES;
	}
	self.view = view;
	[view release];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// set title
	self.navigationItem.title = [self navigationTitle];
	
	// set right button
	if ([self requiresEditBtn]) {
		UIBarButtonItem *editBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditMode)] autorelease];
		editBtn.possibleTitles = [NSSet setWithObjects:@"Edit", @"Done", nil];
		self.navigationItem.rightBarButtonItem = editBtn;
	}
}

- (void)toggleEditMode {
	UITableView *tableView = (UITableView *)self.view;
	if (tableView.isEditing) {
		[tableView setEditing:NO animated:YES];
		self.navigationItem.rightBarButtonItem.title = @"Edit";
	} else {
		[tableView setEditing:YES animated:YES];
		self.navigationItem.rightBarButtonItem.title = @"Done";
	}
}

- (void)promptURLInstallation {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter the installation URL" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Install", nil];
	alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alertView textFieldAtIndex:0].text = @"http://";
	[alertView show];
	[alertView release];
}

- (void)proceedURLInstallation:(NSString *)url {
	
	PWPrefURLInstallationType type = [self URLInstallationType];
	NSString *alertTitle = nil;
	switch (type) {
		case PWPrefURLInstallationTypeWidget:
			alertTitle = @"Unable to install widget";
			break;
		case PWPrefURLInstallationTypeTheme:
			alertTitle = @"Unable to install theme";
			break;
		default:
			return;
	}
	
	NSURL *_url = [NSURL URLWithString:[url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	PWPrefURLInstallation *controller = [[[PWPrefURLInstallation alloc] initWithURL:_url type:type fromPreference:YES] autorelease];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)uninstallPackage:(NSDictionary *)info completionHandler:(void(^)(void))completionHandler {
	NSString *bundlePath = [info[@"bundle"] bundlePath];
	if ([[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil]) {
		completionHandler();
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSString *value = [alertView textFieldAtIndex:0].text;
		LOG(@"PWPrefPageViewController: Receive installation URL (%@)", value);
		[self proceedURLInstallation:value];
	}
}

@end