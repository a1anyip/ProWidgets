//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWContentListViewController.h"
#import "PWThemableTableView.h"
#import "PWThemableTableViewCell.h"
#import "PWController.h"
#import "PWWidget.h"
#import "PWTheme.h"

@implementation PWContentListViewController

- (instancetype)initWithTitle:(NSString *)title delegate:(id<PWContentListViewControllerDelegate>)delegate {
	if ((self = [super init])) {
		
		self.title = title;
		_delegate = delegate;
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		
		// default settings
		self.requiresKeyboard = NO;
		self.shouldMaximizeContentHeight = YES;
	}
	return self;
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

//////////////////////////////////////////////////////////////////////

- (void)reload {
	[self.tableView reloadData];
	[[PWController activeWidget] resizeWidgetAnimated:YES forContentViewController:self];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	// scroll to the first selected row
	NSUInteger index = 0;
	NSInteger noneIndex = [_delegate noneIndex];
	NSArray *selectedValues = [_delegate selectedValues];
	if (selectedValues != nil && [selectedValues count] > 0) {
		id firstValue = selectedValues[0];
		index = [[_delegate listItemValues] indexOfObject:firstValue];
	} else if (noneIndex >= 0) {
		index = noneIndex;
	}
	
	if (index != NSNotFound && index < [[_delegate listItemValues] count]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[PWController activeTheme] heightOfCellOfType:PWWidgetCellTypeNormal forOrientation:[PWController currentOrientation]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// extract row and index from index path
	NSUInteger row = [indexPath row];
	NSNumber *index = [NSNumber numberWithUnsignedInteger:row];
	
	// deselect the row
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// retrieve the none index
	BOOL hasNoneRow = NO;
	BOOL isNoneRow = NO;
	NSInteger noneIndex = -1;
	NSIndexPath *noneIndexPath = nil;
	
	if ([_delegate respondsToSelector:@selector(noneIndex)])
		noneIndex = MAX(-1, [_delegate noneIndex]);
	
	if (noneIndex >= 0) {
		if (row == noneIndex) isNoneRow = YES;
		hasNoneRow = YES;
		noneIndexPath = [NSIndexPath indexPathForRow:noneIndex inSection:0];
	}
	
	// retrieve max number of selection
	NSUInteger maxSelection = 1;
	if ([_delegate respondsToSelector:@selector(maximumNumberOfSelection)])
		maxSelection = MAX(1, [_delegate maximumNumberOfSelection]);
	
	// retrieve selected indices
	NSArray *valueList = [_delegate listItemValues];
	NSArray *selectedValues = [[_delegate selectedValues] retain];
	NSMutableArray *selectedIndices = [NSMutableArray new];
	
	// convert selected values to selected indices
	for (id value in selectedValues) {
		NSUInteger indexOfValue = [valueList indexOfObject:value];
		if (indexOfValue != NSNotFound) {
			[selectedIndices addObject:@(indexOfValue)];
		}
	}
	
	// states
	BOOL shouldPerformUpdate = YES;
	BOOL originalState = [selectedIndices containsObject:index];
	BOOL newState = !originalState;
	
	if (isNoneRow && newState) {
		
		for (NSNumber *selectedIndex in selectedIndices) {
			
			NSUInteger selectedRow = [selectedIndex unsignedIntegerValue];
			NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
			
			// remove the check mark in previously selected cell
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
			selectedCell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		[selectedIndices removeAllObjects];
		[selectedIndices addObject:@(noneIndex)];
	}
	
	if (hasNoneRow) {
		
		UITableViewCell *noneCell = [tableView cellForRowAtIndexPath:noneIndexPath];
		
		// if any of other row is selected, deselect none row
		if (!isNoneRow && newState) {
			
			// just in case, normally none index does not exist in selected value list (filtered)
			if ([selectedIndices containsObject:@(noneIndex)]) {
				// deselect none row
				[selectedIndices removeObject:@(noneIndex)];
			}
			
			// remove check mark
			noneCell.accessoryType = UITableViewCellAccessoryNone;
		}
		
		// if the last selected row is deselected, select none row
		if (!isNoneRow && !newState && [selectedIndices count] == 1) {
			// deselect the current row
			[selectedIndices removeAllObjects];
			// select none row
			//[selectedIndices addObject:@(noneIndex)];
			// add check mark
			noneCell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	
	// exceed max number of selection
	if (!isNoneRow && newState && [selectedIndices count] == maxSelection) {
		
		if (maxSelection == 1) {
			
			NSNumber *selectedIndex = selectedIndices[0];
			NSUInteger selectedRow = [selectedIndex unsignedIntegerValue];
			NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
			
			// remove the check mark in previously selected cell
			UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
			selectedCell.accessoryType = UITableViewCellAccessoryNone;
			
			// remove its index from selectedIndices
			[selectedIndices removeObject:selectedIndex];
			
		} else {
			// notify delegate
			if ([_delegate respondsToSelector:@selector(selectedTooManyItems)])
				[_delegate selectedTooManyItems];
			
			return;
		}
	}
	
	// trying to deselect all rows (1 -> 0)
	if (!newState && [selectedIndices count] == 1) {
		if (maxSelection == 1) { // select itself once again (no change in selected indices)
								 // bu still notify delegate to pop list view controller
			shouldPerformUpdate = NO;
		} else {
			return;
		}
	}
	
	if (shouldPerformUpdate) {
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		// update accessory type
		cell.accessoryType = newState ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		
		// update selected indices
		if (newState)
			[selectedIndices addObject:index];
		else
			[selectedIndices removeObject:index];
	}
	
	// retrieve selected items according to selected indices
	NSMutableArray *newSelectedValues = [NSMutableArray new];
	
	if (!isNoneRow) {
		
		NSArray *valueList = [_delegate listItemValues];
		NSUInteger valueListSize = [valueList count];
		
		// sort the selected indices
		NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
		[selectedIndices sortUsingDescriptors:@[descriptor]];
		
		for (NSNumber *selectedIndex in selectedIndices) {
			NSUInteger i = [selectedIndex unsignedIntegerValue];
			if (i >= valueListSize) continue;
			[newSelectedValues addObject:valueList[i]];
		}
	}
	
	// callback to delegate
	[_delegate selectedValuesChanged:newSelectedValues oldValues:selectedValues];
	
	[newSelectedValues release];
	[selectedValues release];
	[selectedIndices release];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger count = [[_delegate listItemTitles] count];
	LOG(@"PWContentListViewController: number of items: %d", (int)count);
	
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//LOG(@"PWContentListViewController: cellForRowAtIndexPath: %@", indexPath);
	
	unsigned int row = [indexPath row];
	NSString *title = [_delegate listItemTitles][row];
	
	NSString *cellIdentifier = @"PWContentListViewControllerCell";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	//LOG(@"PWContentListViewController: cell for row %u (title: %@) (cell: %@)", row, title, cell);
	
	if (!cell) {
		cell = [[[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	cell.textLabel.text = title;
	
	BOOL selected = NO;
	NSArray *listValues = [_delegate listItemValues];
	NSArray *selectedValues = [_delegate selectedValues];
	if (listValues != nil && [listValues count] > row) {
		id value = [listValues objectAtIndex:row];
		selected = [selectedValues containsObject:value];
	}
	
	// row at none index
	if ([selectedValues count] == 0 && row == _delegate.noneIndex) {
		selected = YES;
	}
	
	if (selected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

//////////////////////////////////////////////////////////////////////
/*
- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation {
	CGFloat cellHeight = [[PWController activeTheme] heightOfCellOfType:PWWidgetCellTypeNormal forOrientation:orientation];
	return cellHeight * [[_delegate listItemTitles] count];
}
*/

- (void)dealloc {
	_delegate = nil;
	[super dealloc];
}

@end