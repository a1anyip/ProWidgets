//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWThemableTableView : UITableView {
	
	PWTheme *_theme;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style theme:(PWTheme *)theme;

- (void)_configureAppearance;
- (void)setHideSeparatorInEmptyCells:(BOOL)hidden;

@end