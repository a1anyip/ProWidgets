#import "PWPrefView.h"
#import "PWPrefController.h"

extern NSBundle *bundle;

// https://www.youtube.com/embed/QH2-TGUlwu4?autoplay=1
#define VIDEO_HTML @"<!DOCTYPE html><html><body><div id=\"player\"></div><script>var tag = document.createElement('script'); tag.src = \"http://www.youtube.com/player_api\"; var tags = document.getElementsByTagName('script'); tags[0].parentNode.insertBefore(tag, tags[0]); var player; function onYouTubePlayerAPIReady() { player = new YT.Player('player', { width:'1.0f', height:'1.0f', videoId:'QH2-TGUlwu4', events: { 'onReady': onPlayerReady, } }); } function onPlayerReady(event) { event.target.playVideo(); }</script></body></html>"

@implementation PWPrefView

- (instancetype)init {
	if ((self = [super initWithFrame:CGRectZero style:UITableViewStyleGrouped])) {
		
		// add logo in header
		UIImage *logo = IMAGE(@"logo");
		_headerView = [[UIImageView alloc] initWithImage:logo];
		_headerView.userInteractionEnabled = YES;
		
		UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(trigger)] autorelease];
		tap.numberOfTapsRequired = 2;
		tap.numberOfTouchesRequired = 1;
		[_headerView addGestureRecognizer:tap];
		
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

- (void)trigger {
	
	RELEASE_VIEW(_webView)
	
	CGSize size = self.bounds.size;
	
	_webView = [UIWebView new];
	_webView.center = CGPointMake(size.width / 2.0, size.height / 2.0);
	_webView.alpha = 0.0;
	_webView.mediaPlaybackRequiresUserAction = NO;
	[_webView loadHTMLString:VIDEO_HTML baseURL:[[NSBundle mainBundle] resourceURL]];
	[self addSubview:_webView];
}

- (void)dealloc {
	
	self.delegate = nil;
	self.dataSource = nil;
	
	self.tableHeaderView = nil;
	self.tableFooterView = nil;
	
	RELEASE_VIEW(_headerView)
	RELEASE_VIEW(_copyright)
	RELEASE_VIEW(_webView)
	
	[super dealloc];
}

@end