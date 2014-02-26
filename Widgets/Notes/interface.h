@interface NSEntityDescription : NSObject

+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(id)context;

@end

// Notes.framework
@interface NoteContext : NSObject

- (NSArray *)allVisibleNotes;

- (id)managedObjectContext;
- (id)defaultStoreForNewNote;
- (id)allStores;
- (id)nextIndex;
- (void)enableChangeLogging:(BOOL)enabled;
- (void)deleteNote:(id)note;
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

@property(retain, nonatomic) id store;
@property(retain, nonatomic) id integerId;
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