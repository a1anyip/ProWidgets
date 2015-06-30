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

extern NSArray *CKPreferredAddressTypes();
extern char PWWidgetItemRecipientTableViewCellRecipientKey;

#define SEARCH_TYPES 7

@implementation PWWidgetItemRecipientController

+ (NSString *)displayTextForRecipients:(NSArray *)recipients maxWidth:(CGFloat)maxWidth font:(UIFont *)font {
	
	if (font == nil || maxWidth <= 0.0 || [recipients count] == 0) return CT(@"NoRecipients");
	
	// with name
	NSUInteger maxRecipients = [recipients count];
	__block NSString *(^testWithNumberOfRecipients)(NSUInteger) = ^NSString *(NSUInteger number) {
		
		if (number > maxRecipients) return nil; // out of bounds
		
		NSMutableArray *names = [NSMutableArray array];
		NSUInteger numberOfMoreRecipients = maxRecipients - number;
		
		for (NSUInteger i = 0; i < number; i++) {
			MFComposeRecipient *recipient = recipients[i];
			NSString *name = recipient.compositeName;
			if (name == nil) name = recipient.address;
			if (name == nil) name = @"";
			[names addObject:name];
		}
		
		NSString *nameText = [names componentsJoinedByString:@", "];
		NSString *moreRecipients = numberOfMoreRecipients == 0 ? @"" : [NSString stringWithFormat:CT(@"RecipientMore"), (int)numberOfMoreRecipients];
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
		NSUInteger count = [recipients count];
		return [NSString stringWithFormat:(count == 1 ? CT(@"Recipient") : CT(@"Recipients")), (int)count];
	} else {
		return resultWithName;
	}
}

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWWidgetItemRecipientControllerDelegate>)delegate recipients:(NSArray *)recipients type:(PWWidgetItemRecipientType)type forWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		
		self.title = title;
		self.delegate = delegate;
		self.recipients = recipients;
		self.type = type;
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = YES;
		self.shouldMaximizeContentHeight = YES;
		
		// setup runtime variables
		_recipients = [NSMutableArray new];
		
		// retrieve the bundle identifier for recent contacts
		NSString *recentsBundleIdentifier = nil;
		if (type == PWWidgetItemRecipientTypeMessageContact) {
			recentsBundleIdentifier = @"";
		} else if (type == PWWidgetItemRecipientTypeMailContact) {
			recentsBundleIdentifier = @"";
		}
		
		// setup search manager and results model
		if (type == PWWidgetItemRecipientTypeMessageContact) {
			
			NSUInteger propertyCount = 0;
			
			NSArray *_properties = CKPreferredAddressTypes(); // an array containing NSNumber
			
			// to support searching iMessage emails
			_properties = [[_properties mutableCopy] autorelease];
			[(NSMutableArray *)_properties addObject:@(kABPersonEmailProperty)];
			
			NSInteger *properties = malloc(sizeof(NSInteger) * [_properties count]);
			
			for (NSNumber *property in _properties) {
				NSInteger propertyInt = [property integerValue];
				properties[propertyCount++] = propertyInt;
			}
			
			_searchManager = [[MFContactsSearchManager alloc] initWithAddressBook:NULL properties:properties propertyCount:propertyCount recentsBundleIdentifier:@"com.apple.MobileSMS"];
			
			_searchResultsModel = [[MFContactsSearchResultsModel alloc] initWithFavorMobileNumbers:YES];
			
			free(properties);
			
		} else if (type == PWWidgetItemRecipientTypeMailContact) {
			
			NSInteger property = (NSInteger)kABPersonEmailProperty;
			NSInteger *properties = &property;
			
			_searchManager = [[MFContactsSearchManager alloc] initWithAddressBook:NULL properties:properties propertyCount:1 recentsBundleIdentifier:@"com.apple.mobilemail"];
			
			_searchResultsModel = [[MFContactsSearchResultsModel alloc] initWithResultTypeSortOrderComparator:nil resultTypePriorityComparator:nil favorMobileNumbers:NO];
		}
		
		// the following line is important and cannot be changed
		[_searchManager setSearchTypes:SEARCH_TYPES]; // fixed
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

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self resetState];
}

- (void)configureFirstResponder {
	[self.recipientView.textField becomeFirstResponder];
}

- (NSString *)displayTextInMaxWidth:(CGFloat)maxWidth font:(UIFont *)font {
	return [self.class displayTextForRecipients:self.recipients maxWidth:maxWidth font:font];
}

- (void)resetState {
	
	[self cancelSearch];
	
	UITextField *textField = self.recipientView.textField;
	UITableView *recipientTableView = self.recipientView.recipientTableView;
	UITableView *searchResultTableView = self.recipientView.searchResultTableView;
	
	textField.text = @""; // clear text
	
	recipientTableView.hidden = NO;
	searchResultTableView.hidden = YES;
	
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

- (void)cancelSearch {
	if (_currentTaskID != nil) {
		[_searchManager cancelTaskWithID:_currentTaskID];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		RELEASE(_currentTaskID)
	}
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
	
	[_searchResults release];
	_searchResults = [results retain];
	
	UITableView *recipientTableView = self.recipientView.recipientTableView;
	UITableView *searchResultTableView = self.recipientView.searchResultTableView;
	
	if (results == nil) {
		recipientTableView.hidden = NO;
		searchResultTableView.hidden = YES;
	} else {
		recipientTableView.hidden = YES;
		searchResultTableView.hidden = NO;
		[searchResultTableView reloadData];
	}
	
	// scroll to top
	[searchResultTableView setContentOffset:CGPointZero animated:NO];
}

- (void)beganNetworkActivity {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)endedNetworkActivity {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)consumeSearchResults:(id)results type:(NSInteger)type taskID:(NSNumber *)taskID {
	LOG(@"consumeSearchResults: %@ / type: %d / taskID: %@", results, (int)type, taskID);
	if (_currentTaskID != nil && [taskID isEqual:_currentTaskID]) {
		[_searchResultsModel addResults:results ofType:type];
	}
}

- (void)finishedSearchingForType:(NSInteger)type {
	
	// ignore all other types
	if (type != 1 && type != 2 && type != 4) return;
	
	[_searchResultsModel processAddedResultsOfType:type completion:^(NSArray *results) {
		dispatch_async(dispatch_get_main_queue(), ^{
			LOG(@"finishedSearchingForType: (%d) %@", (int)type, results);
			_pendingSearchTypes = MAX(0, _pendingSearchTypes - type);
			if (_pendingSearchTypes == 0) {
				[self updateSearchResults:results];
			}
		});
	}];
}

- (void)finishedTaskWithID:(NSNumber *)taskID {
	if (_currentTaskID != nil && [taskID isEqual:_currentTaskID]) {
		RELEASE(_currentTaskID)
	}
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
	[self cancelSearch];
	[_searchResultsModel reset];
	[_searchResultsModel setEnteredRecipients:self.recipients];
	_pendingSearchTypes = SEARCH_TYPES; // 1, 2, 4
	_currentTaskID = [[_searchManager searchForText:text consumer:self] copy];
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
	if (name == nil) name = recipient.placeholderName;
	NSString *type = recipient.label;
	NSString *address = recipient.address;
	[cell setName:name];
	[cell setType:type address:address];
	[cell setButtonRecipient:recipient];
	
	return cell;
}

- (void)removeButtonPressed:(UIButton *)sender {
	if (sender != nil) {
		MFComposeRecipient *recipient = objc_getAssociatedObject(sender, &PWWidgetItemRecipientTableViewCellRecipientKey);
		if (recipient != nil) {
			[self removeRecipient:recipient];
		}
	}
}

- (void)dealloc {
	_delegate = nil;
	[self cancelSearch];
	RELEASE(_currentTaskID)
	RELEASE(_recipients)
	RELEASE(_searchResults)
	RELEASE(_searchManager)
	RELEASE(_searchResultsModel)
	[super dealloc];
}

@end