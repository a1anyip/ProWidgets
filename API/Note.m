//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Note.h"
#import "../PWController.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import <objcipc/objcipc.h>

@implementation PWAPINoteManagerWrapper

- (NSArray *)allNotes {
	
	[PWAPINoteManager _clearCache];
	NSArray *notes = [[noteContext allNotes] copy];
	
	NSMutableArray *result = [NSMutableArray array];
	for (NoteObject *note in notes) {
		PWAPINote *object = [PWAPINote noteWithObject:note];
		PWAPINoteWrapper *wrapper = [PWAPINoteWrapper wrapperOfNote:object];
		if (wrapper != nil)
			[result addObject:wrapper];
	}
	
	[notes release];

	return result;
}

- (PWAPINoteWrapper *)getById:(JSValue *)noteId {
	
	if ([noteId isUndefined]) {
		[_bridge throwException:@"getById: requires argument 1 (note ID)"];
		return nil;
	}
	
	NSNumber *_noteIdNumber = [noteId toNumber];
	NSUInteger _noteId = [_noteIdNumber unsignedIntegerValue];
	PWAPINote *note = [PWAPINoteManager noteWithId:_noteId];
	return [PWAPINoteWrapper wrapperOfNote:note];
}

- (PWAPINoteWrapper *)add:(JSValue *)content :(JSValue *)creationDate :(JSValue *)store {
	
	if ([content isUndefined]) {
		[_bridge throwException:@"add: requires first argument (content)"];
		return nil;
	}
	
	NSString *_content = [content isNull] ? nil : [content toString];
	NSDate *_creationDate = [creationDate isUndefined] ? nil : [creationDate toDate];
	NoteStoreObject *_store = [store isUndefined] ? nil : [store toObjectOfClass:[NoteStoreObject class]];
	
	PWAPINote *note = [PWAPINoteManager addNoteWithContent:_content creationDate:_creationDate store:_store];
	return [PWAPINoteWrapper wrapperOfNote:note];
}

- (void)remove:(JSValue *)note {
	
	if ([note isUndefined]) {
		[_bridge throwException:@"remove: requires argument 1 (note ID or object)"];
		return;
	}
	
	PWAPINoteWrapper *wrapper = (PWAPINoteWrapper *)[note toObjectOfClass:[PWAPINoteWrapper class]];
	
	if (wrapper != nil) {
		[PWAPINoteManager removeNote:wrapper._note];
	} else {
		NSNumber *noteIdNumber = [note toNumber];
		NSUInteger noteId = [noteIdNumber unsignedIntegerValue];
		[PWAPINoteManager removeNoteWithId:noteId];
	}
}

- (NSArray *)allStores {
	return [PWAPINoteManager allStores];
}

- (NoteStoreObject *)defaultStore {
	return [PWAPINoteManager defaultStore];
}

- (NoteStoreObject *)localStore {
	return [PWAPINoteManager localStore];
}

- (void)dealloc {
	DEALLOCLOG;
	[super dealloc];
}

@end

@implementation PWAPINoteWrapper

+ (instancetype)wrapperOfNote:(PWAPINote *)note {
	if (note == nil) return nil;
	PWAPINoteWrapper *wrapper = [self new];
	[wrapper _setNote:note];
	return [wrapper autorelease];
}

- (PWAPINote *)_note {
	return _note;
}

- (void)_setNote:(PWAPINote *)note {
	if (_note != nil) return;
	_note = [note retain];
}

- (NSUInteger)noteId {
	return _note.noteId;
}

- (NSString *)title {
	return _note.title;
}

- (JSValue *)content {
	return [JSValue valueWithObject:_note.content inContext:[JSContext currentContext]];
}

- (void)setContent:(JSValue *)value {
	_note.content = [value isUndefined] || [value isNull] ? nil : [value toString];
}

- (JSValue *)creationDate {
	return [JSValue valueWithObject:_note.creationDate inContext:[JSContext currentContext]];
}

- (void)setCreationDate:(JSValue *)value {
	_note.creationDate = [value toDate];
}

- (JSValue *)modificationDate {
	return [JSValue valueWithObject:_note.modificationDate inContext:[JSContext currentContext]];
}

- (void)setModificationDate:(JSValue *)value {
	_note.modificationDate = [value toDate];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_note)
	[super dealloc];
}

@end

@implementation PWAPINoteManager

+ (void)load {
	
	CHECK_API();
	
	noteContext = [NoteContext new];
	[noteContext enableChangeLogging:YES];
}

+ (NSArray *)allNotes {
	
	[self _clearCache];
	NSArray *notes = [[noteContext allNotes] copy];
	
	NSMutableArray *result = [NSMutableArray array];
	for (NoteObject *note in notes) {
		PWAPINote *object = [PWAPINote noteWithObject:note];
		[result addObject:object];
	}
	
	[notes release];
	
	return result;
}

+ (PWAPINote *)noteWithId:(NSUInteger)noteId {
	
	NSArray *objects = [noteContext notesForIntegerIds:@[@(noteId)]];
	if (objects != nil && [objects count] > 0) {
		NoteObject *object = objects[0];
		PWAPINote *note = [PWAPINote noteWithObject:object];
		return note;
	} else {
		return nil;
	}
}

+ (PWAPINote *)addNoteWithContent:(NSString *)content {
	return [self addNoteWithContent:content creationDate:nil];
}

+ (PWAPINote *)addNoteWithContent:(NSString *)content creationDate:(NSDate *)creationDate {
	return [self addNoteWithContent:content creationDate:creationDate store:nil];
}

+ (PWAPINote *)addNoteWithContent:(NSString *)content creationDate:(NSDate *)creationDate store:(NoteStoreObject *)store {
	
	if (content == nil) content = @"";
	if (creationDate == nil) creationDate = [NSDate date];
	if (store == nil) store = [self defaultStore];
	
	NSString *title = nil;
	NSString *summary = nil;
	[self _extractTitleAndSummaryFromContent:content title:&title summary:&summary];
	
	NoteObject *object = [noteContext newlyAddedNote];
	object.title = title;
	object.summary = summary;
	object.content = [self _convertPlainTextToHTML:content];
	object.creationDate = creationDate;
	object.modificationDate = creationDate;
	object.store = store;
	
	[self _save];
	
	return [PWAPINote noteWithObject:object];
}

+ (void)removeNoteWithId:(NSUInteger)noteId {
	
	NSArray *objects = [noteContext notesForIntegerIds:@[@(noteId)]];
	if (objects != nil && [objects count] > 0) {
		NoteObject *object = objects[0];
		[noteContext deleteNote:object];
		[self _save];
	}
}

+ (void)removeNote:(PWAPINote *)note {
	
	NoteObject *object = note._noteObject;
	if (object != nil) {
		[noteContext deleteNote:object];
		[self _save];
	}
}

+ (NSArray *)allStores {
	return noteContext.allStores;
}

+ (NoteStoreObject *)defaultStore {
	return noteContext.defaultStoreForNewNote;
}

+ (NoteStoreObject *)localStore {
	return noteContext.localStore;
}

+ (void)_extractTitleAndSummaryFromContent:(NSString *)content title:(NSString **)titleOut summary:(NSString **)summaryOut {
	
	NSString *title = nil;
	NSString *summary = nil;
	
	// extract title and summary from content
	NSString *_trimmedText = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *parts = [_trimmedText componentsSeparatedByString:@"\n"];
	if ([parts count] == 1) {
		title = [parts objectAtIndex:0];
		summary = @"";
	} else if ([parts count] >= 2) {
		title = [parts objectAtIndex:0];
		summary = [parts objectAtIndex:1];
	}
	
	// trim title and summary
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	// title and summary MUST NOT be nil
	if (title == nil) title = @"";
	if (summary == nil) summary = @"";
	
	*titleOut = title;
	*summaryOut = summary;
}

#define REPLACE(a,b,c) a = [a stringByReplacingOccurrencesOfString:b withString:c];

+ (NSString *)_convertPlainTextToHTML:(NSString *)text {
	
	// process content
	REPLACE(text, @"<", @"&lt;")
	REPLACE(text, @">", @"&gt;")
	REPLACE(text, @" ", @"&nbsp;")
	REPLACE(text, @"\n", @"<br>")
	
	return text;
}

#undef REPLACE

+ (void)_clearCache {
	[noteContext clearCaches];
}

+ (void)_save {
	[noteContext save:NULL];
}

@end

@implementation PWAPINote

+ (instancetype)noteWithObject:(NoteObject *)noteObject {
	PWAPINote *object = [self new];
	[object _setNoteObject:noteObject];
	return [object autorelease];
}

- (NoteStoreObject *)store {
	return _noteObject.store;
}

- (NSUInteger)noteId {
	return [_noteObject.integerId unsignedIntegerValue];
}

- (NSString *)title {
	return _noteObject.title;
}

- (NSString *)content {
	return _noteObject.contentAsPlainTextPreservingNewlines;
}

- (void)setContent:(NSString *)content {
	
	NSString *title = nil;
	NSString *summary = nil;
	[PWAPINoteManager _extractTitleAndSummaryFromContent:content title:&title summary:&summary];
	
	content = [PWAPINoteManager _convertPlainTextToHTML:content];
	
	_noteObject.title = title;
	_noteObject.summary = summary;
	_noteObject.content = content;
	
	[PWAPINoteManager _save];
}

- (NSDate *)creationDate {
	return _noteObject.creationDate;
}

- (void)setCreationDate:(NSDate *)creationDate {
	_noteObject.creationDate = creationDate;
	[PWAPINoteManager _save];
}

- (NSDate *)modificationDate {
	return _noteObject.modificationDate;
}

- (void)setModificationDate:(NSDate *)modificationDate {
	_noteObject.modificationDate = modificationDate;
	[PWAPINoteManager _save];
}

- (NoteObject *)_noteObject {
	return _noteObject;
}

- (void)_setNoteObject:(NoteObject *)noteObject {
	if (_noteObject != nil) return;
	_noteObject = [noteObject retain];
}

- (void)dealloc {
	DEALLOCLOG;
	RELEASE(_noteObject)
	[super dealloc];
}

@end