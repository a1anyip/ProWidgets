@class NoteObject, NoteStoreObject;

// Notes.framework
@interface NoteContext : NSObject

- (void)clearCaches;
- (void)enableChangeLogging:(BOOL)enabled;
- (NSArray *)allVisibleNotes;
- (NSArray *)allNotes;

- (NoteStoreObject *)defaultStoreForNewNote;
- (NSArray *)allStores;
- (NoteStoreObject *)localStore;

- (NoteObject *)newlyAddedNote;
- (NSArray *)notesForIntegerIds:(NSArray *)ids;
- (void)deleteNote:(NoteObject *)note;

- (BOOL)save:(NSError **)error;
- (BOOL)saveOutsideApp:(NSError **)error;

@end

@interface NoteAccountObject : NSObject

@property(nonatomic, retain) NSString *name;

@end

@interface NoteStoreObject : NSObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NoteAccountObject *account;

@end

@interface NoteObject : NSObject

@property(retain, nonatomic) NoteStoreObject *store;
@property(retain, nonatomic) NSNumber *integerId;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *summary;
@property(retain, nonatomic) id body;
@property(retain, nonatomic) NSDate *creationDate;
@property(retain, nonatomic) NSDate *modificationDate;
@property(retain, nonatomic) NSString *content;

- (NSString *)contentAsPlainText;
- (NSString *)contentAsPlainTextPreservingNewlines;

@end

@interface NoteBodyObject : NSObject

@property(retain, nonatomic) id content;
@property(retain, nonatomic) id owner;

@end