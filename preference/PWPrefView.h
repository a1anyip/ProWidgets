#import "header.h"

@interface PWPrefView : UITableView<UIWebViewDelegate> {
	
	UIImageView *_headerView;
	UILabel *_copyright;
	UIWebView *_webView;
}

@end