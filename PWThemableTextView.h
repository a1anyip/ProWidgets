//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWThemableTextView : UITextView

- (instancetype)initWithFrame:(CGRect)frame theme:(PWTheme *)theme;
- (void)_configureAppearance:(PWTheme *)theme;

@end