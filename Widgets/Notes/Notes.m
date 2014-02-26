//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Notes.h"
#import "Add.h"
#import "List.h"

@implementation PWWidgetNotes

- (void)load {
	
	PWWidgetNotesInterface defaultInterface = PWWidgetNotesInterfaceAdd;
	
	if (defaultInterface == PWWidgetNotesInterfaceAdd) {
		[self switchToAddInterface];
	} else {
		[self switchToListInterface];
	}
}

- (NSDateFormatter *)dateFormatter {
	if (_dateFormatter == nil) {
		_dateFormatter = [NSDateFormatter new];
		[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	}
	return _dateFormatter;
}

- (void)switchToAddInterface {
	
	if (_currentInterface == PWWidgetNotesInterfaceAdd) return;
	
	if (_addViewControllers == nil) {
		PWWidgetNotesAddViewController *addViewController = [PWWidgetNotesAddViewController new];
		_addViewControllers = [@[addViewController] copy];
	}
	
	[self setViewControllers:_addViewControllers animated:YES];
	_currentInterface = PWWidgetNotesInterfaceAdd;
}

- (void)switchToListInterface {
	
	if (_currentInterface == PWWidgetNotesInterfaceList) return;
	
	if (_listViewControllers == nil) {
		PWWidgetNotesListViewController *listViewController = [PWWidgetNotesListViewController new];
		_listViewControllers = [@[listViewController] copy];
	}
	
	[self setViewControllers:_listViewControllers animated:YES];
	_currentInterface = PWWidgetNotesInterfaceList;
}

- (void)dealloc {
	RELEASE(_dateFormatter)
	RELEASE(_addViewControllers)
	RELEASE(_listViewControllers)
	[super dealloc];
}

@end