//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetBrowserAddBookmarkViewController : PWContentViewController {
	
	NSString *_bookmarkTitle;
	NSString *_bookmarkURL;
}

@property(nonatomic, copy) NSString *bookmarkTitle;
@property(nonatomic, copy) NSString *bookmarkURL;

@end