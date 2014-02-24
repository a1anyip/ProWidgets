//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "header.h"

#define PWWebRequestDefaultAccept @"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"

#define PWWebRequestDefaultUserAgent @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.73.11 (KHTML, like Gecko) Version/7.0.1 Safari/537.73.11"

typedef void (^PWWebRequestBlock)(BOOL success, int statusCode, NSString *response, NSError *error);

@protocol PWWebRequestExport <JSExport>

- (void)cancel;

@end

@interface PWWebRequest : NSObject<PWWebRequestExport, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
	
	// request and connection
	NSMutableURLRequest *_request;
	NSURLConnection *_connection;
	
	// response
	int _statusCode;
	NSStringEncoding _encoding;
	NSMutableData *_response;
	
	// callback
	BOOL _useJSBridge;
	JSManagedValue *_callback;
	PWWebRequestBlock _completionHandler;
}

// helper methods
+ (NSString *)encodeURIComponent:(NSString *)string;
+ (NSString *)decodeURIComponent:(NSString *)string;

+ (instancetype)sendRequestWithURL:(NSURL *)url;
+ (instancetype)sendRequestWithURL:(NSURL *)url completionHandler:(PWWebRequestBlock)completionHandler;
+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method completionHandler:(PWWebRequestBlock)completionHandler;
+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params completionHandler:(PWWebRequestBlock)completionHandler;
+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params headers:(NSDictionary *)headers completionHandler:(PWWebRequestBlock)completionHandler;

- (void)cancel;

// private methods
- (void)_setCallback:(JSManagedValue *)callback;
- (void)_setCompletionHandler:(PWWebRequestBlock)completionHandler;
- (void)_sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params headers:(NSDictionary *)headers;

- (NSData *)_processBodyContentForString:(NSString *)string;
- (NSData *)_processBodyContentForDictionary:(NSDictionary *)dictionary useMultipart:(BOOL)useMultipart;

- (void)_finishConnection;

@end