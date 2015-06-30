#import "objc/objc.h"
#import "objc/runtime.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

inline BOOL PWPresentWidget(NSString *name, NSDictionary *userInfo) {

	if (name == nil) return NO;

	if (objc_getClass("SpringBoard") != nil) {
		return [objc_getClass("PWWidgetController") presentWidgetNamed:name userInfo:userInfo];
	} else {
		NSDictionary *dictionary = nil;
		if (userInfo != nil) {
			dictionary = @{ @"name": name, @"userInfo": userInfo };
		} else {
			dictionary = @{ @"name": name };
		}
		return [objc_getClass("OBJCIPC") sendMessageToSpringBoardWithMessageName:@"prowidgets.presentwidget" dictionary:dictionary replyHandler:nil];
	}
}
