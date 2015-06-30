//
//  ProWidgets
//  Theme for Spotify
//
//  Created by Alan Yip on 9 Mar 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Theme.h"

@implementation PWWidgetThemeSpotify

- (CGFloat)cornerRadius {
	return 0.0;
}

- (UIColor *)navigationBarBackgroundColor {
	return [PWTheme parseColorString:@"#1e1e1d"];
}

- (UIColor *)navigationTitleTextColor {
	return [PWTheme parseColorString:@"#FFF"];
}

- (UIColor *)navigationButtonTextColor {
	return [PWTheme parseColorString:@"#84bd00"];
}

@end