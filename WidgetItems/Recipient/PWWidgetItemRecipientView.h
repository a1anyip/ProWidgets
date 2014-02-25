//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../item.h"

@interface PWWidgetItemRecipientView : UIView {
	
	UITextField *_textField;
	UIView *_separator;
	UIButton *_addButton;
	
	PWThemableTableView *_recipientTableView;
	PWThemableTableView *_searchResultTableView;
}

@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, readonly) UIView *separator;
@property(nonatomic, readonly) UIButton *addButton;
@property(nonatomic, readonly) UITableView *recipientTableView;
@property(nonatomic, readonly) UITableView *searchResultTableView;

- (void)setDelegate:(id<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>)delegate;

@end