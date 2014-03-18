#import "PWPrefURLInstallationRootView.h"
#import "PWPrefURLInstallationRootController.h"
#import "PWPrefInfoView.h"
#import "../PWTheme.h"

extern NSBundle *bundle;

@implementation PWPrefURLInstallationRootView

- (instancetype)init {
	if ((self = [super init])) {
		
		// set background color
		self.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1.0];
		
		// add status label
		_statusLabel = [UILabel new];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		_statusLabel.textColor = [UIColor blackColor];
		_statusLabel.font = [UIFont boldSystemFontOfSize:24];
		[self addSubview:_statusLabel];
		
		// add URL label
		_urlLabel = [UILabel new];
		_urlLabel.textAlignment = NSTextAlignmentCenter;
		_urlLabel.textColor = [PWTheme systemBlueColor];
		_urlLabel.font = [UIFont systemFontOfSize:14];
		_urlLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
		[self addSubview:_urlLabel];
		
		// add progress label
		_progressLabel = [UILabel new];
		_progressLabel.textAlignment = NSTextAlignmentCenter;
		_progressLabel.textColor = [UIColor colorWithWhite:.5 alpha:1.0];
		_progressLabel.font = [UIFont systemFontOfSize:14];
		_progressLabel.numberOfLines = 2;
		[self addSubview:_progressLabel];
		
		// add progress view
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
		[self addSubview:_progressView];
		
		// add retry button
		_retryButton = [UIButton new];
		_retryButton.adjustsImageWhenHighlighted = YES;
		_retryButton.alpha = 0.0;
		_retryButton.hidden = YES;
		[_retryButton setTitle:PTEXT(@"Retry") forState:UIControlStateNormal];
		[_retryButton setBackgroundImage:[PWTheme imageFromColor:[UIColor redColor]] forState:UIControlStateNormal];
		[_retryButton addTarget:[self nextResponder] action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_retryButton];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	CGFloat statusHeight = 30.0;
	CGFloat urlHeight = 50.0;
	CGFloat progressViewHeight = 2.0;
	CGFloat progressLabelHeight = 50.0;
	CGFloat buttonHeight = 60.0;
	
	CGFloat top = (height - statusHeight - urlHeight - progressViewHeight - progressLabelHeight) / 2;
	CGFloat horizontalMargin = 10.0;
	CGFloat labelWidth = width - horizontalMargin * 2;
	
	CGRect statusRect = CGRectMake(horizontalMargin, top, labelWidth, statusHeight);
	CGRect urlRect = CGRectMake(horizontalMargin, statusRect.origin.y + statusRect.size.height, labelWidth, urlHeight);
	CGRect progressViewRect = CGRectMake(0, urlRect.origin.y + urlRect.size.height, width, progressViewHeight);
	CGRect progressLabelRect = CGRectMake(horizontalMargin, progressViewRect.origin.y + progressViewRect.size.height, labelWidth, progressLabelHeight);
	CGRect buttonRect = CGRectMake(0, height - buttonHeight, width, buttonHeight);
	
	if (_exitedDownloadInterface) {
		progressLabelRect.origin.y -= 40.0;
	}
	
	_statusLabel.frame = statusRect;
	_urlLabel.frame = urlRect;
	_progressLabel.frame = progressLabelRect;
	_progressView.frame = progressViewRect;
	_retryButton.frame = buttonRect;
}

- (void)hideProgressView {
	_progressView.hidden = YES;
	_progressView.alpha = 0.0;
}

- (void)showProgressView {
	
	_progressView.hidden = NO;
	_progressView.alpha = 0.0;
	
	[UIView animateWithDuration:0.3 animations:^{
		_progressView.alpha = 1.0;
	}];
}

- (void)exitDownloadInterface {
	
	if (_exitedDownloadInterface) return;
	_exitedDownloadInterface = YES;
	
	CGRect finalRect = _progressLabel.frame;
	finalRect.origin.y -= 40.0;
	
	[UIView animateWithDuration:0.3 animations:^{
		_urlLabel.alpha = 0.0;
		_progressView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_urlLabel removeFromSuperview];
		[_progressView removeFromSuperview];
	}];
	
	[UIView animateWithDuration:0.5 animations:^{
		_progressLabel.frame = finalRect;
	}];
}

- (void)switchToInfoView:(PWPrefInfoView *)view {
	
	if (_infoView != nil) return;
	
	// update reference
	_infoView = [view retain];
	
	view.alpha = 0.0;
	view.frame = self.bounds;
	[self addSubview:view];
	
	[UIView animateWithDuration:0.3 animations:^{
		_statusLabel.alpha = 0.0;
		_progressLabel.alpha = 0.0;
		view.alpha = 1.0;
	} completion:^(BOOL finished) {
		_statusLabel.hidden = YES;
		_progressLabel.hidden = YES;
	}];
}

- (void)switchFromInfoView {
	
	if (_infoView == nil) return;
	
	_statusLabel.hidden = NO;
	_progressLabel.hidden = NO;
	
	[UIView animateWithDuration:0.3 animations:^{
		_statusLabel.alpha = 1.0;
		_progressLabel.alpha = 1.0;
		_infoView.alpha = 0.0;
	} completion:^(BOOL finished) {
		RELEASE_VIEW(_infoView)
	}];
}

- (void)setStatus:(NSString *)status {
	_statusLabel.text = status;
}

- (void)setURL:(NSString *)url {
	_urlLabel.text = url;
}

- (void)setProgressText:(NSString *)text {
	_progressLabel.text = text;
}

- (void)setExpectedContentLength:(long long)length {
	_expectedContentLength = length;
	[self updateProgress];
}

- (void)setDownloadedBytes:(long long)bytes {
	_downloadedBytes = bytes;
	[self updateProgress];
}

- (void)updateProgress {
	
	CGFloat progress = 0.0;
	NSString *downloadedString = [self _formatBytes:_downloadedBytes];
	NSString *lengthString = @"";
	
	if (_expectedContentLength == NSURLResponseUnknownLength || _expectedContentLength < 0) {
		
		// unknown content length
		lengthString = @"?";
		
	} else {
		
		// known content length
		lengthString = [self _formatBytes:_expectedContentLength];
		if (lengthString == nil) lengthString = @"";
		
		// calculate progress percentage
		if (_expectedContentLength > 0)
			progress = (CGFloat)_downloadedBytes / (CGFloat)_expectedContentLength;
	}
	
	[self setProgressText:[NSString stringWithFormat:@"%@ / %@", downloadedString, lengthString]];
	[_progressView setProgress:progress animated:NO];
}

- (void)setError:(NSString *)errMsg {
	[self setStatus:PTEXT(@"Failed")];
	[self setProgressText:errMsg];
	
	// show the retry button
	_retryButton.alpha = 0.0;
	_retryButton.hidden = NO;
	
	[UIView animateWithDuration:0.3 animations:^{
		_retryButton.alpha = 1.0;
	}];
}

- (NSString *)_formatBytes:(long long)bytes {
	NSByteCountFormatter *formatter = [NSByteCountFormatter new];
	formatter.allowsNonnumericFormatting = NO;
	formatter.adaptive = YES;
	formatter.zeroPadsFractionDigits = YES;
	NSString *formatted = [[formatter stringFromByteCount:bytes] copy];
	[formatter release];
	return [formatted autorelease];
}

- (void)dealloc {
	RELEASE_VIEW(_statusLabel)
	RELEASE_VIEW(_urlLabel)
	RELEASE_VIEW(_progressLabel)
	RELEASE_VIEW(_progressView)
	RELEASE_VIEW(_retryButton)
	[super dealloc];
}

@end