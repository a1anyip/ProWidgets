#import "header.h"

@interface PWPrefURLInstallationRootView : UIView {
	
	BOOL _exitedDownloadInterface;
	PWPrefInfoView *_infoView;
	
	UILabel *_statusLabel;
	UILabel *_urlLabel;
	UILabel *_progressLabel;
	UIProgressView *_progressView;
	UIButton *_retryButton;
	
	long long _expectedContentLength;
	long long _downloadedBytes;
}

- (void)hideProgressView;
- (void)showProgressView;
- (void)exitDownloadInterface;

- (void)switchToInfoView:(PWPrefInfoView *)view;
- (void)switchFromInfoView;

- (void)setStatus:(NSString *)status;
- (void)setURL:(NSString *)url;
- (void)setProgressText:(NSString *)text;

- (void)setExpectedContentLength:(long long)length;
- (void)setDownloadedBytes:(long long)bytes;
- (void)updateProgress;

- (void)setError:(NSString *)errMsg;

- (NSString *)_formatBytes:(long long)bytes;

@end