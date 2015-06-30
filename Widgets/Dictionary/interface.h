@class _UIDefinitionDictionary, _UIDictionaryManager, _UIDefinitionValue, ASAsset;

@interface _UIDefinitionDictionary : NSObject

@property(readonly) ASAsset *rawAsset;

@end

@interface _UIDictionaryManager : NSObject {
    NSArray *_availableDefinitionDictionaries;
}

@property(readonly) NSArray * availableDefinitionDictionaries;

+ (id)_filteredDictionaryIDs;
+ (instancetype)assetManager;
+ (void)initialize;

- (id)_allAvailableDefinitionDictionariesUsingRemoteInfo:(BOOL)arg1;
- (id)_availableDictionaryAssets;
- (id)_availableDictionaryAssetsUsingRemoteInfo:(BOOL)arg1;
- (id)_currentlyAvailableDefinitionDictionaries;
- (NSArray *)_definitionValuesForTerm:(id)arg1;
- (BOOL)_hasDefinitionForTerm:(id)arg1;
- (id)availableDefinitionDictionaries;
- (void)dealloc;
- (id)init;

@end

@interface _UIDefinitionValue : NSObject {
    NSAttributedString *_definition;
    NSString *_localizedDictionaryName;
    NSString *_longDefinition;
    id _rawAsset;
    NSString *_term;
}

@property(readonly) NSAttributedString * definition;
@property(readonly) NSString * localizedDictionaryName;
@property(readonly) NSString * longDefinition;
@property(retain) id rawAsset;
@property(readonly) NSString * term;

- (void)dealloc;
- (id)definition;
- (id)description;
- (id)initWithLocalizedDictionaryName:(id)arg1 term:(id)arg2 definition:(id)arg3 longDefinition:(id)arg4;
- (id)localizedDictionaryName;
- (id)longDefinition;
- (id)rawAsset;
- (void)setRawAsset:(id)arg1;
- (id)term;

@end

@interface ASAsset : NSObject

- (NSInteger)state;

@end