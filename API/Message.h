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

@protocol PWAPIMessageWrapperExport <JSExport>

- (void)send:(JSValue *)content :(JSValue *)recipients;

@end

@interface PWAPIMessageWrapper : PWJSBridgeWrapper<PWAPIMessageWrapperExport>
@end


@interface PWAPIMessage : NSObject

+ (void)sendMessage:(NSString *)content recipients:(NSArray *)recipients;

@end