//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipientView.h"
#import "PWWidgetItemRecipientController.h"
#import "../../PWThemableTableView.h"
#import "../../PWThemableTextField.h"
#import "../../PWController.h"
#import "../../PWTheme.h"

@implementation PWWidgetItemRecipientView

- (instancetype)initWithTheme:(PWTheme *)theme {
	if ((self = [super init])) {
		
		_textField = [[PWThemableTextField alloc] initWithFrame:CGRectZero theme:theme];
		_textField.placeholder = @"Type recipients here...";
		[self addSubview:_textField];
		
		_addButton = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
		_textField.rightView = _addButton;
		_textField.rightViewMode = UITextFieldViewModeAlways;
		
		_separator = [UIView new];
		[self addSubview:_separator];
		
		_recipientTableView = [[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:theme];
		[self addSubview:_recipientTableView];
		
		_searchResultTableView = [[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:theme];
		_searchResultTableView.alpha = 0.0;
		[self addSubview:_searchResultTableView];
		
		// configure colors
		self.tintColor = [theme tintColor];
		_separator.backgroundColor = [theme cellSeparatorColor];
	}
	return self;
}

- (void)setDelegate:(id<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>)delegate {
	[_textField removeTarget:nil action:NULL forControlEvents:UIControlEventEditingChanged];
	[_textField addTarget:delegate action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
	_textField.delegate = delegate;
	_recipientTableView.delegate = delegate;
	_recipientTableView.dataSource = delegate;
	_searchResultTableView.delegate = delegate;
	_searchResultTableView.dataSource = delegate;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat textFieldHeight = 44.0;
	
	CGRect textFieldRect = CGRectMake(PWDefaultItemCellPadding, 0, width - PWDefaultItemCellPadding * 2, textFieldHeight);
	CGRect separatorRect = CGRectMake(0, textFieldHeight - .5, width, .5);
	CGRect tableViewRect = CGRectMake(0, textFieldHeight, width, height - textFieldHeight);
	
	_textField.frame = textFieldRect;
	_separator.frame = separatorRect;
	_recipientTableView.frame = tableViewRect;
	_searchResultTableView.frame = tableViewRect;
}

- (void)dealloc {
	DEALLOCLOG;
	
	[self setDelegate:nil];
	
	RELEASE_VIEW(_textField)
	RELEASE_VIEW(_addButton)
	RELEASE_VIEW(_recipientTableView)
	RELEASE_VIEW(_searchResultTableView)
	
	[super dealloc];
}

@end