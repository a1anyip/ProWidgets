#import "PWPrefController.h"
#import "PWPrefView.h"
#import "PWPrefWidgets.h"
#import "PWPrefThemes.h"
#import "PWPrefActivation.h"
#import "PWPrefConfiguration.h"

#define TWEET_CONTENT @"I love #ProWidgets, a revolutionary widget suite and framework for iOS! http://prowidgets.net via @tweakcc"

NSBundle *bundle;

@implementation PWPrefController

+ (void)initialize {
	bundle = [[NSBundle bundleForClass:[self class]] retain];
}

- (id)table { return self.view; }
- (id)specifier { return nil; }

- (void)loadView {
	PWPrefView *view = [PWPrefView new];
	view.delegate = self;
	view.dataSource = self;
	self.view = view;
	[view release];
}

- (void)viewWillAppear:(BOOL)animated {
	
	CGFloat shareBtnSize = 25.0;
	
	UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, shareBtnSize, shareBtnSize)];
	[shareBtn setBackgroundImage:IMAGE(@"icon_twitter") forState:UIControlStateNormal];
	[shareBtn setShowsTouchWhenHighlighted:NO];
	[shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *shareBtnItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
	[shareBtn release];
	
	// set right button (Twitter)
	self.navigationItem.rightBarButtonItem = shareBtnItem;
	[shareBtnItem release];
	
	// set back button
	self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:PTEXT(@"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	
	// reload preference
	[self readPreference];
}

- (void)share {
	SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[composeController setInitialText:TWEET_CONTENT];
	[self presentViewController:composeController animated:YES completion:nil];
}

- (void)readPreference {
	[_pref release];
	_pref = [[NSMutableDictionary alloc] initWithContentsOfFile:PWPrefPath];
	if (_pref == nil) _pref = [[NSMutableDictionary alloc] init];
}

- (id)valueForKey:(NSString *)key {
	return _pref[key];
}

- (void)updateValue:(id)value forKey:(NSString *)key {
	// update value in cache
	_pref[key] = value;
	// write to dictionary
	[_pref writeToFile:PWPrefPath atomically:YES];
	// broadcast notification (notify PWController to update)
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("cc.tweak.prowidgets.preferencechanged"), NULL, NULL, true);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section == 0 ? 4 : 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	static NSString *identifier = @"PWPrefViewCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	NSString *labelText = nil;
	UIImage *icon = nil;
	
	if (section == 0) {
		switch (row) {
			case 0:
				labelText = PTEXT(@"Widgets");
				icon = IMAGE(@"icon_widgets");
				break;
			case 1:
				labelText = PTEXT(@"Themes");
				icon = IMAGE(@"icon_themes");
				break;
			case 2:
				labelText = PTEXT(@"ActivationMethods");
				icon = IMAGE(@"icon_activation");
				break;
			case 3:
				labelText = PTEXT(@"Configuration");
				icon = IMAGE(@"icon_configuration");
				break;
		}
	} else {
		switch (row) {
			case 0:
				labelText = PTEXT(@"WebsiteAndDocumentation");
				icon = IMAGE(@"icon_website");
				break;
			case 1:
				labelText = PTEXT(@"MoreByAuthor");
				icon = IMAGE(@"icon_author");
				break;
			case 2:
				labelText = PTEXT(@"FollowTwitter");
				icon = IMAGE(@"icon_twitter");
				break;
		}
	}
	
	cell.textLabel.text = labelText;
	cell.imageView.image = icon;
	
	if (section == 0)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int section = [indexPath section];
	unsigned int row = [indexPath row];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (section == 0) {
		
		Class controllerClass = nil;
		
		if (row == 0) {
			// Widgets
			controllerClass = [PWPrefWidgets class];
		} else if (row == 1) {
			// Themes
			controllerClass = [PWPrefThemes class];
		} else if (row == 2) {
			// Activation Methods
			controllerClass = [PWPrefActivation class];
		} else if (row == 3) {
			// Configuration
			controllerClass = [PWPrefConfiguration class];
		}
		
		if (controllerClass != nil) {
			PSViewController *controller = [[controllerClass new] autorelease];
			controller.rootController = self.navigationController;
			controller.parentController = self;
			[self.parentController pushController:controller];
		}
		
	} else if (section == 1) {
		if (row == 0) {
			// Website
			OPEN_URL(@"http://prowidgets.net");
		} else if (row == 1) {
			// More by Alan Yip
			OPEN_URL(@"http://alanyip.me");
		} else if (row == 2) {
			// Follow @tweakcc
#define CAN_OPEN(x) ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:x]])
			
			if (CAN_OPEN(@"tweetbot://"))
				OPEN_URL(@"tweetbot://tweakcc/follow/tweakcc");
			else if (CAN_OPEN(@"twitterrific://"))
				OPEN_URL(@"twitterrific:///profile?screen_name=tweakcc");
			else
				OPEN_URL(@"http://twitter.com/tweakcc");
			
#undef CAN_OPEN
		}
	}
}

- (void)dealloc {
	[_pref release], _pref = nil;
	[super dealloc];
}

@end