//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetItem.h"
#import "PWWidgetItemCell.h"
#import "WidgetItems/items.h"
#import "PWWidget.h"
#import "PWController.h"
#import "PWTheme.h"
#import "PWContentItemViewController.h"

@implementation PWWidgetItem

+ (Class)valueClass {
	return nil;
}

+ (id)defaultValue {
	return nil;
}

//////////////////////////////////////////////////////////////////////

- (PWWidget *)widget {
	return self.itemViewController.widget;
}

-(PWTheme *)theme {
	return self.itemViewController.theme;
}

/**
 * Override this to specify which class the cell should be
 **/

+ (Class)cellClass {
	LOG(@"PWWidgetItem: cellClass must be overridden. Item: %@", NSStringFromClass(self));
	return nil;
}

/**
 * Retrieve the identifier of table view cell
 **/

+ (NSString *)cellIdentifier {
	return NSStringFromClass([self cellClass]);
}

/**
 * Retrieve the table view cell for a widget item
 **/

+ (PWWidgetItemCell *)createCell:(PWTheme *)theme {
	PWWidgetItemCell *cell = (PWWidgetItemCell *)[[self cellClass] create:theme];
	return cell;
}

//////////////////////////////////////////////////////////////////////

/**
 * Shortcuts related to widget items
 **/

// shortcut to create item with the given type
+ (PWWidgetItem *)createItemNamed:(NSString *)name forItemViewController:(PWContentItemViewController *)itemViewController {
	
	Class itemClass = NSClassFromString(name);
	
	if (itemClass == nil || ![itemClass isSubclassOfClass:[PWWidgetItem class]]) {
		LOG(@"PWWidgetItem: Unable to create a widget item named '%@'. Reason: the class does not exist or it is not a sub class of PWWidgetItem.", name);
		return nil;
	}
	
	PWWidgetItem *item = [itemClass new];
	item.itemViewController = itemViewController;
	
	return [item autorelease];
}

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)init {
	if ((self = [super init])) {
		_cellType = [self isKindOfClass:[PWWidgetItemTextArea class]] ? PWWidgetCellTypeTextArea : PWWidgetCellTypeNormal;
	}
	return self;
}

- (instancetype)initWithKey:(NSString *)key title:(NSString *)title actionEventName:(NSString *)actionEventName hideChevron:(BOOL)hideChevron icon:(UIImage *)icon {
	if ((self = [self init])) {
		
		self.key = key;
		self.title = title;
		self.actionEventName = actionEventName;
		self.hideChevron = hideChevron;
		self.icon = icon;
	}
	return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
	
	LOG(@"PWWidgetItem: Copy instance (%@)", self);
	
	PWWidgetItem *item = [self.class new];
	
	// set reference
	item.itemViewController = _itemViewController;
	
	// set runtime variables and properties
	item.key = self.key;
	item.title = self.title;
	item.actionEventName = self.actionEventName;
	item.hideChevron = self.hideChevron;
	item.icon = self.icon;
	item.shouldFillHeight = self.shouldFillHeight;
	item.minimumFillHeight = self.minimumFillHeight;
	item.overrideHeight = self.overrideHeight;
	item.value = self.value;
	item.itemValueChangedEventBlockHandler = self.itemValueChangedEventBlockHandler;
	
	return item;
}

//////////////////////////////////////////////////////////////////////

/**
 * Property Getters and Setters
 **/

- (PWWidgetItemCell *)activeCell {
	
	if (_activeCell != nil && _activeCell.item != self) {
		_activeCell = nil;
	}
	
	return _activeCell;
}

- (NSString *)type {
	return NSStringFromClass(self.class);
}

- (void)setTitle:(NSString *)title {
	
	[_title release];
	_title = [title copy];
	
	[_itemViewController reloadCellOfItem:self];
}

- (void)setIcon:(UIImage *)icon {
	
	[_icon release];
	_icon = [icon retain];
	
	[_itemViewController reloadCellOfItem:self];
}

- (id)value {
	if (_value == nil) {
		[self setValue:[self.class defaultValue]];
	}
	return _value;
}

- (void)setValue:(id)value {
	[self setItemValue:value];
	[self setCellValue:value];
}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the item
 **/

- (BOOL)isSelectable { return NO; }

- (void)select {}

- (void)becomeFirstResponder {
	[self.itemViewController requestFirstResponder:self];
}

- (void)resignFirstResponder {
	[self.activeCell contentResignFirstResponder];
}

- (void)setExtraAttributes:(NSDictionary *)attributes {}

- (CGFloat)cellHeightForOrientation:(PWWidgetOrientation)orientation {
	return self.overrideHeight == 0.0 ? [self.theme heightOfCellOfType:_cellType forOrientation:orientation] : self.overrideHeight;
}

//////////////////////////////////////////////////////////////////////

- (void)setItemValue:(id)value {
	
	Class validClass = [self.class valueClass];
	if (validClass != nil && ![value isKindOfClass:validClass]) return;
	
	if (value == nil) {
		value = [self.class defaultValue];
	}
	
	// release the previous value
	[_value release];
	
	// store the new value
	/*if ([[value class] conformsToProtocol:@protocol(NSMutableCopying)]) {
		_value = [value mutableCopy];
	} else if ([[value class] conformsToProtocol:@protocol(NSCopying)]) {
		_value = [value copy];
	} else {*/
		_value = [value retain];
	//}
}

- (void)setCellValue:(id)value {
	
	Class validClass = [self.class valueClass];
	if (validClass != nil && ![value isKindOfClass:validClass]) return;
	
	if (value == nil) {
		value = [self.class defaultValue];
	}
	
	[self.activeCell setValue:value];
}

//////////////////////////////////////////////////////////////////////

- (NSString*) description {
    return [NSString stringWithFormat:@"<%@ %p> <key: %@ / title: %@ / action event name: %@ / hide chevron: %@ / icon: %@> <value: %@>", [self class], self, _key, _title, _actionEventName, (_hideChevron ? @"YES" : @"NO"), _icon, _value];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	_itemViewController = nil;
	_activeCell = nil;
	
	RELEASE(_key)
	RELEASE(_title)
	RELEASE(_actionEventName)
	RELEASE(_icon)
	RELEASE(_value)
	RELEASE(_itemValueChangedEventBlockHandler)
	
	[super dealloc];
}

@end