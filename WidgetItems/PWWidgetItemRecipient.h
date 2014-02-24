//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"

@interface PWWidgetItemRecipient : PWWidgetItem<UITableViewDelegate, UITableViewDataSource> {
	
	CGFloat _viewHeight;
	
	//CKRecipientSearchListController
	UITableView *_searchResultView;
	NSArray *_searchResult;
}

@end

@interface PWWidgetItemRecipientCell : PWWidgetItemCell {
	
	MFComposeRecipientView *_recipientView;
}

@property(nonatomic, readonly) MFComposeRecipientView *recipientView;

@end