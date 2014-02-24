#import "PWPrefURLInstallationRootController.h"
#import "PWPrefURLInstallationRootView.h"
#import "PWPrefURLInstallationInfoView.h"
#import "PWController.h"
#import "NSTask.h"

#define DELAY_SEND(target,action) [target performSelector:@selector(action) withObject:nil afterDelay:0.5];

extern NSBundle *bundle;

@implementation PWPrefURLInstallationRootController

- (instancetype)initWithURL:(NSURL *)url type:(PWPrefURLInstallationType)type fromPreference:(BOOL)fromPreference {
	if ((self = [super init])) {
		self.url = url;
		self.type = type;
		self.fromPreference = fromPreference;
	}
	return self;
}

- (void)loadView {
	self.view = [[PWPrefURLInstallationRootView new] autorelease];
}

- (void)viewWillAppear:(BOOL)animated {
	
	// set title
	self.navigationItem.title = @"URL Installation";
	
	// set cancel button
	UIBarButtonItem *cancelBtn = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)] autorelease];
	cancelBtn.possibleTitles = [NSSet setWithObjects:@"Cancel", @"Close", nil];
	self.navigationItem.leftBarButtonItem = cancelBtn;
	
	// set initial status
	[self.rootView setURL:[_url absoluteString]];
	
	if (self.fromPreference) {
		[self.rootView setStatus:@"Downloading..."];
	} else {
		[self.rootView setStatus:@"Ready to Download"];
		[self.rootView hideProgressView];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	
	void (^begin)(void) = ^() {
		if (!self.fromPreference) {
			[self.rootView setStatus:@"Downloading..."];
			[self.rootView showProgressView];
		}
		[self.rootView setProgressText:@"Connecting to server..."];
		[self downloadPackage];
	};
	
	// start download
	if (!self.fromPreference) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
			begin();
		});
	} else {
		begin();
	}
}

- (PWPrefURLInstallationRootView *)rootView {
	return (PWPrefURLInstallationRootView *)self.view;
}

- (void)downloadPackage {
	
	// check URL format
	if ([[_url absoluteString] length] == 0) {
		[self showError:@"Empty installation URL"];
		return;
	}
	
	NSString *scheme = [[_url scheme] lowercaseString];
	if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
		[self showError:@"Unsupported installation URL"];
		return;
	}
	
	// setup file handle
	if (![self setupTempFile]) {
		[self _removeTempFile];
		return;
	}
	
	// configure request
	_request = [[NSMutableURLRequest alloc] initWithURL:_url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
	
	// set request method
	[_request setHTTPMethod:@"GET"];
	
	// set default headers
	[_request setValue:@"ProWidgets" forHTTPHeaderField:@"User-Agent"];
	[_request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// configure connection
	_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
}

- (void)validatePackage {
	
	LOG(@"PWPrefURLInstallationRootController: validatePackage");
	
	[self.rootView exitDownloadInterface];
	[self.rootView setStatus:@"Validating..."];
	[self.rootView setProgressText:@"Please wait until the package validation process completes."];
	
	if (_filePath == nil) {
		[self showUnknownError];
		return;
	}
	
	NSString *unzipPath = @"/usr/bin/unzip";
	if (![[NSFileManager defaultManager] isExecutableFileAtPath:unzipPath]) {
		[self showError:@"Unable to extract the package.\nPlease reinstall ProWidgets in Cydia."];
		return;
	}
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:unzipPath];
	[task setArguments:@[@"-l", @"-qq", _filePath]];
	
	// configure output pipe
	task.standardOutput = [NSPipe pipe];
	
	// configure notification
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validatePackageReadOutputComplete:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[task.standardOutput fileHandleForReading]];
	
	[[task.standardOutput fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	
	// launch the task
	[task launch];
	[task autorelease];
}

- (void)validatePackageReadOutputComplete:(NSNotification *)notification {
	
	if (_validated) return;
	_validated = YES;
	
	NSString *infoFilePath = @".bundle/Info.plist";
	
	NSData *data = [notification userInfo][NSFileHandleNotificationDataItem];
	NSString *output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	BOOL valid = [output rangeOfString:infoFilePath].location != NSNotFound;
	
	LOG(@"PWPrefURLInstallationRootController: Received validation output from standard output.\n\n%@\n\n", output);
	
	if (valid) {
		DELAY_SEND(self, extractPackage)
	} else {
		DELAY_SEND(self, showInvalidPackage)
	}
}

- (void)extractPackage {
	
	LOG(@"PWPrefURLInstallationRootController: extractPackage");
	
	[self.rootView setStatus:@"Extracting..."];
	[self.rootView setProgressText:@"Please wait until the package extraction process completes."];
	
	if (![self setupTempDirectory]) {
		[self _removeTempFile];
		[self _removeTempDirectory];
		return;
	}
	
	if (_directoryPath == nil || _filePath == nil || [_directoryPath length] == 0 || [_filePath length] == 0) {
		[self showUnknownError];
		return;
	}
	
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/bin/unzip"];
	[task setArguments:@[@"-u", @"-qq", @"-d", _directoryPath, _filePath]];
	
	// configure output pipe
	task.standardOutput = [NSPipe pipe];
	
	// configure notification
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(extractPackageReadOutputComplete:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[task.standardOutput fileHandleForReading]];
	
	[[task.standardOutput fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
	
	// launch the task
	[task launch];
	[task autorelease];
}

- (void)extractPackageReadOutputComplete:(NSNotification *)notification {
	
	if (_extracted) return;
	_extracted = YES;
	
	NSData *data = [notification userInfo][NSFileHandleNotificationDataItem];
	NSString *output = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	BOOL fail = NO;
	
	LOG(@"PWPrefURLInstallationRootController: Received extraction output from standard output.\n\n%@\n\n", output);
	
	// the zip file is no longer necessary
	[self _removeTempFile];
	
	// empty contents
	if ([[[NSFileManager defaultManager] contentsOfDirectoryAtPath:_directoryPath error:nil] count] == 0) {
		fail = YES;
	}
	
	if (!fail) {
		DELAY_SEND(self, analyzePackage)
	} else {
		DELAY_SEND(self, showExtractionFail)
	}
}

- (void)analyzePackage {
	
	LOG(@"PWPrefURLInstallationRootController: analyzePackage");
	
	[self.rootView setStatus:@"Analyzing..."];
	[self.rootView setProgressText:@"Please wait until the analysis of package contents finishes."];
	
	if (_directoryPath == nil || [_directoryPath length] == 0) {
		[self showUnknownError];
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// check if the package contains only one bundle with correct structure (./XXX.bundle/Info.plist)
	BOOL onlyOneBundle = YES;
	NSString *installBundleName = nil;
	NSString *installBundlePath = nil;
	NSArray *rootSubfolders = [fm contentsOfDirectoryAtPath:_directoryPath error:nil];
	for (NSString *name in rootSubfolders) {
		
		if ([name hasPrefix:@"."]) continue; // bypass hidden items
		if ([name length] <= 7) continue; // shorter or equal to ".bundle"
		if (![name hasSuffix:@".bundle"]) continue; // bypass non-bundle items
		
		BOOL isDir = NO;
		NSString *bundlePath = [NSString stringWithFormat:@"%@/%@", _directoryPath, name];
		if ([fm fileExistsAtPath:bundlePath isDirectory:&isDir] && isDir) {
			
			// check excess bundles
			if (installBundlePath != nil && installBundlePath != nil) {
				onlyOneBundle = NO;
				installBundleName = nil;
				installBundlePath = nil;
				break;
			}
			
			installBundleName = [name stringByDeletingPathExtension]; // remove ".bundle"
			installBundlePath = bundlePath;
		}
	}
	
	if (!onlyOneBundle) {
		[self showError:@"Invalid package (more than one bundles)"];
		return;
	}
	
	if (installBundleName == nil || installBundlePath == nil) {
		[self showError:@"Invalid package (bundle not found)"];
		return;
	}
	
	// a simple check to ensure the bundle can be found and is accessible
	NSBundle *installBundle = [NSBundle bundleWithPath:installBundlePath];
	
	if (installBundle == nil) {
		// unexpected
		[self showInvalidPackage];
		return;
	}
	
	// check duplication
	NSString *installedPath = [NSString stringWithFormat:@"%@/%@/%@.bundle", [PWController basePath], (self.type == PWPrefURLInstallationTypeWidget ? @"Widgets" : @"Themes"), installBundleName];
	if ([fm fileExistsAtPath:installedPath]) {
		[self showError:@"You have installed a package with the same name before."];
		return;
	}
	
	// retrieve information of this bundle
	// info dictionary
	NSString *infoPath = [NSString stringWithFormat:@"%@/Info.plist", installBundlePath];
	NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:infoPath];
	
	if (info == nil) {
		[self showError:@"Invalid package (unable to read Info.plist)"];
		return;
	}
	
	// parse the plist via PWController
	NSDictionary *parsed = nil;
	if (self.type == PWPrefURLInstallationTypeWidget)
		parsed = [[PWController sharedInstance] infoOfWidgetInBundle:installBundle];
	else if (self.type == PWPrefURLInstallationTypeTheme)
		parsed = [[PWController sharedInstance] infoOfThemeInBundle:installBundle];
	
	if (parsed == nil) {
		[self showError:@"Invalid package type"];
		return;
	}
	
	// update _installBundleName and _installBundlePath
	_installBundleName = [installBundleName copy];
	_installBundlePath = [installBundlePath copy];
	
	// PWInfoDisplayName
	NSString *displayName = parsed[@"displayName"];
	
	// PWInfoAuthor
	NSString *author = parsed[@"author"];
	if ([author length] == 0) author = @"Unknown";
	
	// PWInfoDescription
	NSString *description = parsed[@"description"];
	if ([description length] == 0) description = @"No description";
	
	// PWInfoIconFile
	NSString *iconFile = parsed[@"iconFile"];
	
	UIImage *icon = [UIImage imageNamed:iconFile inBundle:installBundle];
	if (icon == nil) {
		if (self.type == PWPrefURLInstallationTypeWidget) {
			icon = [UIImage imageNamed:@"icon_widgets" inBundle:bundle];
		} else if (self.type == PWPrefURLInstallationTypeTheme) {
			icon = [UIImage imageNamed:@"icon_themes" inBundle:bundle];
		}
	}
	
	PWPrefURLInstallationInfoView *infoView = [[PWPrefURLInstallationInfoView new] autorelease];
	[infoView setIcon:icon];
	[infoView setName:displayName];
	[infoView setAuthor:author];
	[infoView setDescription:description];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		[self.rootView switchToInfoView:infoView];
	});
}

- (void)confirmInstallation {
	
	LOG(@"PWPrefURLInstallationRootController: confirmInstallation");
	
	[self.rootView switchFromInfoView];
	[self.rootView setStatus:@"Installing..."];
	[self.rootView setProgressText:@"Please wait until the package installation process completes."];
	
	if (_installBundlePath == nil || _installBundleName == nil || [_installBundlePath length] == 0 || [_installBundleName length] == 0) {
		[self showUnknownError];
		return;
	}
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	// first, ensure the target directory exists
	NSString *sourcePath = _installBundlePath;
	NSString *containerPath = [NSString stringWithFormat:@"%@/%@/", [PWController basePath], (self.type == PWPrefURLInstallationTypeWidget ? @"Widgets" : @"Themes")];
	NSString *destinationPath = [NSString stringWithFormat:@"%@%@.bundle/", containerPath, _installBundleName];
	
	if (![fm fileExistsAtPath:containerPath]) {
		if (![fm createDirectoryAtPath:containerPath withIntermediateDirectories:YES attributes:nil error:nil]) {
			[self showError:@"Unable to reach the destination path. You may try reinstalling ProWidgets in Cydia."];
			return;
		}
	}
	
	// copy the bundle from extracted path to /Library/ProWidgets/
	if (![fm copyItemAtPath:sourcePath toPath:destinationPath error:nil]) {
		[self showError:@"Unable to copy package contents to destination path."];
		return;
	}
	
	// create an indicator file
	NSString *indicatorPath = [NSString stringWithFormat:@"%@.installed", destinationPath];
	[fm createFileAtPath:indicatorPath contents:[NSData data] attributes:nil];
	
	// completed
	DELAY_SEND(self, finishInstallation)
}

- (void)finishInstallation {
	
	LOG(@"PWPrefURLInstallationRootController: finishInstallation");
	
	[self.rootView setStatus:@"Installation Complete"];
	[self.rootView setProgressText:@"The installation was successful. You can uninstall it in the preference page anytime."];
	
	// update close button text
	self.navigationItem.leftBarButtonItem.title = @"Close";
	
	// clear everything
	[self _clear];
}

- (void)showUnknownError {
	LOG(@"PWPrefURLInstallationRootController: showUnknownError");
	[self showError:@"Unknown error occurs. Please try again."];
}

- (void)showInvalidPackage {
	LOG(@"PWPrefURLInstallationRootController: showInvalidPackage");
	[self showError:@"Invalid package"];
}

- (void)showExtractionFail {
	LOG(@"PWPrefURLInstallationRootController: showExtractionFail");
	[self showError:@"Fail to extract package, or the package content is empty"];
}

- (BOOL)setupTempFile {
	
	// create temp filename template
	const char *template = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"ProWidgets.XXXXXX"] fileSystemRepresentation];
	char *filename = (char *)malloc(strlen(template) + 1);
	strcpy(filename, template);
	
	// create temp file descriptor
	int descriptor = mkstemp(filename);
	
	// get the temp file path
	_filePath = [[NSString stringWithCString:filename encoding:NSASCIIStringEncoding] copy];
	free(filename);
	
	if (descriptor == -1 || _filePath == nil) {
		[self showError:@"Unable to create a temporary file. Please try again."];
		return NO;
	}
	
	// create a file handle
	_fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:descriptor closeOnDealloc:YES];
	
	LOG(@"PWPrefURLInstallationRootController: setupTempFile: %@ <%@>", _filePath, _fileHandle);
	
	return YES;
}

- (BOOL)setupTempDirectory {
	
	const char *template = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"ProWidgets.Extraction.XXXXXX"] fileSystemRepresentation];
	char *directoryName = (char *)malloc(strlen(template) + 1);
	strcpy(directoryName, template);
	
	char *result = mkdtemp(directoryName);
	
	_directoryPath = [[NSString stringWithCString:directoryName encoding:NSASCIIStringEncoding] copy];
	free(directoryName);
	
	if (!result || _directoryPath == nil) {
		[self showError:@"Unable to create a temporary directory. Please try again."];
		return NO;
	}
	
	LOG(@"PWPrefURLInstallationRootController: setupTempFile: %@", _directoryPath);
	
	return YES;
}

- (void)retry {
	[self _clear];
	PWPrefURLInstallationRootController *controller = [[[PWPrefURLInstallationRootController alloc] initWithURL:self.url type:self.type fromPreference:NO] autorelease];
	self.navigationController.viewControllers = @[controller];
}

- (void)cancel {
	[self _clear];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showError:(NSString *)error {
	[self _clear];
	[self.rootView exitDownloadInterface];
	[self.rootView setError:error];
}

- (void)_removeTempFile {
	
	LOG(@"PWPrefURLInstallationRootController: _removeTempFile");
	
	// close file handle
	[_fileHandle closeFile];
	RELEASE(_fileHandle)
	
	// remove tmp file
	[[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
	RELEASE(_filePath)
}

- (void)_removeTempDirectory {
	
	LOG(@"PWPrefURLInstallationRootController: _removeTempDirectory");
	
	// remove tmp file
	[[NSFileManager defaultManager] removeItemAtPath:_directoryPath error:nil];
	RELEASE(_directoryPath)
}

- (void)_finishConnection {
	
	LOG(@"PWPrefURLInstallationRootController: _finishConnection");
	
	[_connection cancel];
	
	RELEASE(_request)
	RELEASE(_connection)
}

- (void)_clear {
	[self _removeTempFile];
	[self _removeTempDirectory];
	[self _finishConnection];
}

///// NSURLConnectionDelegate /////

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	LOG(@"PWWebRequest: didFailWithError <error: %@>", error);
	
	NSString *errMsg = [error localizedDescription];
	if (errMsg == nil) {
		[self showUnknownError];
	} else {
		[self showError:errMsg];
	}
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
	return YES;
}

///// NSURLConnectionDataDelegate /////

// handle redirection
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	
	if (redirectResponse) {
		NSMutableURLRequest *redirectedRequest = [[_request mutableCopy] autorelease];
		[redirectedRequest setURL:[request URL]];
		return redirectedRequest;
	} else {
		return request;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	// HTTP status code
	int statusCode = [response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)response statusCode] : 0;
	
	if (statusCode >= 400) {
		
		NSString *extraInfo = nil;
		switch (statusCode) {
			case 400:
				extraInfo = @"Bad Request";
				break;
			case 401:
				extraInfo = @"Unauthorized";
				break;
			case 403:
				extraInfo = @"Forbidden";
				break;
			case 404:
				extraInfo = @"Not Found";
				break;
			case 408:
				extraInfo = @"Request Timeout";
				break;
			case 500:
				extraInfo = @"Internal Server Error";
				break;
			case 503:
				extraInfo = @"Service Unavailable";
				break;
		}
		
		if (extraInfo != nil)
			extraInfo = [NSString stringWithFormat:@"\n(%@)", extraInfo];
		else
			extraInfo = @"";
		
		[self showError:[NSString stringWithFormat:@"Received HTTP status code: %d%@", statusCode, extraInfo]];
		return;
	}
	
	// expected content length
	long long contentLength = [response expectedContentLength];
	[self.rootView setExpectedContentLength:contentLength];
	
	LOG(@"PWPrefURLInstallationRootController: didReceiveResponse <status code: %d> <expected content length: %lld>", statusCode, contentLength);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	LOG(@"PWPrefURLInstallationRootController: didReceiveData (%lu bytes)", (unsigned long)[data length]);
	
	//[_response appendData:data];
	_receivedDataLength += [data length];
	[self.rootView setDownloadedBytes:_receivedDataLength];
	[_fileHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	LOG(@"PWPrefURLInstallationRootController: connectionDidFinishLoading (total %lu bytes)", _receivedDataLength);
	
	[self _finishConnection];
	[self validatePackage];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	[self _clear];
	
	RELEASE(_url)
	RELEASE(_request)
	RELEASE(_connection)
	RELEASE(_filePath)
	RELEASE(_fileHandle)
	RELEASE(_directoryPath)
	RELEASE(_installBundleName)
	RELEASE(_installBundlePath)
	
	[super dealloc];
}

@end