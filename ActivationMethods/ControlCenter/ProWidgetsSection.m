//
//  ProWidgetsSection.m
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "ProWidgetsSection.h"

@implementation ProWidgetsSection

- (CGFloat)sectionHeight {
	return 98.0; // same as the stock one
}

- (void)loadView {
	self.view = [[ProWidgetsSectionView new] autorelease];
}

- (UIView *)view {
	if (!_view) {
		[self loadView];
	}
	return _view;
}

- (void)controlCenterWillAppear {
	[self.view load];
	[self.view resetPage];
}

- (void)controlCenterDidDisappear {
	[self.view unload];
}

- (void)dealloc {
	self.view = nil;
	[super dealloc];
}

@end
