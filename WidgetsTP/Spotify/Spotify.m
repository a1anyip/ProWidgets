//
//  ProWidgets
//  Spotify
//
//  Created by Alan Yip on 9 Mar 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Spotify.h"

@implementation PWWidgetSpotify

- (void)configure {
	// configure theme
	self.layout = PWWidgetLayoutCustom;
	[self loadThemeNamed:@"PWWidgetThemeSpotify"];
}

- (void)load {
	
	// check if the app is installed on the device
	SBApplicationController *controller = [objc_getClass("SBApplicationController") sharedInstance];
	SBApplication *spotifyApp = [controller applicationWithDisplayIdentifier:SpotifyIdentifier];
	if (spotifyApp == nil) {
		[self showMessage:@"You need to install Spotify app from App Store to use this widget."];
		[self dismiss];
		return;
	}
	
	// push a custom view controller
	_viewController = [[PWWidgetSpotifyViewController alloc] initForWidget:self];
	[self pushViewController:_viewController animated:NO];
	
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)willDismiss {
	[OBJCIPC deactivateAppWithIdentifier:SpotifyIdentifier];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_viewController)
	[super dealloc];
}

@end