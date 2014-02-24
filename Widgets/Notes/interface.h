@interface NSEntityDescription : NSObject

+ (id)insertNewObjectForEntityForName:(NSString *)entityName inManagedObjectContext:(id)context;

@end

// Notes.framework
@interface NoteContext : NSObject

- (id)managedObjectContext;
- (id)defaultStoreForNewNote;
- (id)allStores;
- (id)nextIndex;
- (void)enableChangeLogging:(BOOL)arg1;
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
@property(retain, nonatomic) id title;
@property(retain, nonatomic) id summary;
@property(retain, nonatomic) id body;
@property(retain, nonatomic) id creationDate;
@property(retain, nonatomic) id modificationDate;

@end

@interface NoteBodyObject : NSObject

@property(retain, nonatomic) id content;
@property(retain, nonatomic) id owner;

@end