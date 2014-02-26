//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Add.h"
#import "Notes.h"

@implementation PWWidgetNotesAddViewController

- (void)load {
	
	[self loadPlist:@"AddItems"];
	
	// fetch the note account list
	[self fetchStores];
	
	// set event handlers
	[self setSubmitEventHandler:self selector:@selector(submitEventHandler:)];
	[self setHandlerForEvent:[PWContentViewController titleTappedEventName] target:self selector:@selector(titleTapped)];
}

- (void)titleTapped {
	PWWidgetNotes *widget = (PWWidgetNotes *)[PWController activeWidget];
	[widget switchToListInterface];
}

- (void)fetchStores {
	
	// fetch all calendars
	NoteContext *noteContext = [objc_getClass("NoteContext") new];
	NSArray *stores = [noteContext allStores];
	
	if ([stores count] == 0) {
		[noteContext release];
		[[PWController activeWidget] showMessage:@"You need at least one store to save notes." title:nil handler:^{
			[[PWController activeWidget] dismiss];
		}];
		return;
	}
	
	NSMutableArray *titles = [NSMutableArray array];
	NSMutableArray *values = [NSMutableArray array];
	
	unsigned int i = 0;
	for (NoteStoreObject *store in stores) {
		
		NoteAccountObject *account = store.account;
		NSString *accountName = account.name;
		
		if ([accountName isEqualToString:@"LOCAL_NOTES_ACCOUNT"])
			accountName = @"Local";
		
		if (accountName == nil) continue;
		
		[titles addObject:accountName];
		[values addObject:@(i++)];
	}
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"account"];
	[item setListItemTitles:titles values:values];
	[item setValue:@[@(0)]];
	
	_stores = [stores retain];
	[noteContext release];
}

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *content = values[@"content"];
	unsigned int selectedAccountIndex = [(values[@"account"])[0] unsignedIntValue];
	
	if ([content length] == 0) {
		[[PWController activeWidget] showMessage:@"Note content cannot be empty."];
		PWWidgetItem *item = [self itemWithKey:@"content"];
		[item becomeFirstResponder];
		return;
	}
	
	// creation and modification date
	NSDate *date = [NSDate date]; // get current date and time
	
	// title and summary
	NSString *_trimmedText = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString *title;
	NSString *summary;
	NSArray *parts = [_trimmedText componentsSeparatedByString:@"\n"];
	if ([parts count] == 1) {
		title = [parts objectAtIndex:0];
		summary = @"";
	} else if ([parts count] >= 2) {
		title = [parts objectAtIndex:0];
		summary = [parts objectAtIndex:1];
	} else { // parts' count is zero, ridiculous?
		return;
	}
	
	// trim title and summary
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// initialize note objects
	NoteContext *noteContext = [[objc_getClass("NoteContext") alloc] init];
	[noteContext enableChangeLogging:YES]; // enable iCloud syncronization support
	NSManagedObjectContext *context = [noteContext managedObjectContext];
	
	// store
	NSArray *stores = [noteContext allStores];
	NoteStoreObject *store = selectedAccountIndex >= [stores count] ? [noteContext defaultStoreForNewNote] : [stores objectAtIndex:selectedAccountIndex];
	
	NoteObject *note = [objc_getClass("NSEntityDescription") insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
	NoteBodyObject *body = [objc_getClass("NSEntityDescription") insertNewObjectForEntityForName:@"NoteBody" inManagedObjectContext:context];
	
	// set body parameters
	body.content = [[content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"] stringByReplacingOccurrencesOfString:@" " withString:@"&nbsp;"]; // Notes app requires HTML code to show wrapped lines
	body.owner = note; // reference to NoteObject
	
	// set note parameters
	note.store = store; // reference to NoteStoreObject
	note.integerId = [noteContext nextIndex];
	note.title = title; // first line
	note.summary = summary; // second line
	note.body = body; // reference to NoteBodyObject
	note.creationDate = date;
	note.modificationDate = date;
	
	// save it
	[noteContext saveOutsideApp:NULL];
	[noteContext release];
	
	[[PWController activeWidget] dismiss];
}

- (void)dealloc {
	RELEASE(_stores)
	[super dealloc];
}

@end