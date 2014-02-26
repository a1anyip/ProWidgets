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
#import "Cell.h"
#import "Content.h"
#import "PWContentViewController.h"
#import "PWThemableTableView.h"

@implementation PWWidgetNotesListViewController

- (void)load {
	
	self.shouldAutoConfigureStandardButtons = NO;
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

- (NoteContext *)noteContext {
	PWWidgetNotes *widget = (PWWidgetNotes *)[PWController activeWidget];
	return widget.noteContext;
}

- (UITableView *)tableView {
	return (UITableView *)self.view;
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureCloseButton];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	unsigned int row = [indexPath row];
	NoteObject *note = _notes[row];
	
	PWWidgetNotesContentViewController *controller = [[[PWWidgetNotesContentViewController alloc] initWithNote:note] autorelease];
	controller.listViewController = self;
	[[PWController activeWidget] pushViewController:controller animated:YES];
	
	// deselect the cell
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
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
	
	NoteObject *note = _notes[row];
	[self removeNote:note];
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
	
	unsigned int row = [indexPath row];
	
	NSString *identifier = @"PWWidgetNotesTableViewCell";
	PWWidgetNotesTableViewCell *cell = (PWWidgetNotesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (!cell) {
		cell = [[[PWWidgetNotesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
	}
	
	NoteObject *note = _notes[row];
	NSString *title = note.title;
	NSDate *modificationDate = note.modificationDate;
	
	[cell setTitle:title];
	[cell setDate:modificationDate];
	
	return cell;
}

- (void)loadNotes {
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		NoteContext *context = self.noteContext;
		NSArray *allNotes = [context allVisibleNotes]; // an array of NoteObject
		[_notes release];
		_notes = [allNotes copy];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			applyFadeTransition(self.tableView, .2);
		});
	});
}

- (void)removeNote:(NoteObject *)note {
	NoteContext *context = self.noteContext;
	[context deleteNote:note];
	[context saveOutsideApp:NULL];
	[self loadNotes];
}

- (void)dealloc {
	RELEASE(_notes)
	[super dealloc];
}

@end