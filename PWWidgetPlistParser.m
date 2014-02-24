//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWidgetPlistParser.h"
#import "PWController.h"
#import "PWWidget.h"
#import "PWWidgetJS.h"
#import "PWWidgetItem.h"
#import "PWTheme.h"
#import "PWContentViewController.h"
#import "PWContentItemViewController.h"

static NSDictionary *predefinedTypes = nil;

@implementation PWWidgetPlistParser

+ (void)load {
	
	if (predefinedTypes != nil);
	
	predefinedTypes = [@{
		@"textarea": @"PWWidgetItemTextArea",
		@"textfield": @"PWWidgetItemTextField",
		@"listvalue": @"PWWidgetItemListValue",
		@"datevalue": @"PWWidgetItemDateValue",
		@"tonevalue": @"PWWidgetItemToneValue",
		@"switch": @"PWWidgetItemSwitch",
		@"text": @"PWWidgetItemText",
		@"button": @"PWWidgetItemButton",
		@"webview": @"PWWidgetItemWebView",
		@"recipient": @"PWWidgetItemRecipient"
	} retain];
}

+ (void)parse:(NSDictionary *)dict forWidget:(PWWidget *)widget {
	
	LOG(@"PWWidgetPlistParser: Parsing plist for widget (%@)", widget);
	
	// requiresProtectedDataAccess
	NSNumber *requiresProtectedDataAccess = dict[@"requiresProtectedDataAccess"];
	if (requiresProtectedDataAccess != nil) {
		[widget setRequiresProtectedDataAccess:[requiresProtectedDataAccess boolValue]];
	}
	
	// title
	NSString *title = dict[@"title"];
	if (title != nil) widget.title = title;
	
	// layout
	NSString *layoutName = [dict[@"layout"] lowercaseString];
	
	// JS widgets must use default layout
	PWWidgetLayout layout = PWWidgetLayoutDefault;
	if (![widget isKindOfClass:[PWWidgetJS class]]) {
		if ([layoutName hasSuffix:@"custom"]) {
			layout = PWWidgetLayoutCustom;
		}
	}
	
	widget.layout = layout;
	
	// preferred tint color
	NSString *preferredTintColor = dict[@"preferredTintColor"];
	if (preferredTintColor != nil) {
		UIColor *color = [PWTheme parseColorString:preferredTintColor];
		widget.preferredTintColor = color;
	}
	
	// preferred bar text color
	NSString *preferredBarTextColor = dict[@"preferredBarTextColor"];
	if (preferredBarTextColor != nil) {
		UIColor *color = [PWTheme parseColorString:preferredBarTextColor];
		widget.preferredBarTextColor = color;
	}
	
	// widget theme
	NSString *themeName = dict[@"theme"];
	if (themeName != nil) {
		
		// try plist
		BOOL success = [widget loadThemePlist:themeName];
		
		// then load theme from other bundles OR defined in the same bundle
		if (!success)
			[widget loadThemeNamed:themeName];
	}
	
	// defaultItemViewControllerPlist
	if (layout == PWWidgetLayoutDefault) {
		NSString *defaultItemViewControllerPlist = dict[@"defaultItemViewControllerPlist"];
		if (defaultItemViewControllerPlist != nil) {
			widget.defaultItemViewControllerPlist = defaultItemViewControllerPlist;
		}
	}
}

+ (void)parse:(NSDictionary *)dict forContentViewController:(PWContentViewController *)viewController {
	
	// title
	NSString *title = dict[@"title"];
	if (title != nil) viewController.title = title;
	
	// closeButtonText
	NSString *closeButtonText = dict[@"closeButtonText"];
	if (closeButtonText != nil) [viewController setCloseButtonText:closeButtonText];
	
	// actionButtonText
	NSString *actionButtonText = dict[@"actionButtonText"];
	if (actionButtonText != nil) [viewController setActionButtonText:actionButtonText];
	
	// shouldAutoConfigureStandardButtons
	NSNumber *shouldAutoConfigureStandardButtons = dict[@"shouldAutoConfigureStandardButtons"];
	if (shouldAutoConfigureStandardButtons != nil) {
		[viewController setShouldAutoConfigureStandardButtons:[shouldAutoConfigureStandardButtons boolValue]];
	}
	
	// shouldMaximizeContentHeight
	NSNumber *shouldMaximizeContentHeight = dict[@"shouldMaximizeContentHeight"];
	if (shouldMaximizeContentHeight != nil) {
		[viewController setShouldMaximizeContentHeight:[shouldMaximizeContentHeight boolValue]];
	}
	
	// requiresKeyboard
	NSNumber *requiresKeyboard = dict[@"requiresKeyboard"];
	if (requiresKeyboard != nil) {
		[viewController setRequiresKeyboard:[requiresKeyboard boolValue]];
	}
}

+ (void)parse:(NSDictionary *)dict forContentItemViewController:(PWContentItemViewController *)itemViewController {
	
	[self parse:dict forContentViewController:itemViewController];
	
	// override content height
	id overrideContentHeight = dict[@"overrideContentHeight"];
	if (overrideContentHeight != nil) {
		
		NSString *expressionForPortrait = nil;
		NSString *expressionForLandscape = nil;
		
#define EXPRESSION_FROM_STRING(x) NSString *expression = (NSString *)x;
		
#define EXPRESSION_FROM_NUMBER(x) NSNumber *expressionNumber = (NSNumber *)x;\
NSString *expression = [NSString stringWithFormat:@"%f", [expressionNumber doubleValue]];
		
		if ([overrideContentHeight isKindOfClass:[NSString class]]) {
			
			EXPRESSION_FROM_STRING(overrideContentHeight)
			expressionForPortrait = expression;
			expressionForLandscape = expression;
			
		} else if ([overrideContentHeight isKindOfClass:[NSNumber class]]) {
			
			EXPRESSION_FROM_NUMBER(overrideContentHeight)
			expressionForPortrait = expression;
			expressionForLandscape = expression;
			
		} else if ([overrideContentHeight isKindOfClass:[NSDictionary class]]) {
			
			NSDictionary *dict = (NSDictionary *)overrideContentHeight;
			id portrait = dict[@"portrait"];
			id landscape = dict[@"landscape"];
			
			if (portrait != nil) {
				if ([portrait isKindOfClass:[NSString class]]) {
					
					EXPRESSION_FROM_STRING(portrait)
					expressionForPortrait = expression;
					
				} else if ([portrait isKindOfClass:[NSNumber class]]) {
					
					EXPRESSION_FROM_NUMBER(portrait)
					expressionForPortrait = expression;
				}
			}
			
			if (landscape != nil) {
				if ([landscape isKindOfClass:[NSString class]]) {
					
					EXPRESSION_FROM_STRING(landscape)
					expressionForLandscape = expression;
					
				} else if ([landscape isKindOfClass:[NSNumber class]]) {
					
					EXPRESSION_FROM_NUMBER(landscape)
					expressionForLandscape = expression;
				}
			}
		}
		
		if (expressionForPortrait != nil)
			[itemViewController setOverrideContentHeightExpression:expressionForPortrait forOrientation:PWWidgetOrientationPortrait];
		
		if (expressionForLandscape != nil)
			[itemViewController setOverrideContentHeightExpression:expressionForLandscape forOrientation:PWWidgetOrientationLandscape];
	}
	
	// items
	NSArray *items = dict[@"items"];
	NSMutableArray *parsedItems = nil;
	if (items != nil && [items count] > 0) {
		
		// initialized the array
		parsedItems = [NSMutableArray new];
		
		for (NSDictionary *item in items) {
			
			// required 'key'
			NSString *key = item[@"key"];
			
			// title
			NSString *title = item[@"title"];
			
			// type
			NSString *type = item[@"type"];
			
			// if the type is predefined, convert it to full class name
			if (type != nil) {
				NSString *predefinedClassName = [predefinedTypes objectForKey:[type lowercaseString]];
				if (predefinedClassName != nil)
					type = predefinedClassName;
			}
			
			// create the widget item
			PWWidgetItem *widgetItem = [PWWidgetItem createItemNamed:type forItemViewController:itemViewController]; // auto release
			
			if (widgetItem == nil) {
				LOG(@"PWWidgetPlistParser: Error occurs when creating an item. Reason: item class name defined in 'type' does not exist.");
				continue;
			}
			
			// default value
			id defaultValue = item[@"default"];
			
			// actionEventName
			NSString *actionEventName = item[@"actionEventName"];
			
			// hideChevron (default NO)
			NSNumber *_hideChevron = item[@"hideChevron"];
			BOOL hideChevron = _hideChevron != nil ? [_hideChevron boolValue] : NO;
			
			// icon
			NSString *icon = item[@"icon"];
			UIImage *iconImage = nil;
			if (icon != nil) {
				iconImage = [UIImage imageNamed:icon inBundle:[PWController activeWidget].bundle];
			}
			
			// should fill height
			BOOL shouldFillHeight = [item[@"shouldFillHeight"] boolValue];
			
			// minimum fill height
			CGFloat minimumFillHeight = (CGFloat)[item[@"minimumFillHeight"] doubleValue];
			
			// override height
			CGFloat overrideHeight = (CGFloat)[item[@"overrideHeight"] doubleValue];
			
			// configure the widget item
			widgetItem.key = key;
			widgetItem.title = title;
			widgetItem.actionEventName = actionEventName;
			widgetItem.hideChevron = hideChevron;
			widgetItem.icon = iconImage;
			widgetItem.shouldFillHeight = shouldFillHeight;
			widgetItem.minimumFillHeight = minimumFillHeight;
			widgetItem.overrideHeight = overrideHeight;
			
			// set extra attributes (like list item titles and values)
			[widgetItem setExtraAttributes:item];
			
			// set default value
			widgetItem.value = defaultValue;
			
			LOG(@"PWWidgetPlistParser: Created a widget item (%@)", widgetItem);
			
			[parsedItems addObject:widgetItem];
		}
	} else {
		LOG(@"PWWidgetPlistParser: No items specified in plist.");
	}
	
	[itemViewController setItems:parsedItems];
	[parsedItems release];
}

@end