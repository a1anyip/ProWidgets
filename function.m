#import "objc/objc.h"
#import "objc/runtime.h"
#import "PWController.h"
#import "PWWidgetController.h"
#import <objcipc/IPC.h>

void PWPresentWidget(NSString *name, NSDictionary *userInfo) {
	
	if (name == nil) return;
	
	if (objc_getClass("SpringBoard") != nil) {
		[PWWidgetController presentWidgetNamed:name userInfo:userInfo];
	} else {
		NSDictionary *dictionary = nil;
		if (userInfo != nil) {
			dictionary = @{ @"name": name, @"userInfo": userInfo };
		} else {
			dictionary = @{ @"name": name };
		}
		[OBJCIPC sendMessageToSpringBoardWithMessageName:@"prowidgets.presentwidget" dictionary:dictionary replyHandler:nil];
	}
}