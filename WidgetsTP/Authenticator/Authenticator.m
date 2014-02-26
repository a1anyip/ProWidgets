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
	// configure theme
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
	
	// push a custom view controller
	_viewController = [PWWidgetGoogleAuthenticatorViewController new];
	[self pushViewController:_viewController animated:NO];
}

- (void)willDismiss {
	[_viewController invalidateTimer];
	[OBJCIPC deactivateAppWithIdentifier:AuthenticatorIdentifier];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_viewController)
	[super dealloc];
}

@end