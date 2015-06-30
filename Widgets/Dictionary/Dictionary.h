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

#import "Main.h"
#import "Result.h"

@interface PWWidgetDictionary : PWWidget {
	
	AVSpeechSynthesizer *_synthesizer;
	
	PWWidgetDictionaryMainViewController *_mainViewController;
	PWWidgetDictionaryResultViewController *_resultViewController;
}

@property (nonatomic, assign) BOOL shouldAutoFocus;
@property (nonatomic, copy) NSString *pendingTerm;

- (void)lookUp:(NSString *)word animated:(BOOL)animated;
- (void)pronounce:(NSString *)word;

@end