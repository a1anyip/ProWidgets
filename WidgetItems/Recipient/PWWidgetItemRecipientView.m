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
#import "../../PWController.h"
#import "../../PWTheme.h"

@implementation PWWidgetItemRecipientView

- (instancetype)init {
	if ((self = [super init])) {
		
		_textField = [UITextField new];
		_textField.placeholder = @"Type recipients here...";
		[self addSubview:_textField];
		
		_addButton = [[UIButton buttonWithType:UIButtonTypeContactAdd] retain];
		_textField.rightView = _addButton;
		_textField.rightViewMode = UITextFieldViewModeAlways;
		
		_separator = [UIView new];
		[self addSubview:_separator];
		
		_recipientTableView = [[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		[self addSubview:_recipientTableView];
		
		_searchResultTableView = [[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_searchResultTableView.alpha = 0.0;
		[self addSubview:_searchResultTableView];
		
		// configure colors
		PWTheme *theme = [PWController activeTheme];
		self.tintColor = [theme cellTintColor];
		_textField.textColor = [theme cellInputTextColor];
		_textField.tintColor = [[theme cellInputTextColor] colorWithAlphaComponent:.3];
		[_textField setValue:[theme cellInputPlaceholderTextColor] forKeyPath:@"_placeholderLabel.textColor"];
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
	CGRect separatorRect = CGRectMake(0, textFieldHeight - 1.0, width, 1.0);
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