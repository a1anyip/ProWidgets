//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItemListValue.h"
#import "../PWContentListViewController.h"
#import "../PWWidget.h"
#import "../PWWidgetItem.h"

@implementation PWWidgetItemListValue

+ (Class)cellClass {
	return [PWWidgetItemListValueCell class];
}

- (instancetype)init {
	if ((self = [super init])) {
		// default value
		_noneIndex = -1;
	}
	return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[super copyWithZone:zone];
	
	item.noneIndex = _noneIndex;
	item.maximumNumberOfSelection = _maximumNumberOfSelection;
	
	// set list item titles and values
	[item setListItemTitles:_listItemTitles values:_listItemValues];
	[item setItemValue:self.value];
	
	return item;
}

- (NSArray *)value {
	
	NSArray *value = [super value];
	
	// if the value is equal to the value of none option,
	// then return an empty array
	if (_noneIndex >= 0) { // none index is set/specified
		NSUInteger indexOfValue = [_listItemValues indexOfObject:value];
		if (indexOfValue == _noneIndex)
			return @[];
	}
	
	return value;
}

- (void)setValue:(id)value {
	
	if (_listItemValues == nil || [_listItemValues count] == 0) return;
	
	BOOL isArray = [value isKindOfClass:[NSArray class]];
	NSArray *selectedValues = nil;
	
	if (value != nil) {
		
		if (!isArray) {
			// wrap the single object in an array
			value = @[value];
		} else {
			// make sure that every value in the selected values is unique
			value = [value valueForKeyPath:@"@distinctUnionOfObjects.self"];
		}
		
		// to ensure the new selected values is in order
		// according to the list ite values
		
		NSUInteger valueCount = [value count];
		NSUInteger selectedValueCount = 0;
		
		unsigned int i = 0;
		NSMutableArray *_selectedValues = [NSMutableArray array];
		for (id val in _listItemValues) {
			if ((_noneIndex < 0 || _noneIndex != i) && [value containsObject:val]) {
				[_selectedValues addObject:val];
				if (++selectedValueCount == valueCount) break;
			}
			i++;
		}
		
		selectedValues = _selectedValues;
	}
	
	// fallback: select the first item
	if (selectedValues == nil || [selectedValues count] == 0) {
		// try to set the selected values to the value at none index
		if (_noneIndex >= 0 && [_listItemValues count] > _noneIndex) {
			selectedValues = @[];
		} else {
			selectedValues = @[(_listItemValues[0])];
		}
	}
	
	// store new values
	[super setValue:selectedValues];
	
	// reload table view
	[_listViewController reload];
}

- (BOOL)isSelectable {
	return YES;
}

- (void)select {
	
	if (_listViewController == nil) {
		_listViewController = [[PWContentListViewController alloc] initWithTitle:self.title delegate:self forWidget:self.itemViewController.widget];
	}
	
	BOOL requiresKeyboard = self.itemViewController.requiresKeyboard;
	if (![PWController isIPad] && [PWController isLandscape]) {
		requiresKeyboard = NO; // to maximize the content height
	}
	_listViewController.requiresKeyboard = requiresKeyboard;
	
	[self.itemViewController.widget pushViewController:_listViewController animated:YES];
}

- (void)setExtraAttributes:(NSDictionary *)attributes {
	
	NSArray *listItemTitles = attributes[@"listItemTitles"];
	NSArray *listItemValues = attributes[@"listItemValues"];
	NSNumber *noneIndex = attributes[@"listNoneIndex"];
	NSNumber *maxSelection = attributes[@"listMaxSelection"];
	
	if (listItemTitles != nil && listItemValues != nil) {
		
		// process localized titles
		NSBundle *bundle = self.itemViewController.widget.bundle;
		if (bundle != nil) {
			
			BOOL failed = NO;
			NSMutableArray *localizedListItemTitles = [NSMutableArray array];
			
			for (NSString *rawTitle in listItemTitles) {
				NSString *localizedTitle = T(rawTitle, bundle);
				if (localizedTitle == nil) {
					failed = YES;
					break;
				} else {
					[localizedListItemTitles addObject:localizedTitle];
				}
			}
			
			if (!failed) {
				listItemTitles = localizedListItemTitles;
			}
		}
		
		[self setListItemTitles:listItemTitles values:listItemValues];
	}
	
	if (noneIndex != nil)
		[self setNoneIndex:MAX(-1, [noneIndex integerValue])];
	else
		[self setNoneIndex:-1];
	
	if (maxSelection != nil)
		[self setMaximumNumberOfSelection:MAX(1, [maxSelection unsignedIntegerValue])];
}

- (void)setListItemTitles:(NSArray *)titles values:(NSArray *)values {
	
	if ([titles count] != [values count]) {
		LOG(@"PWWidgetItemListValue: Number of list item titles and values mismatches.");
		return;
	}
	
	for (NSObject *title in titles) {
		if (![title isKindOfClass:[NSString class]]) {
			LOG(@"PWWidgetItemListValue: All list item titles must be NSString.");
			return;
		}
	}
	
	// check uniqueness
	NSArray *uniqueValues = [values valueForKeyPath:@"@distinctUnionOfObjects.self"];
	if ([uniqueValues count] != [values count]) {
		LOG(@"PWWidgetItemListValue: Each list item value must be unique.");
		return;
	}
	
	// update stored value
	[_listItemTitles release];
	[_listItemValues release];
	
	_listItemTitles = [titles mutableCopy];
	_listItemValues = [values mutableCopy];
	
	// reset value
	[self setValue:nil];
	
	// reload table view
	[_listViewController reload];
}

- (NSString *)displayTextForValues:(NSArray *)values {
	
	if ([values count] == 0 && _noneIndex >= 0 && _noneIndex < [_listItemTitles count]) {
		
		// set the title of item at none index
		return _listItemTitles[_noneIndex];
		
	} else {
		
		NSMutableArray *titles = [NSMutableArray array];
		
		for (NSNumber *value in values) {
			NSUInteger index = [_listItemValues indexOfObject:value];
			if (index == NSNotFound || index >= [_listItemTitles count]) continue;
			[titles addObject:_listItemTitles[index]];
		}
		
		return [titles componentsJoinedByString:@", "];
	}
	
	return nil;
}

// PWContentListViewControllerDelegate

- (NSArray *)listItemTitles {
	return _listItemTitles;
}

- (NSArray *)listItemValues {
	return _listItemValues;
}

- (NSArray *)selectedValues {
	return (NSArray *)self.value;
}

- (NSInteger)noneIndex {
	return MAX(-1, _noneIndex);
}

- (NSUInteger)maximumNumberOfSelection {
	return MAX(1, _maximumNumberOfSelection);
}

- (void)selectedTooManyItems {
	[self.itemViewController.widget showMessage:[NSString stringWithFormat:CT(@"ListValueSelectedTooManyItems"), (unsigned int)_maximumNumberOfSelection]];
}

- (void)selectedValuesChanged:(NSArray *)newValues oldValues:(NSArray *)oldValues {
	
	// save new value
	// and update value in cell
	[super setValue:[[newValues mutableCopy] autorelease]];
	
	if ([self maximumNumberOfSelection] == 1) {
		[self.itemViewController.widget popViewController];
	}
	
	// notify widget
	[self.itemViewController itemValueChanged:self oldValue:oldValues];
	
	LOG(@"PWWidgetItemListValue: selectedValuesChanged (new: %@, old: %@)", newValues, oldValues);
}

- (void)dealloc {
	
	RELEASE(_listItemTitles)
	RELEASE(_listItemValues)
	
	[super dealloc];
}

@end

@implementation PWWidgetItemListValueCell

//////////////////////////////////////////////////////////////////////

+ (PWWidgetItemCellStyle)cellStyle {
	return PWWidgetItemCellStyleValue;
}

//////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
	self.textLabel.text = title;
}

- (void)setValue:(NSArray *)value {
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)self.item;
	NSString *text = [item displayTextForValues:(NSArray *)item.value];
	self.detailTextLabel.text = text;
	[self setNeedsLayout]; // this line is important to instantly reflect the new value
}

- (BOOL)shouldShowChevron {
	return YES;
}

@end