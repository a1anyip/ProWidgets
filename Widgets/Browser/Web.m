//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Web.h"
#import "Browser.h"
#import "PrivateWebView.h"
#import "PWThemableTextField.h"
#import "PWThemableTableView.h"
#import "PWThemableTableViewCell.h"
#import "PWView.h"
#import "PWWebRequest.h"

#define WEBVIEW_INACTIVE_ALPHA 0.0
#define RICKROLL_URL @"http://www.youtube.com/watch?v=dQw4w9WgXcQ"

@implementation PWURL
@end

@implementation PWWidgetBrowserWebView

- (instancetype)init {
	if ((self = [super init])) {
		
		PWTheme *theme = [PWWidgetBrowser theme];
		
		_textField = [[PWThemableTextField alloc] initWithFrame:CGRectZero theme:theme];
		_textField.keyboardType = UIKeyboardTypeWebSearch; //UIKeyboardTypeURL;
		_textField.returnKeyType = UIReturnKeyGo;
		_textField.autocorrectionType = UITextAutocorrectionTypeNo;
		_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_textField.spellCheckingType = UITextSpellCheckingTypeNo;
		_textField.backgroundColor = [UIColor clearColor];
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_textField.font = [UIFont systemFontOfSize:14.0];
		_textField.alpha = .4;
		_textField.placeholder = @"Enter URL or Search Google...";
		[self addSubview:_textField];
		
		_actionButton = [UIButton new];
		_actionButton.alpha = .5;
		_actionButton.tintColor = [theme tintColor];
		[self setButtonState:NO];
		[self setButtonHidden:YES];
		[self addSubview:_actionButton];
		
		_separator = [UIView new];
		_separator.backgroundColor = [theme cellSeparatorColor];
		[self addSubview:_separator];
		
		_webView = [PWWidgetBrowserPrivateWebView new];
		_webView.scalesPageToFit = YES;
		_webView.allowsInlineMediaPlayback = YES;
		_webView.alpha = WEBVIEW_INACTIVE_ALPHA;
		[self addSubview:_webView];
		
		_suggestionView = [[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:theme];
		_suggestionView.hidden = YES;
		[self addSubview:_suggestionView];
		
		/*
		_messageLabel = [UILabel new];
		//_messageLabel.text = @"Type  or\nTap on title to view bookmarks";
		_messageLabel.font = [UIFont boldSystemFontOfSize:16.0];
		_messageLabel.textColor = [theme sheetForegroundColor];
		_messageLabel.numberOfLines = 0;
		_messageLabel.alpha = .5;
		_messageLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_messageLabel];*/
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	
	CGFloat textFieldHorizontalPadding = 10.0;
	CGFloat textFieldHeight = 35.0;
	CGFloat buttonSize = 25.0;
	//CGFloat messageLabelHeight = 60.0;
	
	CGRect textFieldRect;
	if (_buttonHidden) {
		textFieldRect = CGRectMake(textFieldHorizontalPadding, 0, width - textFieldHorizontalPadding * 2, textFieldHeight);
	} else {
		textFieldRect = CGRectMake(textFieldHorizontalPadding, 0, width - textFieldHorizontalPadding * 2 - buttonSize, textFieldHeight);
	}
	CGRect buttonRect = CGRectMake(width - textFieldHorizontalPadding - buttonSize, 0, buttonSize + textFieldHorizontalPadding, textFieldHeight);
	CGRect separatorRect = CGRectMake(0, textFieldHeight - .5, width, .5);
	CGRect webViewRect = CGRectMake(0, textFieldHeight, width, height - textFieldHeight);
	CGRect suggestionViewRect = webViewRect;
	//CGRect messageLabelRect = CGRectMake(0, textFieldHeight, width, messageLabelHeight);
	
	_textField.frame = textFieldRect;
	_actionButton.frame = buttonRect;
	_separator.frame = separatorRect;
	_webView.frame = webViewRect;
	_suggestionView.frame = suggestionViewRect;
	//_messageLabel.frame = messageLabelRect;
}

- (void)setDelegate:(id<UITextFieldDelegate, UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>)delegate {
	_textField.delegate = delegate;
	[_textField removeTarget:nil action:NULL forControlEvents:UIControlEventEditingChanged];
	[_textField addTarget:delegate action:@selector(textFieldValueDidChange:) forControlEvents:UIControlEventEditingChanged];
	[_actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
	[_actionButton addTarget:delegate action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	_webView.delegate = delegate;
	_suggestionView.delegate = delegate;
	_suggestionView.dataSource = delegate;
}

- (void)setTextFieldActive:(BOOL)active {
	[UIView animateWithDuration:.1 animations:^{
		_textField.alpha = active ? 1.0 : 0.4;
	}];
	[self setButtonHidden:active];
}

- (void)setButtonState:(BOOL)loading {
	PWWidgetBrowser *widget = [PWWidgetBrowser widget];
	if (loading) {
		[_actionButton setImage:[widget stopIcon] forState:UIControlStateNormal];
	} else {
		[_actionButton setImage:[widget reloadIcon] forState:UIControlStateNormal];
	}
}

- (void)setButtonHidden:(BOOL)hidden {
	
	if (!hidden && [_textField isFirstResponder]) return [self setButtonHidden:YES];
	
	_buttonHidden = hidden;
	[UIView animateWithDuration:.1 animations:^{
		_actionButton.alpha = hidden ? 0.0 : .5;
	}];
	[self setNeedsLayout];
}

/*
- (void)setMessageLabelText:(NSString *)text {
	_messageLabel.text = text;
}
*/

- (void)setWebViewActive:(BOOL)active {
	
	[UIView animateWithDuration:.1 animations:^{
		_webView.alpha = active ? 1.0 : WEBVIEW_INACTIVE_ALPHA;
	}];
	
	[self setButtonHidden:!active];
}

- (void)updateSuggestionView:(BOOL)hidden {
	
	[_suggestionView reloadData];
	
	_webView.hidden = !hidden;
	_suggestionView.hidden = hidden;
}

- (void)dealloc {
	[self setDelegate:nil];
	RELEASE_VIEW(_textField)
	RELEASE_VIEW(_actionButton)
	RELEASE_VIEW(_separator)
	RELEASE_VIEW(_webView)
	RELEASE_VIEW(_suggestionView)
	//RELEASE_VIEW(_messageLabel)
	[super dealloc];
}

@end

@implementation PWWidgetBrowserWebViewController

- (void)load {
	
	// retrieve preference values
	_hideHTTP = [(PWWidgetBrowser *)self.widget boolValueForPreferenceKey:@"hideHTTP" defaultValue:YES];
	
	self.shouldAutoConfigureStandardButtons = NO;
	self.wantsFullscreen = YES;
	self.requiresKeyboard = YES;
	
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)loadView {
	PWWidgetBrowserWebView *view = [[PWWidgetBrowserWebView new] autorelease];
	[view setDelegate:self];
	self.view = view;
}

- (PWWidgetBrowserWebView *)webView {
	return (PWWidgetBrowserWebView *)self.view;
}

- (void)titleTapped {
	PWWidgetBrowser *widget = (PWWidgetBrowser *)self.widget;
	[widget switchToBookmarkInterface];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	if ([self.navigationItem.leftBarButtonItems count] == 0) {
		_previous = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)101 target:self action:@selector(previousButtonPressed)];
		_next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItem)102 target:self action:@selector(nextButtonPressed)];
		self.navigationItem.leftBarButtonItems = @[_previous, _next];
	}
	
	if ([self.navigationItem.rightBarButtonItems count] == 0) {
		_more = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moreButtonPressed)];
		self.navigationItem.rightBarButtonItems = @[_more];
	}
	
	[self updateNavigationButtonState];
}

- (void)configureFirstResponder {
	
	// auto focus URL if it's empty
	UITextField *textField = self.webView.textField;
	
	if ([PWWidgetBrowser widget].shouldAutoFocus && ([textField.text length] == 0 || [textField.text isEqualToString:@"http://"])) {
		textField.text = _hideHTTP ? @"" : @"http://";
		[textField becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
	}
	
	// reset state
	[PWWidgetBrowser widget].shouldAutoFocus = YES;
}

- (void)loadURLString:(NSString *)urlString {
	
	UITextField *textField = self.webView.textField;
	[textField resignFirstResponder];
	
	if ([urlString length] == 0) {
		urlString = @"about:blank";
	} else if ([[urlString lowercaseString] isEqualToString:@"about:prowidgets"]) {
		urlString = RICKROLL_URL;
	}
	
	// update text field value
	textField.text = urlString;
	
	NSURL *url = [NSURL URLWithString:urlString];
	
	// auto prepend http:// scheme
	if ([[url scheme] length] == 0) {
		if ([urlString rangeOfString:@"."].location != NSNotFound) {
			url = [NSURL URLWithString:[@"http://" stringByAppendingString:urlString]];
		} else {
			NSString *query = [PWWebRequest encodeURIComponent:urlString];
			url = [NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/search?q=%@", query]];
		}
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView.webView loadRequest:request];
	[self.webView updateSuggestionView:YES];
}

- (void)updateTitle {
	NSString *title = [self.webView.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.title = title;
	[_lastTitle release];
	_lastTitle = [title copy];
}

- (void)updateNavigationButtonState {
	// update the previous and next enabled state
	_previous.enabled = [self.webView.webView canGoBack];
	_next.enabled = [self.webView.webView canGoForward];
}

- (void)setLoading:(BOOL)loading {
	_loading = loading;
	[self.webView setButtonState:loading];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldValueDidChange:(UITextField *)textField {
	
	NSString *text = textField.text;
	NSString *apiPath = [NSString stringWithFormat:@"http://suggestqueries.google.com/complete/search?client=firefox&q=%@", [PWWebRequest encodeURIComponent:text]];
	NSURL *apiURL = [NSURL URLWithString:apiPath];
	
	if (_currentSuggestionRequest != nil) {
		[_currentSuggestionRequest cancel];
		RELEASE(_currentSuggestionRequest);
	}
	
	_currentSuggestionRequest = [[PWWebRequest sendRequestWithURL:apiURL completionHandler:^(BOOL success, int statusCode, NSDictionary *headers, NSString *response, NSError *error) {
		
		// release request and suggestion data
		RELEASE(_currentSuggestionRequest);
		RELEASE(_suggestionData);
		
		NSError *jsonError;
		NSArray *root = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
		
		if (jsonError != nil && [root isKindOfClass:[NSArray class]] && root.count > 0) {
			
			NSArray *results = root[1];
			
			// update suggestion data
			_suggestionData = [results isKindOfClass:[NSArray class]] ? [results copy] : nil;
			
			BOOL hidden = [_suggestionData count] == 0;
			[self.webView updateSuggestionView:hidden];
			
		} else {
			// unknown error occurs
			[self.webView updateSuggestionView:YES];
		}
		
	}] retain];
	
	[self.webView.suggestionView reloadData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self.webView setTextFieldActive:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	[self.webView setTextFieldActive:NO];
	
	// revert the textfield value back to current URL
	if ([textField.text length] == 0) {
		textField.text = _lastURLString;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self loadURLString:textField.text];
	return YES;
}

- (void)actionButtonPressed {
	if (_loading) {
		[self.webView.webView stopLoading];
	} else {
		[self.webView.webView reload];
	}
}

#pragma mark - UIWebViewDelegate

- (void)webView:(WebView *)webView didStartProvisionalLoadForFrame:(WebFrame *)frame {
	if ([frame isMainFrame]) {
		
		WebDataSource *dataSource = frame.provisionalDataSource;
		NSURLRequest *request = dataSource.request;
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;
		
		if (urlString == nil || [urlString length] == 0 || [urlString isEqualToString:@"about:blank"]) {
			[self.webView setWebViewActive:NO];
		} else {
			[self.webView setWebViewActive:YES];
		}
		
		RELEASE(_lastURLString);
		_lastURLString = [urlString copy];
		
		[self setLoading:YES];
		
		self.webView.textField.text = urlString;
		[self updateNavigationButtonState];
		
		LOG(@"didStartProvisionalLoadForFrame: %@ \"%@\"", frame, urlString);
	}
}

- (void)webView:(WebView *)webView didCommitLoadForFrame:(WebFrame *)frame {
	if ([frame isMainFrame]) {
		
		WebDataSource *dataSource = frame.dataSource;
		NSURLRequest *request = dataSource.request;
		NSURL *url = request.URL;
		NSString *urlString = url.absoluteString;
		
		if (urlString == nil || [urlString length] == 0 || [urlString isEqualToString:@"about:blank"]) {
			self.title = @"";
			RELEASE(_lastTitle)
			[self.webView setWebViewActive:NO];
		} else {
			[self.webView setWebViewActive:YES];
		}
		
		RELEASE(_lastURLString);
		_lastURLString = [urlString copy];
		
		[self setLoading:YES];
		
		self.webView.textField.text = urlString;
		[self updateNavigationButtonState];
		
		LOG(@"didCommitLoadForFrame: %@ \"%@\"", frame, urlString);
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	// enable action sheet for all types of links
	UIWebDocumentView *documentView = [webView _documentView];
	[documentView setAllowsLinkSheet:YES];
	[documentView setAllowsImageSheet:YES];
	[documentView setAllowsDataDetectorsSheet:YES];
	
	self.title = @"Loading...";
	
	return YES;
}

- (void)webView:(WebView *)view didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
	if ([frame isMainFrame]) {
		self.title = title;
		[_lastTitle release];
		_lastTitle = [title copy];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[self updateTitle];
	
	[self.webView setWebViewActive:YES];
	[self setLoading:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	
	[self updateTitle];
	[self setLoading:NO];
	
	// ignore some errors
	if (error.code == NSURLErrorCancelled) return; // code: -999
	if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
	if (error.code == 204) return; // Plugin loaded (the web view will handle it)
	
	self.title = @"Error";
	RELEASE(_lastTitle)
	
	[self.webView setWebViewActive:NO];
	
	LOG(@"Webview error: %@", error);
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot open the page." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0:
			{
				PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
				
				UIApplication *app = [UIApplication sharedApplication];
				NSString *urlString = _lastURLString;
				
				NSURL *url = nil;
				if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
					NSRange range = NSMakeRange(4, urlString.length - 4);
					NSString *chromeURLString = [NSString stringWithFormat:@"googlechrome%@", [urlString substringWithRange:range]];
					url = [PWURL URLWithString:chromeURLString];
				} else {
					url = [PWURL URLWithString:urlString];
				}
				
				if ([app canOpenURL:url]) {
					[app openURL:url];
					[self.widget dismiss];
				}
			}
			break;
		case 1: // Copy URL
			[[UIPasteboard generalPasteboard] setString:_lastURLString];
			break;
		case 2: // Add Bookmark...
			{
				PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
				
				if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Adding bookmark to Chrome is not supported yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
					[alert show];
					[alert release];
				} else {
					NSString *title = _lastTitle;
					NSString *url = _lastURLString;
					PWWidgetBrowser *widget = (PWWidgetBrowser *)self.widget;
					[widget addBookmarkFromWebInterfaceWithTitle:title url:url animated:YES];
				}
			}
			break;
		case 3: // Close Browser
			[self.widget dismiss];
			break;
		default:
			break;
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	RELEASE(_actionSheet)
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 38.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	NSString *urlString = nil;
	
	if (row == 0) {
		// Navigate to the URL
		urlString = self.webView.textField.text;
	} else {
		NSString *searchTerm = _suggestionData[row - 1];
		urlString = searchTerm;
	}
	
	[self loadURLString:urlString];
	
	[_currentSuggestionRequest cancel];
	RELEASE(_currentSuggestionRequest);
	
	RELEASE(_suggestionData);
	[self.webView updateSuggestionView:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger count = [_suggestionData count];
	return count == 0 ? 0 : count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *identifier = @"PWBrowserSuggestionCell";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (cell == nil) {
		cell = [[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier theme:[PWWidgetBrowser theme]];
		cell.alpha = .8;
		cell.textLabel.font = [UIFont systemFontOfSize:16.0];
	}
	
	NSUInteger row = [indexPath row];
	
	if (row == 0) {
		cell.textLabel.text = [NSString stringWithFormat:@"Navigate to %@", self.webView.textField.text];
		cell.imageView.image = nil;
	} else {
		NSString *suggestion = _suggestionData[row - 1];
		cell.textLabel.text = suggestion;
		cell.imageView.image = [[PWWidgetBrowser widget] imageNamed:@"search"];
	}
	
	return cell;
}

#pragma mark - Others

- (void)previousButtonPressed {
	[self.webView.webView goBack];
}

- (void)nextButtonPressed {
	[self.webView.webView goForward];
}

- (void)moreButtonPressed {
	
	if (_actionSheet != nil) return;
	
	[self.webView.textField resignFirstResponder];
	
	PWWidgetBrowserDefault defaultBrowser = [(PWWidgetBrowser *)self.widget defaultBrowser];
	NSString *defaultBrowserText = nil;
	if (defaultBrowser == PWWidgetBrowserDefaultChrome) {
		defaultBrowserText = @"Chrome";
	} else {
		defaultBrowserText = @"Safari";
	}
	
	_actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Open in %@", defaultBrowserText], @"Copy URL", @"Bookmark...", @"Close Browser", nil];
	
	PWTheme *theme = self.theme;
	if (theme.wantsDarkKeyboard) {
		_actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	}
	
	if ([PWController isIPad]) {
		[_actionSheet showFromBarButtonItem:_more animated:YES];
	} else {
		UIView *mainView = [PWController sharedInstance].mainView;
		[_actionSheet showInView:mainView];
	}
}

- (void)dealloc {
	
	RELEASE(_lastTitle)
	RELEASE(_lastURLString)
	RELEASE(_previous)
	RELEASE(_next)
	RELEASE(_more)
	
	[_actionSheet dismissWithClickedButtonIndex:0 animated:NO];
	RELEASE(_actionSheet)
	
	[_currentSuggestionRequest cancel];
	RELEASE(_currentSuggestionRequest);
	RELEASE(_suggestionData);
	
	[super dealloc];
}

@end