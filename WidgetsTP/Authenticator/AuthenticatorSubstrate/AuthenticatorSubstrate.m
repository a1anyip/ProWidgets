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
				
				NSMutableArray *records = [NSMutableArray array];
				
				// retrieve records from store
				OTPStore *store = [objc_getClass("OTPStore") new];
				NSArray *authURLs = store.authURLs;
				
				for (OTPAuthURL *authURL in authURLs) {
					
					// name
					NSString *name = authURL.name;
					
					// issuer
					NSString *issuer = authURL.issuer;
					
					// verification code
					OTPGenerator *generator = authURL.generator;
					NSString *code = [generator generateOTP];
					
					// get the period
					NSTimeInterval period = generator.period;
					
					NSDictionary *record = @{ @"name": SAFE_TEXT(name),
											  @"issuer": SAFE_TEXT(issuer),
											  @"code": SAFE_TEXT(code),
											  @"period": @(period)
											  };
					
					[records addObject:record];
				}
				
				[store release];
				
				return @{ @"dataAvailable": @(dataAvailable), @"records": records };
			}
			
			return nil;
		}];
		
	}
}