//
//  ProWidgets
//  Theme for Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Theme.h"

@implementation PWWidgetThemeGoogleAuthenticator

- (CGFloat)cornerRadius {
	return 0.0;
}

- (UIColor *)navigationBarBackgroundColor {
	return [PWTheme parseColorString:@"#d0d0d0"];
}

- (UIColor *)navigationTitleTextColor {
	return [PWTheme parseColorString:@"#333"];
}

- (UIColor *)navigationButtonTextColor {
	return [PWTheme parseColorString:@"#333"];
}

@end