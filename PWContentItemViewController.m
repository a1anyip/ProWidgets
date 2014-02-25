//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWContentItemViewController.h"
#import "PWController.h"
#import "PWWidget.h"
#import "PWWidgetPlistParser.h"
#import "PWWidgetItem.h"
#import "PWWidgetItemCell.h"
#import "PWThemableTableView.h"
#import "PWTheme.h"

static NSNumberFormatter *numberFormatter = nil;

@implementation PWContentItemViewController

+ (NSString *)itemValueChangedEventName {
	return @"PWContentItemViewControllerItemValueChangedEvent";
}

+ (NSString *)submitEventName {
	return @"PWContentItemViewControllerSubmitEvent";
}

- (instancetype)init {
	if ((self = [super _init])) {
		
		if (numberFormatter == nil) {
			numberFormatter = [NSNumberFormatter new];
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		}
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		
		// set delegate
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		
		// default settings
		self.requiresKeyboard = YES;
		self.shouldMaximizeContentHeight = NO;
		
		_items = [NSMutableArray new];
		
		// pass to developers to load their own stuff
		[self load];
	}
	return self;
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (BOOL)loadPlist:(NSString *)filename {
	PWWidget *widget = [PWController activeWidget];
	NSString *path = [widget _pathOfPlist:filename];
	NSDictionary *dict = [widget _loadPlistAtPath:path];
	if (dict == nil) return NO;
	[PWWidgetPlistParser parse:dict forContentItemViewController:self];
	return YES;
}

- (void)setItemValueChangedEventHandler:(id)target selector:(SEL)selector {
	[self setHandlerForEvent:[self.class itemValueChangedEventName] block:^(NSDictionary *dict) {
		if (target != nil && selector != NULL) {
			PWWidgetItem *item = dict[@"item"];
			id oldValue = dict[@"oldValue"];
			[target performSelector:selector withObject:item withObject:oldValue];
		}
	}];
}

- (void)setItemValueChangedEventBlockHandler:(void(^)(PWWidgetItem *, id))block {
	
	[_wrappedItemValueChangedEventBlockHandler release];
	_wrappedItemValueChangedEventBlockHandler = [block copy];
	
	[self setHandlerForEvent:[self.class itemValueChangedEventName] block:^(NSDictionary *dict) {
		if (_wrappedItemValueChangedEventBlockHandler != nil) {
			PWWidgetItem *item = dict[@"item"];
			id oldValue = dict[@"oldValue"];
			_wrappedItemValueChangedEventBlockHandler(item, oldValue);
		}
	}];
}

- (void)setSubmitEventHandler:(id)target selector:(SEL)selector {
	[self setHandlerForEvent:[self.class submitEventName] target:target selector:selector];
}

- (void)setSubmitEventBlockHandler:(void(^)(id))block {
	[self setHandlerForEvent:[self.class submitEventName] block:block];
}

- (void)reload {
	[self.tableView reloadData];
}

- (void)configureFirstResponder {
	
	UIApplication *app = [UIApplication sharedApplication];
	UIWindow *keyWindow = app.keyWindow;
	id firstResponder = [keyWindow firstResponder];
	LOG(@"PWContentItemViewController: configureFirstResponder: existing first responder: %@ in key window %@", firstResponder, keyWindow);
	if (firstResponder != nil) {
		LOG(@"PWContentItemViewController: configureFirstResponder: first responder is not nil.");
		//_lastFirstResponder = nil;
		//return;
	}
	
	LOG(@"PWContentItemViewController: configureFirstResponder: _lastFirstResponder: %@", _lastFirstResponder);
	
	if (_lastFirstResponder != nil && [_items containsObject:_lastFirstResponder]) {
		[self requestFirstResponder:_lastFirstResponder];
		return;
	}
	
	NSArray *cells = [self.tableView visibleCells];
	for (PWWidgetItemCell *cell in cells) {
		if (![cell isKindOfClass:[PWWidgetItemCell class]]) continue;
		if ([cell.class contentCanBecomeFirstResponder]) {
			[cell contentSetFirstResponder];
			break;
		}
	}
}

- (void)requestFirstResponder:(PWWidgetItem *)item {
	
	LOG(@"PWContentItemViewController: requestFirstResponder: %@ <active cell: %@>", item, item.activeCell);
	
	//[self.tableView visibleCells]
	
	NSUInteger index = [self indexOfItem:item];
	if (index == NSNotFound) return;

	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	PWWidgetItemCell *cell = (PWWidgetItemCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		// the cell is visible
		_pendingFirstResponder = nil;
		if ([cell.class contentCanBecomeFirstResponder]) {
			_lastFirstResponder = item;
			[cell contentSetFirstResponder];
		}
	} else {
		// as the cell is not available yet, ask table view
		// to scroll to the cell and then immediately make it
		// become the first responder
		//NSUInteger index = [self indexOfItem:item];
		LOG(@"PWContentItemViewController: requestFirstResponder: index of item: %d", (int)index);
		_pendingFirstResponder = item;
	}
	
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)updateLastFirstResponder:(PWWidgetItem *)item {
	LOG(@"updateLastFirstResponder =====> (%@) %@ / top vc: %@", _shouldUpdateLastFirstResponder ? @"YES" : @"NO", item, [self.navigationController topViewController]);
	if (_lastFirstResponder == nil || _shouldUpdateLastFirstResponder) {
		_lastFirstResponder = item;
		return YES;
	} else {
		return NO;
	}
}

- (void)setNextResponder:(PWWidgetItem *)currentFirstResponder {
	
	NSUInteger index = [self indexOfItem:currentFirstResponder];
	
	if (index != NSNotFound) {
		
		if (index < [_items count] - 1) {
			// try to set the next responder
			for (unsigned int i = index + 1; i < [_items count]; i++) {
				
				PWWidgetItem *item = _items[i];
				Class cellClass = [item.class cellClass];
				
				if ([cellClass contentCanBecomeFirstResponder]) {
					[self requestFirstResponder:item];
					return;
				}
			}
		} else if (index == [_items count] - 1) {
			// last item, trigger send selector
			[self triggerAction];
		}
	}
	
	// resign the previous first responder
	[currentFirstResponder.activeCell contentResignFirstResponder];
}

- (void)itemValueChanged:(PWWidgetItem *)item oldValue:(id)oldValue {
	
	if (item == nil) return;
	
	NSMutableDictionary *object = [NSMutableDictionary dictionary];
	
	object[@"item"] = item;
	
	if (oldValue != nil)
		object[@"oldValue"] = oldValue;
	
	// if the item itself has a handler, trigger it first
	void(^itemHandler)(id) = item.itemValueChangedEventBlockHandler;
	if (itemHandler != nil) {
		itemHandler(oldValue);
	}
	
	// then trigger event anyway
	[self triggerEvent:[self.class itemValueChangedEventName] withObject:object];
}

- (void)reloadCellOfItem:(PWWidgetItem *)item {
	
	LOG(@"reloadCellOfItem: %@", item);
	
	NSUInteger row = [self indexOfItem:item];
	if (row != NSNotFound) {
		
		UITableView *tableView = self.tableView;
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		if (indexPath == nil) return; // just in case
		
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		CGFloat originalHeight = cell.contentView.bounds.size.height;
		CGFloat newHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
		
		if (originalHeight != newHeight) {
			LOG(@"reloadCellOfItem: cell height changed from %f to %f", originalHeight, newHeight);
			// resize widget
			[[PWController activeWidget] resizeWidgetAnimated:YES forContentViewController:self];
		}
		
		//[self reload];
		[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)triggerAction {
	
	_lastFirstResponder = nil;
	
	[[PWController sharedInstance].window endEditing:YES];
	
	// collect values from items
	if (_items == nil || [_items count] == 0) {
		return [self triggerEvent:[self.class submitEventName] withObject:nil];
	}
	
	LOG(@"PWWidget: --- Collect values from items");
	
	NSMutableDictionary *values = [NSMutableDictionary dictionary];
	
	for (PWWidgetItem *item in _items) {
		
		// retrieve key and value from the item
		NSString *key = item.key;
		id value = item.value;
		
		if (key == nil) {
			LOG(@"PWWidget --- ignored an item without key");
			continue;
		}
		
		if (value == nil) {
			LOG(@"PWWidget --- ignored an item (%@) with empty value", key);
			continue;
		}
		
		values[key] = value;
		
		LOG(@"PWWidget: --- '%@': %@", key, value);
	}
	
	[self triggerEvent:[self.class submitEventName] withObject:values];
}

//////////////////////////////////////////////////////////////////////

/**
 * Item manipulation
 **/

#define PWWidgetItemCheckBoundsReturn if (![self _checkBounds:index]) return

// set value
- (void)setValue:(id)value forItem:(PWWidgetItem *)item {
	[item setValue:value];
}

// retrieve item
- (NSArray *)items {
	return (NSArray *)_items;
}

- (PWWidgetItem *)itemWithKey:(NSString *)key {
	
	for (PWWidgetItem *item in _items) {
		if ([item.key isEqualToString:key]) return item;
	}
	
	return nil;
}

- (PWWidgetItem *)itemAtIndex:(NSUInteger)index {
	
	PWWidgetItemCheckBoundsReturn nil;
	return [_items objectAtIndex:index];
}

- (NSUInteger)indexOfItem:(PWWidgetItem *)item {
	return _items == nil || item == nil ? NSNotFound : [_items indexOfObject:item];
}

// update items
- (void)setItems:(NSArray *)items {
	
	BOOL initialSetting = _items == nil;
	_lastFirstResponder = nil;
	
	[_items release];
	_items = [items mutableCopy];
	
	[self _updateItemsShouldFillHeight];
	
	// reload item table view, if the widget is presented
	[self reload];
	
	LOG(@"PWContentItemViewController: setItems: %@", _items);
	
	// resize widget
	[[PWController activeWidget] resizeWidgetAnimated:YES forContentViewController:self];
	
	// set new first responder if the items are not set for the first time
	if (!initialSetting) {
		[self configureFirstResponder];
	}
}

// addition
- (void)addItem:(PWWidgetItem *)item {
	[self addItem:item animated:YES];
}

- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index {
	[self addItem:item atIndex:index animated:YES];
}

- (void)addItem:(PWWidgetItem *)item animated:(BOOL)animated {
	[self addItem:item atIndex:[_items count] animated:animated];
}

- (void)addItem:(PWWidgetItem *)item atIndex:(NSUInteger)index animated:(BOOL)animated {
	
	if (index > [_items count]) {
		index = [_items count];
	}
	
	// insert the item to _items array
	[_items insertObject:item atIndex:index];
	
	[self _updateItemsShouldFillHeight];
	
	// inert a row in sheet table view
	UITableView *tableView = self.tableView;
	if (animated) {
		applyFadeTransition(tableView, 0.3);
	}
	[tableView reloadData];
	
	// resize widget
	[[PWController activeWidget] resizeWidgetAnimated:animated forContentViewController:self];
	
	[self configureFirstResponder];
}

- (void)addItems:(NSArray *)items {
	[self addItems:items animated:YES];
}

- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index {
	[self addItems:items atIndex:index animated:YES];
}

- (void)addItems:(NSArray *)items animated:(BOOL)animated {
	[self addItems:items atIndex:[_items count] animated:animated];
}

- (void)addItems:(NSArray *)items atIndex:(NSUInteger)index animated:(BOOL)animated {
	
	if (index > [_items count]) {
		index = [_items count];
	}
	
	// insert the item to _items array
	NSMutableArray *indexPaths = [NSMutableArray array];
	NSUInteger i = index;
	for (PWWidgetItem *item in items) {
		[_items insertObject:item atIndex:i];
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		[indexPaths addObject:indexPath];
		i++;
	}
	
	[self _updateItemsShouldFillHeight];
	
	UITableView *tableView = self.tableView;
	if (animated) {
		applyFadeTransition(tableView, 0.3);
	}
	[tableView reloadData];
	
	// resize widget
	[[PWController activeWidget] resizeWidgetAnimated:animated forContentViewController:self];
	
	[self configureFirstResponder];
}

- (PWWidgetItem *)addItemNamed:(NSString *)name {
	return [self addItemNamed:name animated:NO];
}

- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index {
	return [self addItemNamed:name atIndex:index animated:NO];
}

- (PWWidgetItem *)addItemNamed:(NSString *)name animated:(BOOL)animated {
	return [self addItemNamed:name atIndex:[_items count] animated:animated];
}

- (PWWidgetItem *)addItemNamed:(NSString *)name atIndex:(NSUInteger)index animated:(BOOL)animated {
	PWWidgetItem *item = [PWWidgetItem createItemNamed:name forItemViewController:self];
	[self addItem:item atIndex:index animated:animated];
	return item;
}

// removal
- (void)removeItem:(PWWidgetItem *)item {
	[self removeItem:item animated:NO];
}

- (void)removeItem:(PWWidgetItem *)item animated:(BOOL)animated {
	
	NSUInteger index = [_items indexOfObject:item];
	
	if (index == NSNotFound) {
		LOG(@"PWContentItemViewController: Unable to remove item (%@). Reason: Item not found.", item);
		return;
	}
	
	[self removeItemAtIndex:index animated:animated];
}

- (void)removeItemAtIndex:(NSUInteger)index {
	[self removeItemAtIndex:index animated:NO];
}

- (void)removeItemAtIndex:(NSUInteger)index animated:(BOOL)animated {
	
	LOG(@"PWContentItemViewController: removeItemAtIndex: %lu", (unsigned long)index);
	
	PWWidgetItemCheckBoundsReturn;
	
	PWWidgetItem *item = [self itemAtIndex:index];
	BOOL isFirstResponder = item == _lastFirstResponder;
	
	// resign first responder
	[item resignFirstResponder];
	
	// remove the item at given index from _items array
	[_items removeObjectAtIndex:index];
	
	[self _updateItemsShouldFillHeight];
	
	// inert a row in sheet table view
	UITableView *tableView = self.tableView;
	if (animated) {
		applyFadeTransition(tableView, 0.3);
	}
	[tableView reloadData];
	
	// resize widget
	[[PWController activeWidget] resizeWidgetAnimated:animated forContentViewController:self];
	
	// first responder lost
	if (isFirstResponder) {
		_lastFirstResponder = nil;
	}
	
	[self configureFirstResponder];
}

// private method: check bounds
- (BOOL)_checkBounds:(NSUInteger)index {
	
	if (_items == nil || [_items count] <= index) {
		LOG(@"PWContentItemViewController: Unable to query item. Reason: Index %lu beyond bounds or empty items", (unsigned long)index);
		return NO;
	}
	
	return YES;
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//LOG(@"====== heightForRowAtIndexPath <_fillHeight: %f>", _fillHeight);
	
	unsigned int row = [indexPath row];
	PWWidgetItem *item = [self itemAtIndex:row];
	
	if (item.shouldFillHeight && _fillHeight > 0.0) {
		if (item.minimumFillHeight > 0.0 && _fillHeight < item.minimumFillHeight) {
			return item.minimumFillHeight;
		} else {
			return _fillHeight;
		}
	} else {
		return [item cellHeightForOrientation:[PWController currentOrientation]];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	PWWidgetItem *item = [self itemAtIndex:row];
	
	// ensure the item is selectable
	if (![item isSelectable]) return;
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// trigger select method
	[item select];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger count = [_items count];
	LOG(@"PWContentItemViewController: number of items: %d", (int)count);
	
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	PWWidgetItem *item = [self itemAtIndex:row];
	
	NSString *identifier = [item.class cellIdentifier];
	PWWidgetItemCell *cell = (PWWidgetItemCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	//LOG(@"PWContentItemViewController: cell for row %u (item: %@) (cell: %@)", row, item, cell);
	
	if (!cell) {
		
		cell = [item.class createCell];
		
		// selectable
		if (![item isSelectable]) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	// set cell
	[item setActiveCell:cell];
	
	// set item
	[cell _setItem:item];
	
	// set basic properties
	[cell setTitle:item.title];
	
	// set icon
	[cell setIcon:item.icon];
	
	// set value
	[cell setValue:item.value];
	
	// show or hide chevron
	cell.accessoryType = !item.hideChevron && [cell shouldShowChevron] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	
	[cell.layer removeAllAnimations];
	[cell.contentView.layer removeAllAnimations];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	PWWidgetItem *item = [self itemAtIndex:row];
	PWWidgetItemCell *itemCell = (PWWidgetItemCell *)cell;
	
	[itemCell willAppear];
	
	if (_pendingFirstResponder != nil && item == _pendingFirstResponder) {
		_pendingFirstResponder = nil;
		if ([itemCell.class contentCanBecomeFirstResponder]) {
			[itemCell contentSetFirstResponder];
		}
	}
}

- (CGFloat)contentHeightForOrientation:(PWWidgetOrientation)orientation {
	return [self optimalContentHeightForOrientation:orientation];
}

- (NSString *)overrideContentHeightExpressionForOrientation:(PWWidgetOrientation)orientation {
	return orientation == PWWidgetOrientationPortrait ? _overrideContentHeightExpressionForPortrait : _overrideContentHeightExpressionForLandscape;
}

- (void)setOverrideContentHeightExpression:(NSString *)expression {
	[self setOverrideContentHeightExpression:expression forOrientation:PWWidgetOrientationPortrait];
	[self setOverrideContentHeightExpression:expression forOrientation:PWWidgetOrientationLandscape];
}

- (void)setOverrideContentHeightExpression:(NSString *)expression forOrientation:(PWWidgetOrientation)orientation {
	NSString *originalExpression = [self overrideContentHeightExpressionForOrientation:orientation];
	if (![originalExpression isEqualToString:expression]) {
		
		if (orientation == PWWidgetOrientationPortrait) {
			[_overrideContentHeightExpressionForPortrait release];
			_overrideContentHeightExpressionForPortrait = [expression copy];
		} else {
			[_overrideContentHeightExpressionForLandscape release];
			_overrideContentHeightExpressionForLandscape = [expression copy];
		}
		
		if (orientation == [PWController currentOrientation]) {
			[[PWController activeWidget] resizeWidgetAnimated:YES forContentViewController:self];
		}
	}
}

- (CGFloat)optimalContentHeightForOrientation:(PWWidgetOrientation)orientation {
	
	LOG(@"===== SELF shouldMaximizeContentHeight: %@", (self.shouldMaximizeContentHeight ? @"YES" : @"NO"));
	LOG(@"========= optimalContentHeightForOrientation ====== <%@> <%@>", self.shouldMaximizeContentHeight ? @"YES" : @"NO", _shouldMaximizeContentHeight ? @"YES" : @"NO");
	
	PWController *controller = [PWController sharedInstance];
	CGFloat maxHeight = [controller availableHeightInOrientation:orientation withKeyboard:self.requiresKeyboard];
	CGFloat navigationBarHeight = [controller heightOfNavigationBarInOrientation:orientation];
	CGFloat availableHeight = MAX(1.0, maxHeight - navigationBarHeight);
	
	// return the maximize height if it is set to maximize height
	if (self.shouldMaximizeContentHeight) {
		LOG(@"_itemsShouldFillHeight: <%@>", _itemsShouldFillHeight ? @"YES" : @"NO");
		if (_itemsShouldFillHeight) {
			
			CGFloat accumulatedHeight = 0.0;
			
			for (PWWidgetItem *item in _items) {
				
				if (item.shouldFillHeight) {
					[self _setFillHeight:availableHeight - accumulatedHeight forItem:item];
					return availableHeight;
				}
				
				CGFloat itemHeight = [item cellHeightForOrientation:orientation];
				if (accumulatedHeight + itemHeight <= availableHeight) {
					accumulatedHeight += itemHeight;
				} else {
					break;
				}
			}
			[self _setFillHeight:0.0 forItem:nil];
		}
		
		return availableHeight;
	}
	
	// parse the expression
	CGFloat overriddenContentHeight = 0.0;
	NSString *expression = orientation == PWWidgetOrientationPortrait ? _overrideContentHeightExpressionForPortrait : _overrideContentHeightExpressionForLandscape;
	if (expression != nil && [expression length] > 0) {
		
		CGFloat normalCellHeight = [[PWController activeTheme] heightOfCellOfType:PWWidgetCellTypeNormal forOrientation:orientation];
		CGFloat textAreaCellHeight = [[PWController activeTheme] heightOfCellOfType:PWWidgetCellTypeTextArea forOrientation:orientation];
		
		NSMutableString *_expression = [expression mutableCopy];
		
		// replace item keys
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[([a-zA-Z0-9]+)\\]"
																			   options:0
																				 error:nil];
		[regex enumerateMatchesInString:expression
								options:0
								  range:NSMakeRange(0, [expression length])
							 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
								 if ([match numberOfRanges] == 2) {
									 NSString *target = [expression substringWithRange:match.range];
									 NSString *key = [expression substringWithRange:[match rangeAtIndex:1]];
									 PWWidgetItem *item = [self itemWithKey:key];
									 if (item != nil) {
										 CGFloat cellHeight = [item cellHeightForOrientation:orientation];
										 NSString *replacement = [NSString stringWithFormat:@"%f", cellHeight];
										 LOG(@"Parsed expression (key: %@) (cell height: %f)", key, cellHeight);
										 [_expression replaceOccurrencesOfString:target withString:replacement options:0 range:NSMakeRange(0, [_expression length])];
									 }
								 }
							 }];
		
		// replace basic variabls
		[_expression replaceOccurrencesOfString:@"normal" withString:[NSString stringWithFormat:@"%f", normalCellHeight] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_expression length])];
		[_expression replaceOccurrencesOfString:@"textarea" withString:[NSString stringWithFormat:@"%f", textAreaCellHeight] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_expression length])];
		
		// solve the expression
		char buffer[1024];
		CalculatePerformExpression([_expression UTF8String], 100, 1, buffer);
		NSString *resultString = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
		[_expression release];
		
		// convert the resulting string to NSNumber
		NSNumber *result = [numberFormatter numberFromString:resultString];
		
		// retrieve the number
		CGFloat resultNumber = [result floatValue];
		
		// update final overridden value
		overriddenContentHeight = MAX(0.0, resultNumber);
	}
	
	if (overriddenContentHeight > 0) {
		
		[self _setFillHeight:0.0 forItem:nil];
		return overriddenContentHeight;
		
	} else {
		
		CGFloat accumulatedHeight = 0.0;
		
		for (PWWidgetItem *item in _items) {
			
			if (item.shouldFillHeight) {
				[self _setFillHeight:availableHeight - accumulatedHeight forItem:item];
				return availableHeight;
			}
			
			CGFloat itemHeight = [item cellHeightForOrientation:orientation];
			if (accumulatedHeight + itemHeight <= availableHeight) {
				accumulatedHeight += itemHeight;
			} else {
				break;
			}
		}
		
		// to prevent any unexpected behaviour
		if (accumulatedHeight == 0.0)
			accumulatedHeight = availableHeight;
		
		return accumulatedHeight;
	}
}

- (void)_setFillHeight:(CGFloat)fillHeight forItem:(PWWidgetItem *)item {
	LOG(@"_setFillHeight: %f <item: %@>", fillHeight, item);
	_fillHeight = fillHeight;
	NSUInteger index = [self indexOfItem:item];
	if (index != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		if (indexPath != nil) {
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		}
	}
}

- (void)_updateItemsShouldFillHeight {
	LOG(@"_updateItemsShouldFillHeight");
	_itemsShouldFillHeight = NO;
	for (PWWidgetItem *item in _items) {
		LOG(@"item.shouldFillHeight: <%@>", item.shouldFillHeight ? @"YES" : @"NO");
		if (item.shouldFillHeight) {
			_itemsShouldFillHeight = YES;
			return;
		}
	}
}

- (void)_willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	LOG(@"_willBePresentedInNavigationController");
	[super _willBePresentedInNavigationController:navigationController];
	//[self.tableView reloadData];
	_shouldUpdateLastFirstResponder = NO;
}

- (void)_presentedInNavigationController:(UINavigationController *)navigationController {
	LOG(@"_presentedInNavigationController");
	_shouldUpdateLastFirstResponder = YES;
	//[self.tableView reloadData];
	//[[[PWController sharedInstance].window firstResponder] resignFirstResponder];
}

- (void)dealloc {
	
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	
	RELEASE(_overrideContentHeightExpressionForPortrait)
	RELEASE(_overrideContentHeightExpressionForLandscape)
	RELEASE(_items)
	RELEASE(_wrappedItemValueChangedEventBlockHandler)
	
	_lastFirstResponder = nil;
	_pendingFirstResponder = nil;
	
	[super dealloc];
}

@end