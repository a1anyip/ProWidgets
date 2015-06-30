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

#define SAFE_TEXT(x) (x == nil ? @"" : x)

typedef enum {
	TimeBased = 1,
	CounterBased = 2
} RecordType;

static inline __attribute__((constructor)) void init() {
	@autoreleasepool {
		
		[OBJCIPC registerIncomingMessageFromSpringBoardHandlerForMessageName:@"GoogleAuthenticator" handler:^NSDictionary *(NSDictionary *dict) {
			
			NSString *action = dict[@"action"];
			
			LOG(@"AuthenticatorSubstrate: Received action (%@)", action);
			
			if ([action isEqualToString:@"retrieve"]) {
				
				BOOL dataAvailable = [UIApplication sharedApplication].protectedDataAvailable;
				
				if (!dataAvailable) {
					return @{ @"dataAvailable": @(NO) };
				}
				
				BOOL firstTime = [dict[@"firstTime"] boolValue];
				NSMutableArray *records = [NSMutableArray array];
				
				// retrieve records from store
				OTPStore *store = [objc_getClass("OTPStore") new];
				NSArray *authURLs = store.authURLs;
				
				for (OTPAuthURL *authURL in authURLs) {
					
					// type
					RecordType type = [authURL isKindOfClass:objc_getClass("HOTPAuthURL")] ? CounterBased : TimeBased;
					
					// name
					NSString *name = authURL.name;
					
					// issuer
					NSString *issuer = authURL.issuer;
					
					// generate next OTP code, if needed
					if (firstTime || type == TimeBased) {
						[authURL generateNextOTPCode];
					}
					
					// retrieve the latest OTP code
					NSString *code = [authURL otpCode];
					
					// get the period
					NSTimeInterval period = 0.0;
					if (type == TimeBased) {
						OTPGenerator *generator = authURL.generator;
						period = generator.period;
					}
					
					NSDictionary *record = @{ @"type": @(type),
											  @"name": SAFE_TEXT(name),
											  @"issuer": SAFE_TEXT(issuer),
											  @"code": SAFE_TEXT(code),
											  @"period": @(period)
											  };
					
					[records addObject:record];
				}
				
				[store release];
				
				return @{ @"dataAvailable": @(dataAvailable), @"records": records };
				
			} else if ([action isEqualToString:@"refresh"]) {
				
				BOOL dataAvailable = [UIApplication sharedApplication].protectedDataAvailable;
				if (!dataAvailable) goto fail;
				
				NSNumber *_index = dict[@"index"];
				if (_index == nil) goto fail;
				
				NSUInteger index = [_index unsignedIntegerValue];
				
				// retrieve records from store
				OTPStore *store = [objc_getClass("OTPStore") new];
				NSArray *authURLs = store.authURLs;
				
				if ([authURLs count] <= index) {
					[store release];
					goto fail;
				}
				
				OTPAuthURL *authURL = authURLs[index];
				if (![authURL isKindOfClass:objc_getClass("HOTPAuthURL")]) {
					[store release];
					goto fail;
				}
				
				[authURL generateNextOTPCode];
				[store release];
				
				return @{ @"success": @(YES) };
				
			fail:
				return @{ @"success": @(NO) };
			}
			
			return nil;
		}];
		
	}
}