#import "PWPrefInfoViewController.h"
#import "PWPrefInfoView.h"

extern NSBundle *bundle;

@implementation PWPrefInfoViewController

- (instancetype)init {
	if ((self = [super init])) {
		_innerViewController = [PWPrefInfoViewInnerController new];
		[self pushViewController:_innerViewController animated:NO];
	}
	return self;
}

- (PWPrefInfoView *)infoView {
	return (PWPrefInfoView *)_innerViewController.view;
}

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
	self.viewControllers = nil;
	RELEASE(_innerViewController)
	[super dealloc];
}

@end

@implementation PWPrefInfoViewInnerController

- (void)loadView {
	self.view = [[PWPrefInfoView new] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	
	self.navigationItem.title = @"Info";
	
	UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(dismiss)] autorelease];
	
	self.navigationItem.leftBarButtonItem = closeButton;
}

@end