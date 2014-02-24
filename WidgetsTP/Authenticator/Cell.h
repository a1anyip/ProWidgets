//
//  ProWidgets
//  Google Authenticator
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetGoogleAuthenticatorTableViewCell : UITableViewCell {
	
	UILabel *_copiedLabel;
	UILabel *_textLabel;
	UILabel *_codeLabel;
}

- (void)setName:(NSString *)name issuer:(NSString *)issuer;
- (void)setCode:(NSString *)code;
- (void)setWarning:(BOOL)warning;

- (void)showCopied;

@end