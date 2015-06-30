//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../header.h"
#import "../JSBridge/PWJSBridgeWrapper.h"
#import "NoteInterface.h"

@class PWAPINoteManagerWrapper, PWAPINoteWrapper, PWAPINoteManager, PWAPINote;

@protocol PWAPINoteManagerWrapperExport <JSExport>

// retrieve note objects
- (NSArray *)allNotes;
- (PWAPINoteWrapper *)getById:(JSValue *)noteId;

// add a new note
- (PWAPINoteWrapper *)add:(JSValue *)content :(JSValue *)creationDate :(JSValue *)store;

// remove notes
- (void)remove:(JSValue *)note;

// retrieve note stores
- (NSArray *)allStores;
- (NoteStoreObject *)defaultStore;
- (NoteStoreObject *)localStore;

@end

@protocol PWAPINoteWrapperExport <JSExport>

@property(nonatomic, readonly) NSUInteger noteId;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, copy) JSValue *content;
@property(nonatomic, retain) JSValue *creationDate;
@property(nonatomic, retain) JSValue *modificationDate;

@end

@interface PWAPINoteManagerWrapper : PWJSBridgeWrapper<PWAPINoteManagerWrapperExport>
@end

@interface PWAPINoteWrapper : PWJSBridgeWrapper<PWAPINoteWrapperExport> {
	
	PWAPINote *_note;
}

+ (instancetype)wrapperOfNote:(PWAPINote *)note;

- (PWAPINote *)_note;
- (void)_setNote:(PWAPINote *)note;

@end

static NoteContext *noteContext = nil;

// This is the note manager
@interface PWAPINoteManager : NSObject

// retrieve note objects
+ (NSArray *)allNotes;
+ (PWAPINote *)noteWithId:(NSUInteger)noteId;
+ (void)removeNoteWithId:(NSUInteger)noteId;
+ (void)removeNote:(PWAPINote *)note;

// add a new note
+ (PWAPINote *)addNoteWithContent:(NSString *)content;
+ (PWAPINote *)addNoteWithContent:(NSString *)content creationDate:(NSDate *)creationDate;
+ (PWAPINote *)addNoteWithContent:(NSString *)content creationDate:(NSDate *)creationDate store:(NoteStoreObject *)store;

// retrieve note stores
+ (NSArray *)allStores;
+ (NoteStoreObject *)defaultStore;
+ (NoteStoreObject *)localStore;

+ (void)_extractTitleAndSummaryFromContent:(NSString *)content title:(NSString **)titleOut summary:(NSString **)summaryOut;
+ (NSString *)_convertPlainTextToHTML:(NSString *)text;

+ (void)_clearCache;
+ (void)_save;

@end

@interface PWAPINote : NSObject {
	
	NoteObject *_noteObject;
}

@property(nonatomic, readonly) NoteStoreObject *store;
@property(nonatomic, readonly) NSUInteger noteId;
@property(nonatomic, readonly) NSString *title;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, retain) NSDate *creationDate;
@property(nonatomic, retain) NSDate *modificationDate;

+ (instancetype)noteWithObject:(NoteObject *)noteObject;
- (NoteObject *)_noteObject;
- (void)_setNoteObject:(NoteObject *)noteObject;

@end