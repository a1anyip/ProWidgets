//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemRecipientController.h"
#import "PWWidgetItemRecipientTableViewCell.h"

extern char PWWidgetItemRecipientTableViewCellRecipientKey;

@implementation PWWidgetItemRecipientController

+ (NSString *)displayTextForRecipients:(NSArray *)recipients maxWidth:(CGFloat)maxWidth font:(UIFont *)font {
	
	if (font == nil || maxWidth <= 0.0 || [recipients count] == 0) return @"No recipients";
	
	// with name
	NSUInteger maxRecipients = [recipients count];
	__block NSString *(^testWithNumberOfRecipients)(NSUInteger) = ^NSString *(NSUInteger number) {
		
		if (number > maxRecipients) return nil; // out of bounds
		
		NSMutableArray *names = [NSMutableArray array];
		NSUInteger numberOfMoreRecipients = maxRecipients - number;
		
		for (NSUInteger i = 0; i < number; i++) {
			MFComposeRecipient *recipient = recipients[i];
			//NSString *name = recipient.shortName;
			//if (name == nil) name = recipient.compositeName;
			NSString *name = recipient.compositeName;
			if (name == nil) name = @"";
			[names addObject:name];
		}
		
		NSString *nameText = [names componentsJoinedByString:@", "];
		NSString *moreRecipients = numberOfMoreRecipients == 0 ? @"" : [NSString stringWithFormat:@" & %d more...", (int)numberOfMoreRecipients];
		NSString *result = [NSString stringWithFormat:@"%@%@", nameText, moreRecipients];
		
		CGFloat width = [result boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
													options:NSStringDrawingUsesLineFragmentOrigin
												attributes:@{ NSFontAttributeName: font }
													context:nil].size.width;
		if (width <= maxWidth) {
			NSString *nextTrial = testWithNumberOfRecipients(number + 1);
			if (nextTrial == nil) {
				return result;
			} else {
				return nextTrial;
			}
		} else {
			return nil;
		}
	};
	
	NSString *resultWithName = testWithNumberOfRecipients(1); // start from 1 recipient
	if (resultWithName == nil) {
		// only number of recipients
		return [NSString stringWithFormat:@"%d recipient%@", (int)[recipients count], ([recipients count] == 1 ? @"" : @"s")];
	} else {
		return resultWithName;
	}
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWWidgetItemRecipientControllerDelegate>)delegate recipients:(NSArray *)recipients forWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		
		_recipients = [NSMutableArray new];
		
		self.title = title;
		self.delegate = delegate;
		self.recipients = recipients;
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = YES;
		self.shouldMaximizeContentHeight = YES;
	}
	return self;
}

- (void)loadView {
	PWWidgetItemRecipientView *view = [[[PWWidgetItemRecipientView alloc] initWithTheme:self.theme] autorelease];
	[view setDelegate:self];
	self.view = view;
}

- (PWWidgetItemRecipientView *)recipientView {
	return (PWWidgetItemRecipientView *)self.view;
}

- (void)configureFirstResponder {
	[self.recipientView.textField becomeFirstResponder];
}

- (NSString *)displayTextInMaxWidth:(CGFloat)maxWidth font:(UIFont *)font {
	return [self.class displayTextForRecipients:self.recipients maxWidth:maxWidth font:font];
}

- (void)resetState {
	
	UITextField *textField = self.recipientView.textField;
	UITableView *recipientTableView = self.recipientView.recipientTableView;
	UITableView *searchResultTableView = self.recipientView.searchResultTableView;
	
	textField.text = @""; // clear text
	
	recipientTableView.alpha = 1.0;
	searchResultTableView.alpha = 0.0;
	
	[_searchResults release], _searchResults = nil;
	[recipientTableView reloadData];
	[searchResultTableView reloadData];
	
	// scroll to bottom
	if ([_recipients count] > 0) {
		NSIndexPath *lastRow = [NSIndexPath indexPathForRow:[_recipients count] - 1 inSection:0];
		[recipientTableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
	
	// scroll to top
	[searchResultTableView setContentOffset:CGPointZero animated:NO];
}

- (BOOL)recipientExists:(MFComposeRecipient *)recipient {
	return [_recipients containsObject:recipient];
}

- (NSArray *)recipients {
	return [[_recipients copy] autorelease];
}

- (void)setRecipients:(NSArray *)recipients {
	if (_recipients != nil && [_recipients isEqual:recipients]) {
		return;
	}
	[_recipients release];
	_recipients = [recipients mutableCopy];
	[self updateRecipients];
}

- (void)addRecipient:(MFComposeRecipient *)recipient {
	if ([self recipientExists:recipient]) return [self updateRecipients];
	[_recipients addObject:recipient];
	[self updateRecipients];
}

- (void)removeRecipient:(MFComposeRecipient *)recipient {
	if (![self recipientExists:recipient]) return [self updateRecipients];
	[_recipients removeObject:recipient];
	[self updateRecipients];
}

- (void)updateRecipients {
	
	self.recipientView.textField.text = @""; // clear search string
	
	UITableView *recipientTableView = self.recipientView.recipientTableView;
	[self updateSearchResults:nil];
	[recipientTableView reloadData];
	applyFadeTransition(recipientTableView, .1);
	
	// scroll to bottom
	if ([_recipients count] > 0) {
		NSIndexPath *lastRow = [NSIndexPath indexPathForRow:[_recipients count] - 1 inSection:0];
		[recipientTableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
	
	// notify delegate
	if (_delegate != nil) {
		[_delegate recipientsChanged:_recipients];
	}
}

- (void)updateSearchResults:(NSArray *)results {
	
	CGFloat duration = .15;
	
	[_searchResults release];
	_searchResults = [results retain];
	
	UITableView *recipientTableView = self.recipientView.recipientTableView;
	UITableView *searchResultTableView = self.recipientView.searchResultTableView;
	
	if (results == nil) {
		[UIView animateWithDuration:duration animations:^{
			recipientTableView.alpha = 1.0;
			searchResultTableView.alpha = 0.0;
		}];
	} else {
		[UIView animateWithDuration:duration animations:^{
			searchResultTableView.alpha = 1.0;
			recipientTableView.alpha = 0.0;
		}];
		
		[searchResultTableView reloadData];
	}
	
	// scroll to top
	[searchResultTableView setContentOffset:CGPointZero animated:NO];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self resetState];
}

/**
 * UITextFieldDelegate
 **/

- (void)textFieldDidChange:(UITextField *)textField {
	
	NSString *text = textField.text;
	
	if (text == nil || [text length] == 0) {
		[self updateSearchResults:nil];
		return;
	}
	
	// perform searching
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
		NSArray *results = [generator resultsForText:text];
		if (results == nil) results = [NSArray array];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updateSearchResults:results];
		});
	});
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSString *text = textField.text;
	CKRecipientGenerator *generator = [CKRecipientGenerator sharedRecipientGenerator];
	id recipient = [generator recipientWithAddress:text];
	[self addRecipient:recipient];
	return YES;
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (tableView == self.recipientView.searchResultTableView) {
		unsigned int row = [indexPath row];
		MFComposeRecipient *recipient = _searchResults[row];
		if (recipient != nil && ![_recipients containsObject:recipient]) {
			[_recipients addObject:recipient];
			[self updateRecipients];
		}
	}
	
	// deselect the cell
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
	if (tableView == self.recipientView.recipientTableView) {
		return [_recipients count];
	} else {
		return [_searchResults count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (tableView == self.recipientView.recipientTableView) {
		return [NSString stringWithFormat:@"Recipients (%d)", (int)[_recipients count]];
	} else {
		return @"Search Results";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	BOOL isRecipients = tableView == self.recipientView.recipientTableView;
	NSString *identifier = @"PWWidgetItemRecipientTableViewCell";
	PWWidgetItemRecipientTableViewCell *cell = (PWWidgetItemRecipientTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		
		cell = [[[PWWidgetItemRecipientTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier theme:self.theme] autorelease];
		
		if (isRecipients) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		if (isRecipients) {
			[cell setShowingRemoveButton:YES];
			[cell setButtonTarget:self action:@selector(removeButtonPressed:)];
		} else {
			[cell setShowingRemoveButton:NO];
		}
	}
	
	MFComposeRecipient *recipient = isRecipients ? _recipients[row] : _searchResults[row];
	NSString *name = recipient.compositeName;
	NSString *address = recipient.address;
	[cell setName:name];
	[cell setType:@"mobile" address:address];
	[cell setButtonRecipient:recipient];
	
	return cell;
}

- (void)removeButtonPressed:(UIButton *)sender {
	LOG(@"removeButtonPressed: %@", sender);
	if (sender != nil) {
		MFComposeRecipient *recipient = objc_getAssociatedObject(sender, &PWWidgetItemRecipientTableViewCellRecipientKey);
		if (recipient != nil) {
			[self removeRecipient:recipient];
		}
	}
}

- (void)dealloc {
	RELEASE(_recipients)
	RELEASE(_searchResults)
	[super dealloc];
}

@end