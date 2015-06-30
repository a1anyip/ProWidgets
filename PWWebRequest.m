//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWWebRequest.h"
#import "PWWebRequestFileFormData.h"

@implementation PWWebRequest

// code adopted from https://code.google.com/p/google-toolbox-for-mac/source/browse/trunk/Foundation/GTMNSString%2BURLArguments.m

+ (NSString *)encodeURIComponent:(NSString *)string {
	
	// Encode all the reserved characters, per RFC 3986
	// (<http://www.ietf.org/rfc/rfc3986.txt>)
	CFStringRef escaped =
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)string,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
	
	return [(NSString *)escaped autorelease];
}

+ (NSString *)decodeURIComponent:(NSString *)string {
	
	NSMutableString *resultString = [NSMutableString stringWithString:string];
	[resultString replaceOccurrencesOfString:@"+"
								  withString:@" "
									 options:NSLiteralSearch
									   range:NSMakeRange(0, [resultString length])];
	
	return [[[resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy] autorelease];
}

+ (instancetype)sendRequestWithURL:(NSURL *)url {
	return [self sendRequestWithURL:url method:nil params:nil headers:nil completionHandler:nil];
}

+ (instancetype)sendRequestWithURL:(NSURL *)url completionHandler:(PWWebRequestBlock)completionHandler {
	return [self sendRequestWithURL:url method:nil params:nil headers:nil completionHandler:completionHandler];
}

+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method completionHandler:(PWWebRequestBlock)completionHandler {
	return [self sendRequestWithURL:url method:method params:nil headers:nil completionHandler:completionHandler];
}

+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params completionHandler:(PWWebRequestBlock)completionHandler {
	return [self sendRequestWithURL:url method:method params:params headers:nil completionHandler:completionHandler];
}

+ (instancetype)sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params headers:(NSDictionary *)headers completionHandler:(PWWebRequestBlock)completionHandler {
	
	PWWebRequest *request = [self new];
	[request _setCompletionHandler:completionHandler];
	[request _sendRequestWithURL:url method:method params:params headers:headers];
	
	return [request autorelease];
}

- (void)cancel {
	[_connection cancel];
}

// private methods
- (void)_setCallback:(JSManagedValue *)callback {
	
	[_callback release], _callback = nil;
	[_completionHandler release], _completionHandler = nil;
	
	_useJSBridge = YES;
	_callback = [callback retain];
}

- (void)_setCompletionHandler:(PWWebRequestBlock)completionHandler {
	
	[_callback release], _callback = nil;
	[_completionHandler release], _completionHandler = nil;
	
	_useJSBridge = NO;
	_completionHandler = [completionHandler copy];
}

- (void)_sendRequestWithURL:(NSURL *)url method:(NSString *)method params:(id)params headers:(NSDictionary *)headers {
	
	method = [method uppercaseString];
	method = (method == nil ? @"GET" : method);
	
	BOOL isPost = [method isEqualToString:@"POST"];
	BOOL useMultipart = NO;
	
	// initialize response data
	_response = [NSMutableData new];
	
	// configure request
	_request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
	
	// set request method
	[_request setHTTPMethod:method];
	
	// set default headers
	[_request setValue:PWWebRequestDefaultAccept forHTTPHeaderField:@"Accept"];
	[_request setValue:PWWebRequestDefaultUserAgent forHTTPHeaderField:@"User-Agent"];
	[_request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	if (isPost) {
		[_request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	}
	
	// set request headers
	NSString *key = nil;
	NSEnumerator *enumerator = [headers keyEnumerator];
	while ((key = [enumerator nextObject])) {
		
		NSString *value = [headers objectForKey:key];
		if (![key isKindOfClass:[NSString class]] || [key length] == 0 || (value != nil && ![value isKindOfClass:[NSString class]])) continue;
		
		// set header value
		[_request setValue:value forHTTPHeaderField:key];
		
		// check if this is "Content-Type"
		if (isPost && [[key lowercaseString] isEqualToString:@"content-type"] && [value hasPrefix:@"multipart/form-data"]) {
			useMultipart = YES;
		}
	}
	
	// set request body
	NSData *bodyContent = nil;
	if ([params isKindOfClass:[NSString class]]) {
		bodyContent = [self _processBodyContentForString:(NSString *)params];
	} else if ([params isKindOfClass:[NSDictionary class]]) {
		bodyContent = [self _processBodyContentForDictionary:(NSDictionary *)params useMultipart:useMultipart];
	}
	
	if (bodyContent != nil) {
		LOG(@"PWWebRequest: body content (total %lu bytes)\n%@", (unsigned long)[bodyContent length], [[[NSString alloc] initWithData:bodyContent encoding:NSUTF8StringEncoding] autorelease]);
		[_request setHTTPBody:bodyContent];
	}
	
	// configure connection
	_connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self startImmediately:YES];
}

- (NSData *)_processBodyContentForString:(NSString *)string {
	return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)_processBodyContentForDictionary:(NSDictionary *)dictionary useMultipart:(BOOL)useMultipart {
	
	if (useMultipart) {
		
		NSMutableData *body = [NSMutableData data];
		NSString *boundary = @"PWWebRequest";
		NSData *boundaryData = [[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
		
		NSString *key = nil;
		NSEnumerator *enumerator = [dictionary keyEnumerator];
		while ((key = [enumerator nextObject])) {
			
			id value = [dictionary objectForKey:key];
			
			BOOL isString = [value isKindOfClass:[NSString class]];
			BOOL isFileFormData = [value isKindOfClass:[PWWebRequestFileFormData class]];
			
			if (![key isKindOfClass:[NSString class]] || [key length] == 0 || (value != nil && !isString && !isFileFormData)) continue;
			
			// append the beginning boundary line for each form data
			[body appendData:boundaryData];
			
			if (isString) {
				
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
				[body appendData:[(NSString *)value dataUsingEncoding:NSUTF8StringEncoding]];
				
			} else if (isFileFormData) {
				
				PWWebRequestFileFormData *formData = (PWWebRequestFileFormData *)value;
				
				// retrieve basic information and file data
				NSString *filename = formData.filename;
				NSString *contentType = formData.contentType;
				NSData *fileData = [formData readData];
				
				// use blank file name, if nil
				if (filename == nil) filename = @"";
				
				// use default content type
				if (contentType == nil) contentType = @"application/octet-stream";
				
				// append form name and file name
				[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename] dataUsingEncoding:NSUTF8StringEncoding]];
				
				// append content type
				[body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", contentType] dataUsingEncoding:NSUTF8StringEncoding]];
				
				// append file content
				[body appendData:fileData];
			}
		}
		
		// append the last boundary line
		[body appendData:boundaryData];
		
		return body;
		
	} else {
		
		NSMutableArray *params = [NSMutableArray array];
		NSString *key = nil;
		NSEnumerator *enumerator = [dictionary keyEnumerator];
		while ((key = [enumerator nextObject])) {
			
			NSString *value = [dictionary objectForKey:key];
			if (![key isKindOfClass:[NSString class]] || [key length] == 0 || (value != nil && ![value isKindOfClass:[NSString class]])) continue;
			
			NSString *param = [NSString stringWithFormat:@"%@=%@", [self.class encodeURIComponent:key], [self.class encodeURIComponent:value]];
			[params addObject:param];
		}
		
		return [[params componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
	}
}

- (void)_finishConnection {
	RELEASE(_headers)
	RELEASE(_response)
	RELEASE(_request)
	RELEASE(_connection)
	RELEASE(_callback)
	RELEASE(_completionHandler)
}

///// NSURLConnectionDelegate /////

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	LOG(@"PWWebRequest: didFailWithError <error: %@>", error);
	
	if (_useJSBridge) {
		
		NSString *errMsg = [error localizedDescription];
		if (errMsg == nil) errMsg = @"";
		
		JSValue *callbackFunction = [_callback value];
		if (callbackFunction != nil) {
			[callbackFunction callWithArguments:@[@NO, @0, [NSNull null], [NSNull null], errMsg]];
		}
		
	} else {
		_completionHandler(NO, 0, nil, nil, error);
	}
	
	[self _finishConnection];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
	return YES;
}

///// NSURLConnectionDataDelegate /////

// handle redirection
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	
	if (redirectResponse) {
		NSMutableURLRequest *redirectedRequest = [[_request mutableCopy] autorelease];
		[redirectedRequest setURL:[request URL]];
		return redirectedRequest;
	} else {
		return request;
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	// update status code
	_statusCode = [response isKindOfClass:[NSHTTPURLResponse class]] ? [(NSHTTPURLResponse *)response statusCode] : 0;
	
	// update content encoding
	NSString *encodingName = response.textEncodingName;
	
	if (encodingName == nil)
		_encoding = NSUTF8StringEncoding;
	else
		_encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encodingName));
	
	// update headers
	_headers = [response isKindOfClass:[NSHTTPURLResponse class]] ? [[(NSHTTPURLResponse *)response allHeaderFields] copy] : nil;
	
	LOG(@"PWWebRequest: didReceiveResponse <status code: %d> <encoding: %@> <headers: %@>", _statusCode, encodingName, _headers);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	LOG(@"PWWebRequest: didReceiveData (%lu bytes)", (unsigned long)[data length]);
	[_response appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	LOG(@"PWWebRequest: connectionDidFinishLoading (total %lu bytes)", (unsigned long)[_response length]);
	
	NSString *responseString = [[[NSString alloc] initWithData:_response encoding:_encoding] autorelease];
	
	if (_useJSBridge) {
		
		JSValue *callbackFunction = [_callback value];
		if (callbackFunction != nil) {
			[callbackFunction callWithArguments:@[@YES, @(_statusCode), (_headers == nil ? [NSNull null] : _headers), (responseString == nil ? [NSNull null] : responseString), [NSNull null]]];
		}
		
	} else {
		if (_completionHandler != nil) {
			_completionHandler(YES, _statusCode, _headers, responseString, nil);
		}
	}
	
	[self _finishConnection];
}

- (void)dealloc {
	
	DEALLOCLOG;
	
	[self _finishConnection];
	[super dealloc];
}

@end