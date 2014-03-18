//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "PWContentItemViewController.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "WidgetItems/items.h"

@interface PWWidgetDictionaryResultViewController : PWContentItemViewController {
	
	NSString *_content;
}

@property(nonatomic, copy) NSString *content;

@end

@implementation PWWidgetDictionaryResultViewController

- (void)load {
	self.requiresKeyboard = NO;
	self.shouldMaximizeContentHeight = YES;
	[self loadPlist:@"DictionaryResultItems"];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	
	PWTheme *theme = self.theme;
	PWWidgetItemWebView *item = (PWWidgetItemWebView *)[self itemWithKey:@"webView"];
	NSString *content = nil;
	
	// adjust the text and separator color
	UIColor *textColor = [theme cellTitleTextColor];
	UIColor *separatorColor = [theme cellSeparatorColor];
	NSString *textRGBA = [PWTheme RGBAFromColor:textColor];
	NSString *separatorRGBA = [PWTheme RGBAFromColor:separatorColor];
	if (textRGBA != nil && separatorRGBA != nil) {
		content = [NSString stringWithFormat:@"%@<style>* { color:%@ !important; background:none !important; border-color:%@ !important;  }</style>", _content, textRGBA, separatorRGBA];
	} else {
		content = _content;
	}
	
	[item loadHTMLString:content baseURL:nil];
	[_content release], _content = nil;
}

- (void)dealloc {
	RELEASE(_content)
	[super dealloc];
}

@end

@interface PWWidgetDictionary : PWWidget {
	
	PWWidgetDictionaryResultViewController *_resultViewController;
}

- (void)lookUp:(NSString *)word;
- (void)setFirstResponder;

@end

@implementation PWWidgetDictionary

- (void)load {
	
	// check if the user has installed at least one dictionary asset
	BOOL installed = NO;
	_UIDictionaryManager *manager = [objc_getClass("_UIDictionaryManager") assetManager];
	NSArray *assets = [manager _availableDictionaryAssets];
	for (ASAsset *asset in assets) {
		NSInteger state = asset.state;
		if (state != 0) {
			installed = YES;
			break;
		}
	}
	
	if (!installed) {
		[self showMessage:@"You have not installed any dictionary asset yet. Manage dictionary assets in the preference page of Dictionary widget."];
		[self dismiss];
	}
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *word = values[@"word"];
	if (word != nil && [word length] > 0) {
		// look up the word
		[self lookUp:word];
	} else {
		[self setFirstResponder];
	}
}

- (void)lookUp:(NSString *)word {
	_UIDictionaryManager *manager = [objc_getClass("_UIDictionaryManager") assetManager];
	NSArray *values = [manager _definitionValuesForTerm:word];
	if ([values count] > 0) {
		_UIDefinitionValue* value = values[0];
		NSString *term = value.term;
		NSString *result = value.longDefinition;
		if (_resultViewController == nil) {
			_resultViewController = [[PWWidgetDictionaryResultViewController alloc] initForWidget:self];
		}
		_resultViewController.title = term;
		_resultViewController.content = result;
		[self pushViewController:_resultViewController animated:YES];
	} else {
		[self showMessage:@"No definition found" title:nil handler:^{
			[self setFirstResponder];
		}];
	}
}

- (void)setFirstResponder {
	PWWidgetItem *word = [self.defaultItemViewController itemWithKey:@"word"];
	[word becomeFirstResponder];
}

- (void)dealloc {
	RELEASE(_resultViewController)
	[super dealloc];
}

@end