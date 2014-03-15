//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Authenticator.h"

@implementation PWWidgetGoogleAuthenticator

- (BOOL)requiresProtectedDataAccess {
	return YES;
}

- (void)configure {
	self.layout = PWWidgetLayoutCustom;
	[self loadThemeNamed:@"PWWidgetThemeGoogleAuthenticator"];
}

- (void)load {
	
	// check if the app is installed on the device
	SBApplicationController *controller = [objc_getClass("SBApplicationController") sharedInstance];
	SBApplication *authApp = [controller applicationWithDisplayIdentifier:AuthenticatorIdentifier];
	if (authApp == nil) {
		[self showMessage:@"You need to install Google Authenticator app from App Store to use this widget."];
		[self dismiss];
		return;
	}
	
	// get its bundle
	NSString *path = authApp.path;
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	
	_reloadImage = [[UIImage imageNamed:@"refresh" inBundle:bundle] retain];
	
	// push a custom view controller
	_viewController = [[PWWidgetGoogleAuthenticatorViewController alloc] initForWidget:self];
	[self pushViewController:_viewController animated:NO];
}

- (void)willDismiss {
	[_viewController invalidateTimer];
	[OBJCIPC deactivateAppWithIdentifier:AuthenticatorIdentifier];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_viewController)
	RELEASE(_reloadImage)
	[super dealloc];
}

@end