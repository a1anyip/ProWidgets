//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "folderItem.h"

@interface PWWidgetBrowserAddBookmarkViewController : PWContentItemViewController {
	
	PWWidgetItemTextField *_titleItem;
	PWWidgetItemTextField *_addressItem;
	PWBrowserWidgetItemFolder *_folderItem;
}

- (void)updatePrefillTitle:(NSString *)title andAddress:(NSString *)address;

@end