//
//  ProWidgetsSectionView.h
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "interface.h"

@interface ProWidgetsSectionView : UIView {
	
	UILabel *_noVisibleWidgetLabel;
	UIScrollView *_scrollView;
	NSMutableArray *_pages;
	NSUInteger _pageCount;
}

- (void)resetPage;
- (void)load;
- (void)unload;

@end
