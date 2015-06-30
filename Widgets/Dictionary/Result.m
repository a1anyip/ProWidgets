//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Result.h"
#import "Dictionary.h"

@implementation PWWidgetDictionaryResultViewController

- (void)load {
	
	self.requiresKeyboard = NO;
	self.shouldMaximizeContentHeight = YES;
	
	[self loadPlist:@"DictionaryResultItems"];
	
	[self setSubmitEventBlockHandler:^(id object) {
		[[PWWidgetDictionary widget] pronounce:self.title];
	}];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureSpeakerButton];
}

- (void)configureSpeakerButton {
	
	if (_speakerButtonItem != nil && [self.navigationItem.rightBarButtonItems containsObject:_speakerButtonItem]) return;
	
	if (_speakerButtonItem == nil) {
		UIImage *speakerIcon = [PWWidgetDictionary imageNamed:@"speaker"];
		_speakerButtonItem = [[UIBarButtonItem alloc] initWithImage:speakerIcon style:UIBarButtonItemStylePlain target:self action:@selector(triggerAction)];
	}
	
	// add the buttons and spacing to navigation bar
	self.navigationItem.rightBarButtonItems = @[_speakerButtonItem];
}

- (void)updateDefinition:(_UIDefinitionValue *)definition {
	self.title = definition.term;
	self.content = definition.longDefinition;
	[self updateContent:self.content];
}

- (void)updateContent:(NSString *)content {
	
	PWTheme *theme = [PWWidgetDictionary theme];
	PWWidgetItemWebView *item = (PWWidgetItemWebView *)[self itemWithKey:@"webView"];
	NSString *HTMLContent = nil;
	
	// adjust the text and separator color
	UIColor *textColor = [theme cellTitleTextColor];
	UIColor *separatorColor = [theme cellSeparatorColor];
	NSString *textRGBA = [PWTheme RGBAFromColor:textColor];
	NSString *separatorRGBA = [PWTheme RGBAFromColor:separatorColor];
	if (textRGBA != nil && separatorRGBA != nil) {
		HTMLContent = [NSString stringWithFormat:@"%@<style>* { color:%@ !important; background:none !important; border-color:%@ !important;  }</style>", content, textRGBA, separatorRGBA];
	} else {
		HTMLContent = content;
	}
	
	[item loadHTMLString:HTMLContent baseURL:nil];
	//[_content release], _content = nil;
}

- (void)dealloc {
	RELEASE(_speakerButtonItem)
	RELEASE(_content)
	[super dealloc];
}

@end