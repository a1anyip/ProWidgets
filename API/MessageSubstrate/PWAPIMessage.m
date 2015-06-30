//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "interface.h"
#import <objcipc/objcipc.h>
/*
%hook CKRecipientSearchListController
- (void)_performSearchWithBlock:(id)arg1 { %log; %orig; }
- (BOOL)_serviceColorForRecipients:(id)arg1 { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (id)_statusQueryController { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)beganNetworkActivity { %log; %orig; }
- (void)cancelSearch { %log; %orig; }
- (void)consumeSearchResults:(id)arg1 type:(int)arg2 taskID:(id)arg3 { %log; %orig; }
- (id)currentSearchTaskID { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)defaultiMessageAccount { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)delegate { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)endedNetworkActivity { %log; %orig; }
- (id)enteredRecipients { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)finishedSearchingForType:(int)arg1 { %log; %orig; }
- (void)finishedTaskWithID:(id)arg1 { %log; %orig; }
- (BOOL)hasSearchResults { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (void)invalidateOutstandingIDStatusRequests { %log; %orig; }
- (BOOL)isSearchResultsHidden { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (int)pendingSearchTypes { %log; int r = %orig; NSLog(@" = %d", r); return r; }
- (void)removeRecipientFromSearchResults:(id)arg1 { %log; %orig; }
- (id)searchIDSStatuses { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)searchManager { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)searchResults { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)searchResultsModel { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)searchText { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)searchWithText:(id)arg1 { %log; %orig; }
- (void)setCurrentSearchTaskID:(id)arg1 { %log; %orig; }
- (void)setDefaultiMessageAccount:(id)arg1 { %log; %orig; }
- (void)setDelegate:(id)arg1 { %log; %orig; }
- (void)setEnteredRecipients:(id)arg1 { %log; %orig; }
- (void)setIdsQueryStartTime:(id)arg1 { %log; %orig; }
- (void)setPendingSearchTypes:(int)arg1 { %log; %orig; }
- (void)setSearchIDSStatuses:(id)arg1 { %log; %orig; }
- (void)setSearchManager:(id)arg1 { %log; %orig; }
- (void)setSearchResults:(id)arg1 { %log; %orig; }
- (void)setSearchResultsModel:(id)arg1 { %log; %orig; }
- (void)setSearchText:(id)arg1 { %log; %orig; }
- (void)setShouldDisplayGroupSuggestionCells:(BOOL)arg1 { %log; %orig; }
- (void)setStatusQueryController:(id)arg1 { %log; %orig; }
- (BOOL)shouldDisplayGroupSuggestionCells { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (id)statusQueryController { %log; id r = %orig; NSLog(@" = %@", r); return r; }
%end
*/

@class MFContactsSearchManager, MFContactsSearchResultsModel;

@interface MFContactsSearchManager : NSObject

- (id)initWithAddressBook:(void *)arg1 properties:(NSInteger *)arg2 propertyCount:(NSUInteger)arg3 recentsBundleIdentifier:(id)arg4;

- (NSNumber *)searchForText:(id)arg1 consumer:(id)arg2;
- (void)setSearchTypes:(NSUInteger)arg1;
- (void)cancelTaskWithID:(NSNumber *)arg1;

@end

@interface MFContactsSearchResultsModel : NSObject

- (id)initWithFavorMobileNumbers:(BOOL)arg1;
- (id)initWithResultTypeSortOrderComparator:(id)arg1 resultTypePriorityComparator:(id)arg2 favorMobileNumbers:(BOOL)arg3;

- (void)addResults:(id)arg1 ofType:(NSInteger)arg2;
- (void)processAddedResultsOfType:(NSInteger)arg1 completion:(id)arg2;
- (void)setEnteredRecipients:(id)arg1;
- (void)reset;

@end

extern NSArray *CKPreferredAddressTypes();

@interface TEST : NSObject {
	
	MFContactsSearchManager *_searchManager;
	MFContactsSearchResultsModel *_searchResultsModel;
	NSNumber *_currentTaskID;
}

@end

@implementation TEST

- (instancetype)init {
	if ((self = [super init])) {
		
		NSUInteger propertyCount = 0;
		
		//int properties[2] = { 3, 4 };
		NSArray *_properties = CKPreferredAddressTypes(); // an array containing NSNumber
		NSInteger *properties = malloc(sizeof(NSInteger) * [_properties count]);
		
		for (NSNumber *property in _properties) {
			NSInteger propertyInt = [property integerValue];
			properties[propertyCount++] = propertyInt;
		}
		
		_searchManager = [[MFContactsSearchManager alloc] initWithAddressBook:NULL properties:properties propertyCount:propertyCount recentsBundleIdentifier:@"com.apple.MobileSMS"];
		[_searchManager setSearchTypes:7];
		
		_searchResultsModel = [[MFContactsSearchResultsModel alloc] initWithFavorMobileNumbers:YES];
		
		free(properties);
		
		// perform searching
		[self cancelSearch];
		[_searchResultsModel reset];
		[_searchManager setSearchTypes:7];
		_currentTaskID = [[_searchManager searchForText:@"jeff" consumer:self] copy];
	}
	return self;
}

- (void)cancelSearch {
	if (_currentTaskID != nil) {
		[_searchManager cancelTaskWithID:_currentTaskID];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		RELEASE(_currentTaskID)
	}
}

- (void)beganNetworkActivity {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)endedNetworkActivity {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)consumeSearchResults:(id)results type:(NSInteger)type taskID:(NSNumber *)taskID {
	LOG(@"consumeSearchResults: %@ / type: %d / taskID: %@", results, (int)type, taskID);
}

- (void)finishedSearchingForType:(NSInteger)type {
	LOG(@"finishedSearchingForType: %d", (int)type);
}

- (void)finishedTaskWithID:(NSNumber *)taskID {
	LOG(@"finishedTaskWithID: %@ <current: %@>", taskID, _currentTaskID);
}

@end

%hook CKRecipientSearchListController

- (void)consumeSearchResults:(id)results type:(int)type taskID:(NSNumber *)taskID {
	%log;
	%orig;
}

- (void)finishedSearchingForType:(int)type {
	%log;
	%orig;
}

- (void)finishedTaskWithID:(NSNumber *)taskID {
	LOG(@"Instance: %@", self);
	%log;
	%orig;
}

%end

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"PWAPIMessage" handler:^NSDictionary *(NSDictionary *dict) {
			
			NSString *action = dict[@"action"];
			
			LOG(@"PWAPIMessage: Received action (%@)", action);
			
			if ([action isEqualToString:@"sendMessage"]) {
				
				NSString *content = dict[@"content"];
				NSArray *recipientAddresses = dict[@"recipients"];
				NSMutableArray *recipients = [NSMutableArray array];
				
				// convert recipient addresses into entities
				for (NSString *address in recipientAddresses) {
					CKEntity *entity = [objc_getClass("CKEntity") copyEntityForAddressString:address];
					if (entity != nil)
						[recipients addObject:entity];
				}
				
				LOG(@"PWAPIMessage: Send message <recipients: %@> <content: %@>", recipients, content);
				
				if ([recipients count] == 0) return nil;
				
				// retrieve the conversation
				CKConversationList *conversationList = [objc_getClass("CKConversationList") sharedConversationList];
				CKConversation *conversation = [conversationList conversationForRecipients:recipients create:YES];
				
				// construct composition
				NSAttributedString *text = [[NSAttributedString alloc] initWithString:content];
				CKComposition *composition = [[objc_getClass("CKComposition") alloc] initWithText:text subject:nil];
				[text release];
				
				// construct message
				CKIMMessage *message = [conversation newMessageWithComposition:composition];
				[composition release];
				
				// send the message
				[conversation sendMessage:message newComposition:YES];
			}
			
			return nil;
		}];
		
	}
}