//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemePlistParser.h"
#import "PWTheme.h"
#import "PWThemeParsed.h"

static NSArray *boolKeys = nil;

static NSArray *imageKeys = nil;

static NSArray *colorKeys = nil;

static NSArray *doubleKeys = nil;

// convert key to selector name (setXxx:)
static inline SEL NSSetSelectorFromKey(NSString *key) {
	NSString *selectorName = [NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
	return NSSelectorFromString(selectorName);
}

// convert key to selector name (setXxx:forOrientation:)
static inline SEL NSSetImageSelectorFromKey(NSString *key) {
	NSString *selectorName = [NSString stringWithFormat:@"set%@%@:forOrientation:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
	return NSSelectorFromString(selectorName);
}

static inline UIImage *retrieveImage(PWTheme *theme, NSString *name, NSString *capInsets) {
	
	if (theme == nil || name == nil || [name length] == 0) return nil;
	
	// convert cap insets string to UIEdgeInsets
	BOOL includeCapInsets = NO;
	UIEdgeInsets imageCapInsets = UIEdgeInsetsZero;
	
	if (capInsets != nil && [capInsets length] > 0) {
		
		// ^([\d\.]+)\s*,\s*([\d\.]+)\s*,\s*([\d\.]+)\s*,\s*([\d\.]+)$
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([\\d\\.]+)\\s*,\\s*([\\d\\.]+)\\s*,\\s*([\\d\\.]+)\\s*,\\s*([\\d\\.]+)$"
																			   options:0
																				 error:nil];
		
		NSTextCheckingResult *match = [regex firstMatchInString:capInsets
														options:0
														  range:NSMakeRange(0, [capInsets length])];
		
		// invalid format
		if (match != nil) {
		
			CGFloat top = 0.0;
			CGFloat left = 0.0;
			CGFloat bottom = 0.0;
			CGFloat right = 0.0;
			
			// the first range is the full length of source string
			for (unsigned int i = 0; i < [match numberOfRanges] - 1; i++) {
				
				NSRange range = [match rangeAtIndex:i + 1];
				if (range.location == NSNotFound) continue;
				
				NSString *part = [capInsets substringWithRange:range];
				CGFloat doubleValue = [part doubleValue];
				
				if (i == 0)
					top = doubleValue;
				else if (i == 1)
					left = doubleValue;
				else if (i == 2)
					bottom = doubleValue;
				else if (i == 3)
					right = doubleValue;
			}
			
			includeCapInsets = YES;
			imageCapInsets = UIEdgeInsetsMake(top, left, bottom, right);
		}
	}
	
	return includeCapInsets ? [theme imageNamed:name withCapInsets:imageCapInsets] : [theme imageNamed:name];
}

static inline void configureCellHeight(PWThemeParsed *theme, NSDictionary *dict, PWWidgetOrientation orientation) {
	
	NSNumber *normalHeight = dict[@"normal"];
	NSNumber *textareaHeight = dict[@"textarea"];
	if (normalHeight != nil && textareaHeight != nil) {
		[theme setHeightOfCell:[normalHeight doubleValue] forType:PWWidgetCellTypeNormal forOrientation:orientation];
		[theme setHeightOfCell:[textareaHeight doubleValue] forType:PWWidgetCellTypeTextArea forOrientation:orientation];
	}
}

@implementation PWThemePlistParser

+ (void)load {
	
	if (boolKeys != nil && imageKeys != nil && colorKeys != nil && doubleKeys != nil) return;
	
	boolKeys = [@[@"wantsDarkKeyboard"] copy];
	
	imageKeys = [@[@"sheetBackgroundImage", @"navigationBarBackgroundImage", @"cellBackgroundImage", @"cellSelectedBackgroundImage"] copy];
	
	colorKeys = [@[@"tintColor", @"sheetForegroundColor", @"sheetBackgroundColor", @"navigationBarBackgroundColor", @"navigationTitleTextColor", @"navigationButtonTextColor", @"cellSeparatorColor", @"cellBackgroundColor", @"cellTitleTextColor", @"cellValueTextColor", @"cellButtonTextColor", @"cellInputTextColor", @"cellInputPlaceholderTextColor", @"cellPlainTextColor", @"cellSelectedBackgroundColor", @"cellSelectedTitleTextColor", @"cellSelectedValueTextColor", @"cellSelectedButtonTextColor", @"cellHeaderFooterViewBackgroundColor", @"cellHeaderFooterViewTitleTextColor", @"switchThumbColor", @"switchOnColor", @"switchOffColor"] copy];
	
	doubleKeys = [@[@"cornerRadius"] copy];
}

+ (PWTheme *)parse:(NSDictionary *)dict inBundle:(NSBundle *)bundle {
	
	LOG(@"PWThemePlistParser: Parsing theme plist");
	
	PWThemeParsed *theme = [PWThemeParsed new];
	
	// set basic information
	theme.name = dict[@"name"];
	theme.bundle = bundle;
	
	// process boolean keys
	for (NSString *key in boolKeys) {
		
		NSNumber *value = dict[key];
		
		// not specified in plist
		if (value == nil || ![value isKindOfClass:[NSNumber class]]) continue;
		
		// convert key to selector name (setXxx)
		SEL selector = NSSetSelectorFromKey(key);
		
		if ([theme respondsToSelector:selector]) {
			LOG(@"PWThemePlistParser: set '%@' to %@", key, value);
			[theme performSelector:selector withObject:value];
		} else {
			LOG(@"PWThemePlistParser: selector '%@' not found", NSStringFromSelector(selector));
		}
	}
	
	// process image keys
	for (NSString *key in imageKeys) {
		
		id value = dict[key];
		
		// not specified in plist
		if (value == nil || ![value isKindOfClass:[NSDictionary class]]) continue;
		
		SEL selector = NSSetImageSelectorFromKey(key);
		
		if (![theme respondsToSelector:selector]) {
			LOG(@"PWThemePlistParser: selector '%@' not found", NSStringFromSelector(selector));
			continue;
		}
		
		// specified images for two orientations
		NSString *portraitImageName = value[@"portrait"];
		NSString *landscapeImageName = value[@"landscape"];
		
		// specified image cap insets for two orientations
		NSString *portraitCapInsets = value[@"portraitCapInsets"];
		NSString *landscapeCapInsets = value[@"landscapeCapInsets"];
		
		// retrieve images for both orientations
		UIImage *portraitImage = retrieveImage(theme, portraitImageName, portraitCapInsets);
		UIImage *landscapeImage = retrieveImage(theme, landscapeImageName, landscapeCapInsets);
		
		if (portraitImage != nil) {
			LOG(@"PWThemePlistParser: set '%@' (portrait) to %@", key, portraitImage);
			[theme performSelector:selector withObject:portraitImage withObject:[NSNumber numberWithInt:PWWidgetOrientationPortrait]];
		}
		
		if (landscapeImage != nil) {
			LOG(@"PWThemePlistParser: set '%@' (landscape) to %@", key, landscapeImage);
			[theme performSelector:selector withObject:landscapeImage withObject:[NSNumber numberWithInt:PWWidgetOrientationLandscape]];
		}
	}
	
	// process color keys
	for (NSString *key in colorKeys) {
		
		NSString *value = dict[key];
		
		// not specified in plist
		if (value == nil || ![value isKindOfClass:[NSString class]] || [value length] == 0) continue;
		
		// convert color string into UIColor
		UIColor *color = [PWTheme parseColorString:value];
		
		if (color != nil) {
			
			SEL selector = NSSetSelectorFromKey(key);
			
			if ([theme respondsToSelector:selector]) {
				LOG(@"PWThemePlistParser: set '%@' to %@", key, color);
				[theme performSelector:selector withObject:color];
			} else {
				LOG(@"PWThemePlistParser: selector '%@' not found", NSStringFromSelector(selector));
			}
			
		} else {
			LOG(@"PWThemePlistParser: unable to parse color string '%@'", value);
		}
	}
	
	// process double keys
	for (NSString *key in doubleKeys) {
		
		NSNumber *value = dict[key];
		
		// not specified in plist
		if (value == nil || ![value isKindOfClass:[NSNumber class]]) continue;
		
		// convert key to selector name (setXxx)
		SEL selector = NSSetSelectorFromKey(key);
		
		if ([theme respondsToSelector:selector]) {
			LOG(@"PWThemePlistParser: set '%@' to %@", key, value);
			[theme performSelector:selector withObject:value];
		} else {
			LOG(@"PWThemePlistParser: selector '%@' not found", NSStringFromSelector(selector));
		}
	}
	
	// process cell height
	NSDictionary *cellHeight = dict[@"cellHeight"];
	if (cellHeight != nil) {
		
		NSDictionary *portrait = cellHeight[@"portrait"];
		NSDictionary *landscape = cellHeight[@"landscape"];
		
		if (portrait == nil && landscape == nil) {
			// root -> normal / textarea
			configureCellHeight(theme, cellHeight, PWWidgetOrientationPortrait);
			configureCellHeight(theme, cellHeight, PWWidgetOrientationLandscape);
		} else {
			// root -> portrait/landscape -> normal/textarea
			if (portrait != nil)
				configureCellHeight(theme, portrait, PWWidgetOrientationPortrait);
			if (landscape != nil)
				configureCellHeight(theme, landscape, PWWidgetOrientationLandscape);
		}
	}
	
	return [theme autorelease];
}

@end