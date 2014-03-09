//
//  ProWidgets
//  Spotify
//
//  Created by Alan Yip on 9 Mar 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "ViewController.h"
#import "PWTheme.h"
#import "PWController.h"
#import "PWWidget.h"
#import <objcipc/objcipc.h>

@implementation PWWidgetSpotifyViewController

- (void)load {
	
	self.requiresKeyboard = NO;
	self.shouldMaximizeContentHeight = NO;
	self.actionButtonText = @"App";
	
	self.view.backgroundColor = [PWTheme parseColorString:@"#ecebe8"];
}

- (NSString *)title {
	return @"Spotify";
}

- (void)loadView {
	self.view = [[UIView new] autorelease];
}

- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation {
	return 150.0;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	// add close and action buttons
	[self configureStandardButtons];
}

- (void)triggerAction {
	// "App" button
	// open Spotify app
	SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
	[app launchApplicationWithIdentifier:SpotifyIdentifier suspended:NO];
	[self.widget dismiss];
}

@end