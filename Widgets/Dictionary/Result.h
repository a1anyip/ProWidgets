//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "interface.h"
#import "PWContentItemViewController.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "WidgetItems/items.h"

@interface PWWidgetDictionaryResultViewController : PWContentItemViewController {
	
	UIBarButtonItem *_speakerButtonItem;
	NSString *_content;
}

@property(nonatomic, copy) NSString *content;

- (void)configureSpeakerButton;
- (void)updateDefinition:(_UIDefinitionValue *)definition;

@end