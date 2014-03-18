#import "header.h"

@interface PWPrefURLInstallationRootController : UIViewController<NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {
	
	// basic properties
	NSURL *_url;
	PWPrefURLInstallationType _type;
	NSString *_bundleExtension;
	BOOL _fromPreference;
	
	// request and connection
	NSMutableURLRequest *_request;
	NSURLConnection *_connection;
	
	// temp file path and handle
	unsigned long _receivedDataLength;
	NSString *_filePath;
	NSFileHandle *_fileHandle;
	
	NSString *_directoryPath;
	NSString *_installBundleName;
	NSString *_installBundlePath;
	
	BOOL _validated;
	BOOL _extracted;
}

@property(nonatomic, retain) NSURL *url;
@property(nonatomic) PWPrefURLInstallationType type;
@property(nonatomic, copy) NSString *bundleExtension;
@property(nonatomic) BOOL fromPreference;

- (instancetype)initWithURL:(NSURL *)url type:(PWPrefURLInstallationType)type fromPreference:(BOOL)fromPreference;
- (PWPrefURLInstallationRootView *)rootView;

- (void)downloadPackage;
- (void)validatePackage;
- (void)extractPackage;
- (void)analyzePackage;
- (void)confirmInstallation;
- (void)finishInstallation;

- (void)showUnknownError;
- (void)showInvalidPackage;
- (void)showExtractionFail;

- (BOOL)setupTempFile;
- (BOOL)setupTempDirectory;

- (void)cancel;
- (void)showError:(NSString *)error;

- (void)_removeTempFile;
- (void)_removeTempDirectory;
- (void)_finishConnection;
- (void)_clear;

@end