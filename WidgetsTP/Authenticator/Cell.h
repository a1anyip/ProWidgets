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
	UIButton *_reloadBtn;
}

- (void)setName:(NSString *)name issuer:(NSString *)issuer;
- (void)setCode:(NSString *)code;
- (void)setWarning:(BOOL)warning;
- (void)setReloadBtnHidden:(BOOL)hidden;
- (void)setReloadBtnEnabled:(BOOL)enabled;
- (void)setReloadBtnTarget:(id)target action:(SEL)action;
- (void)setReloadBtnRecordIndex:(NSUInteger)index;

- (void)showCopied;

@end