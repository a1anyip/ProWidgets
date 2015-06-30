//
//  ProWidgets
//  Notification Center
//
//  Created by Alan Yip on 22 Feb 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "interface.h"
#import "header.h"

@interface PWNCView : UIView {
	
	UILabel *_noVisibleWidgetLabel;
	UIScrollView *_scrollView;
	NSMutableArray *_pages;
	NSUInteger _pageCount;
}

- (void)resetPage;
- (void)load;
- (void)unload;

@end