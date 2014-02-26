//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "List.h"
#import "Notes.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"
#import "PWThemableTableViewCell.h"

@implementation PWWidgetNotesListViewController

- (void)load {
	
	self.shouldAutoConfigureStandardButtons = YES;
	self.shouldMaximizeContentHeight = YES;
	
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (NSString *)title {
	return @"All Notes";
}

- (void)loadView {
	self.view = [[[PWThemableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self loadNotes];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)titleTapped {
	PWWidgetNotes *widget = (PWWidgetNotes *)[PWController activeWidget];
	[widget switchToAddInterface];
}

/**
 * UITableViewDelegate
 **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Delete";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	
	if (row >= [_notes count]) return;
	
	id note = _notes[row];
	LOG(@"note: %@", note);
}


//////////////////////////////////////////////////////////////////////

/**
 * UITableViewDataSource
 **/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetNotesTableViewCell";
	PWThemableTableViewCell *cell = (PWThemableTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWThemableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	
	
	return cell;
}

- (void)loadNotes {
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		
		
	});
}

- (void)dealloc {
	RELEASE(_notes)
	[super dealloc];
}

@end