//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetNotesListViewController : PWContentViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UILabel *_noLabel;
	NSMutableArray *_notes;
}

- (NoteContext *)noteContext;
- (UITableView *)tableView;

- (void)reload;
- (void)loadNotes;
- (void)removeNote:(NoteObject *)note;

@end