//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipient.h"

@implementation PWWidgetItemRecipient

+ (Class)valueClass {
	return [NSArray class];
}

+ (id)defaultValue {
	return [NSArray array];
}

+ (Class)cellClass {
	return [PWWidgetItemRecipientCell class];
}

- (CGFloat)overrideHeight {
	return _viewHeight;
}

- (instancetype)init {
	if ((self = [super init])) {
		
		_viewHeight = [MFComposeRecipientView preferredHeight];
		
		PWContainerView *containerView = [PWController sharedInstance].containerView;
		
		_searchResultView = [UITableView new];
		_searchResultView.hidden = YES;
		_searchResultView.frame = CGRectMake(0, 88, 320, 150);
		_searchResultView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_searchResultView.delegate = self;
		_searchResultView.dataSource = self;
		
		[containerView addSubview:_searchResultView];
	}
	return self;
}

- (id)composeRecipientView:(MFComposeRecipientView *)view composeRecipientForRecord:(void *)record identifier:(int)identifier {
	METHODLOG;
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	return [generator recipientWithRecord:record property:0 identifier:identifier];
}

- (id)composeRecipientView:(MFComposeRecipientView *)view composeRecipientForAddress:(NSString *)address {
	METHODLOG;
	LOG(@"Address: <%@>", address);
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	return [generator recipientWithAddress:address];
}

- (void)composeRecipientViewDidFinishPickingRecipient:(MFComposeRecipientView *)view {
	METHODLOG;
}

- (void)composeRecipientViewRequestAddRecipient:(MFComposeRecipientView *)view {
	METHODLOG;
}

- (void)composeRecipientView:(MFComposeRecipientView *)view showPersonCardForAtom:(id)arg2 {
	METHODLOG;
	LOG(@"Atom: <%@>", arg2);
}

- (void)composeRecipientView:(MFComposeRecipientView *)view textDidChange:(NSString *)text {
	METHODLOG;
	LOG(@"Text: <%@>", text);
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	NSArray *results = [generator resultsForText:text];
	LOG(@"Search results: %@", results);
	
	[_searchResult release];
	_searchResult = [results retain];
	[_searchResultView reloadData];
}

- (void)composeRecipientView:(MFComposeRecipientView *)view didChangeSize:(CGSize)size {
	METHODLOG;
	//BOOL isFirstResponder =
	BOOL changed = size.height != _viewHeight;
	if (changed) {
		_viewHeight = size.height;
		[self.itemViewController reloadCellOfItem:self];
		//[self becomeFirstResponder]; // re-focus this cell
	}
}

- (void)composeRecipientView:(MFComposeRecipientView *)view didAddRecipient:(MFComposeRecipient *)recipient {
	METHODLOG;
	LOG(@"Did add: <%@>", recipient);
	/*
	 0 blue (iMessage)
	 1<<0 red
	 1<<1 green (SMS)
	 1<<2 blue + loading icon
	 */
	//[view setAddressAtomPresentationOptions:0 forRecipient:recipient];
	
	//[(NSMutableArray *)self.value addObject:recipient];
	[self setItemValue:view.recipients];
}

- (void)composeRecipientView:(MFComposeRecipientView *)view didFinishEnteringAddress:(NSString *)address {
	METHODLOG;
	LOG(@"Finish entering: <%@>", address);
	
	// clear text
	[view clearText];
	
	// add recipient
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	id recipient = [generator recipientWithAddress:address];
	[view addRecipient:recipient];
}

- (void)composeRecipientView:(MFComposeRecipientView *)view didRemoveRecipient:(MFComposeRecipient *)recipient {
	METHODLOG;
	LOG(@"Did remove: <%@>", recipient);
	//[(NSMutableArray *)self.value removeObject:recipient];
	[self setItemValue:view.recipients];
}


//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	id recipient = _searchResult[row];
	return [MFRecipientTableViewCell heightWithRecipient:recipient width:320.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// deselect the row
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count = [_searchResult count];
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//LOG(@"PWContentListViewController: cellForRowAtIndexPath: %@", indexPath);
	
	unsigned int row = [indexPath row];
	
	NSString *cellIdentifier = @"PWWidgetItemRecipientCell";
	MFRecipientTableViewCell *cell = (MFRecipientTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	LOG(@"PWWidgetItemRecipient: cell for row %u (cell: %@)", row, cell);
	
	if (!cell) {
		cell = [[[MFRecipientTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.backgroundColor = [UIColor clearColor];
	}
	
	id recipient = _searchResult[row];
	[cell setRecipient:recipient];
	
	return cell;
}


@end

@implementation PWWidgetItemRecipientCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleNone;
}

//////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		_recipientView = [MFComposeRecipientView new];
		_recipientView.backgroundColor = [UIColor clearColor];
		_recipientView.separatorHidden = YES;
		[_recipientView setLabel:@"To:"];
		[self.contentView addSubview:_recipientView];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_recipientView.frame = self.contentView.bounds;
}

- (void)updateItem:(PWWidgetItem *)item {
	_recipientView.delegate = (PWWidgetItemRecipient *)item;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	[_recipientView setLabel:title];
}

- (void)setValue:(NSArray *)values {
	
	_recipientView.delegate = nil; // to prevent delegate from keeping receiving didAddRecipient
	_recipientView.addresses = nil; // clear all records
	
	NSUInteger i = 0;
	for (MFComposeRecipient *recipient in values) {
		[_recipientView addRecipient:recipient index:i++ animate:NO];
	}
	
	_recipientView.delegate = self.item;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitleTextColor:(UIColor *)color {
	if (_recipientView != nil) {
		UILabel *label = *(UILabel **)instanceVar(_recipientView, "_labelView");
		if (label != NULL) {
			label.textColor = color;
		}
	}
}

- (void)setValueTextColor:(UIColor *)color {
	self.detailTextLabel.textColor = color;
}

- (void)setInputTextColor:(UIColor *)color {
	
}

- (BOOL)contentCanBecomeFirstResponder {
	return YES;
}

- (void)contentSetFirstResponder {
	if (_recipientView.superview != nil)
		[_recipientView becomeFirstResponder];
}

- (void)contentResignFirstResponder {
	if (_recipientView.superview != nil)
		[_recipientView resignFirstResponder];
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	RELEASE_VIEW(_recipientView)
	[super dealloc];
}

@end