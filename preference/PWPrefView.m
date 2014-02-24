#import "PWPrefView.h"
#import "PWPrefController.h"

extern NSBundle *bundle;

@implementation PWPrefView

- (instancetype)init {
	if ((self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped])) {
		
		// add logo in header
		UIImage *logo = IMAGE(@"logo");
		_headerView = [[UIImageView alloc] initWithImage:logo];
		self.tableHeaderView = _headerView;
		
		// add copyright text in footer
		_copyright = [UILabel new];
		_copyright.font = [UIFont systemFontOfSize:14.0];
		_copyright.text = @"© 2014 Alan Yip";
		_copyright.textColor = [UIColor colorWithRed:139/255.0 green:141/255.0 blue:144/255.0 alpha:1.0];
		self.tableFooterView = _copyright;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat padding = 15.0;
	
	_headerView.frame = CGRectMake(0, 0, 320.0, 90.0);
	_copyright.frame = CGRectMake(padding, _copyright.frame.origin.y, size.width - padding * 2, 20.0);
}

- (void)dealloc {
	
	self.delegate = nil;
	self.dataSource = nil;
	
	self.tableHeaderView = nil;
	self.tableFooterView = nil;
	
	RELEASE_VIEW(_headerView)
	RELEASE_VIEW(_copyright)
	
	[super dealloc];
}

@end