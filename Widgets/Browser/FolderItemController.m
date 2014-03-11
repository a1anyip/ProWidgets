//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "FolderItemController.h"
#import "../../PWThemableTableView.h"
#import "../../PWThemableTableViewCell.h"

@implementation PWBrowserWidgetItemFolderController

- (instancetype)initForWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		
		self.wantsFullscreen = YES;
	}
	return self;
}

- (NSString *)title {
	return @"Destination";
}

- (void)loadView {
	PWThemableTableView *view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain theme:self.theme] autorelease];
	view.delegate = self;
	view.dataSource = self;
	self.view = view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	//[self resetState];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		
	// deselect the cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWBrowserWidgetItemFolderController";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		
		cell = [[[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier theme:self.theme] autorelease];
	}
	
	
	
	return cell;
}

- (void)dealloc {
	[super dealloc];
}

@end