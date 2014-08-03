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

- (NoteContext *)noteContext {
	return [PWWidgetNotes widget].noteContext;
}

- (void)titleTapped {
	[[PWWidgetNotes widget] switchToListInterface];
}

- (void)fetchStores {
	
	// fetch all calendars
	NoteContext *noteContext = self.noteContext;
	NSArray *stores = [noteContext allStores];
	NoteStoreObject *defaultStore = [noteContext defaultStoreForNewNote];
	NSUInteger defaultStoreIndex = 0;
	
	if ([stores count] == 0) {
		[self.widget showMessage:@"You need at least one store to save notes." title:nil handler:^{
			[self.widget dismiss];
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
		
		if ([store isEqual:defaultStore]) {
			defaultStoreIndex = i;
		}
		
		[titles addObject:accountName];
		[values addObject:@(i++)];
	}
	
	PWWidgetItemListValue *item = (PWWidgetItemListValue *)[self itemWithKey:@"account"];
	[item setListItemTitles:titles values:values];
	[item setValue:@[@(defaultStoreIndex)]];
	
	_stores = [stores retain];
}

#define REPLACE(a,b,c) a = [a stringByReplacingOccurrencesOfString:b withString:c];

- (void)submitEventHandler:(NSDictionary *)values {
	
	NSString *content = values[@"content"];
	unsigned int selectedAccountIndex = [(values[@"account"])[0] unsignedIntValue];
	
	if ([content length] == 0) {
		[self.widget showMessage:@"Note content cannot be empty."];
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
	NoteContext *noteContext = self.noteContext;
	NSManagedObjectContext *context = [noteContext managedObjectContext];
	
	// store
	NSArray *stores = [noteContext allStores];
	NoteStoreObject *store = selectedAccountIndex >= [stores count] ? [noteContext defaultStoreForNewNote] : [stores objectAtIndex:selectedAccountIndex];
	
	NoteObject *note = [objc_getClass("NSEntityDescription") insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];
	NoteBodyObject *body = [objc_getClass("NSEntityDescription") insertNewObjectForEntityForName:@"NoteBody" inManagedObjectContext:context];
	
	// set body parameters
	NSString *bodyContent = content;
	
	REPLACE(bodyContent, @"<", @"&lt;")
	REPLACE(bodyContent, @">", @"&gt;")
	REPLACE(bodyContent, @" ", @"&nbsp;")
	REPLACE(bodyContent, @"\n", @"<br>")
	
	body.content = bodyContent;
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
	
	// dismiss the widget
	[self.widget dismiss];
}

#undef REPLACE

- (void)dealloc {
	RELEASE(_stores)
	[super dealloc];
}

@end