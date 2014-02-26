//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWWidgetNotes : PWWidget {
	
	NoteContext *_noteContext;
	NSDateFormatter *_dateFormatter;
	
	PWWidgetNotesInterface _currentInterface;
	NSArray *_addViewControllers;
	NSArray *_listViewControllers;
}

- (NSString *)parseDate:(NSDate *)date;
- (NSUInteger)calculateDayDifference:(NSDate *)fromDate toDate:(NSDate *)toDate;

- (NoteContext *)noteContext;
- (NSDateFormatter *)dateFormatter;

- (void)switchToAddInterface;
- (void)switchToListInterface;

@end