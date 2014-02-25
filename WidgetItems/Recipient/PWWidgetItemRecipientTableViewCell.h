//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../../header.h"
#import "../../PWThemableTableViewCell.h"

@interface PWWidgetItemRecipientTableViewCell : PWThemableTableViewCell {
	
	BOOL _showingRemoveButton;
}

- (void)setButtonRecipient:(MFComposeRecipient *)recipient;

- (void)setButtonTarget:(id)target action:(SEL)action;
- (void)setName:(NSString *)title;
- (void)setType:(NSString *)type address:(NSString *)address;
- (void)setShowingRemoveButton:(BOOL)showing;

- (void)_configureAddButton;
- (void)_configureRemoveButton;

@end