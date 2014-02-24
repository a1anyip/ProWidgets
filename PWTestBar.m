//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWTestBar.h"
#import "PWController.h"
#import "PWWidget.h"
#import "PWWindow.h"

static PWTestBar *sharedInstance = nil;

@implementation PWTestBar

+ (instancetype)sharedInstance {
	
	@synchronized(self) {
		if (sharedInstance == nil)
			[self new];
	}
	
	return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
	@synchronized(self) {
		if (sharedInstance == nil) {
			sharedInstance = [super allocWithZone:zone];
			LOG(@"PWTestBar: allocated shared instance (%@)", sharedInstance);
			return sharedInstance;
		}
	}
	
	return nil;
}

- (instancetype)init {
	if ((self = [super init])) {
		
		// construct tool bar
		_toolbar = [UIToolbar new];
		_toolbar.hidden = YES;
		_toolbar.translucent = YES;
		_toolbar.barStyle = UIBarStyleBlack;
		_toolbar.tintColor = [UIColor colorWithWhite:1.0 alpha:.5];
		
		// configure items
		NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:12], UITextAttributeFont,nil];
		
		// separator
		UIBarButtonItem *separator = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
		separator.width = 8.0;
		
		// dismiss
		UIBarButtonItem *dismiss = [[[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)] autorelease];
		[dismiss setTitleTextAttributes:attributes forState:UIControlStateNormal];
		
		// presentAgain
		UIBarButtonItem *presentAgain = [[[UIBarButtonItem alloc] initWithTitle:@"Present again" style:UIBarButtonItemStylePlain target:self action:@selector(presentAgain)] autorelease];
		[presentAgain setTitleTextAttributes:attributes forState:UIControlStateNormal];
		
		// respring
		UIBarButtonItem *respring = [[[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)] autorelease];
		[respring setTitleTextAttributes:attributes forState:UIControlStateNormal];
		
		NSArray *items = @[dismiss, separator, presentAgain, separator, respring];
		[_toolbar setItems:items animated:NO];
	}
	return self;
}

- (void)show {
	
	PWWindow *window = [PWController sharedInstance].window;
	
	CGFloat toolbarHeight = 30.0;
	_toolbar.alpha = 0.0;
	_toolbar.hidden = NO;
	_toolbar.frame = CGRectMake(0, 0, window.bounds.size.width, toolbarHeight);
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	if (_toolbar.superview == nil)
		[window addSubview:_toolbar];
	
	[UIView animateWithDuration:0.2 animations:^{
		_toolbar.alpha = 1.0;
	}];
}

- (void)hide {
	_toolbar.alpha = 1.0;
	[UIView animateWithDuration:0.2 animations:^{
		_toolbar.alpha = 0.0;
	} completion:^(BOOL finished) {
		_toolbar.hidden = YES;
	}];
}

- (void)dismiss {
	
	PWController *controller = [PWController sharedInstance];
	
	if (controller.activeWidget != nil) {
		[[PWController sharedInstance] dismissWidget];
	}
}

- (void)presentAgain {
	
	PWController *controller = [PWController sharedInstance];
	PWWidget *widget = controller.activeWidget;
	
	if (widget != nil) {
		
		// keep the name of the presented widget
		__block NSString *name = [widget.name copy];
		__block NSDictionary *userInfo = [widget.userInfo copy];
		
		// dismiss the currently presented widget
		[[PWController sharedInstance] dismissWidget];
		
		// present it again after a while
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
			[controller presentWidgetNamed:name userInfo:userInfo];
			[name release], name = nil;
			[userInfo release], userInfo = nil;
		});
	}
}

- (void)respring {
	
}

- (id)copyWithZone:(NSZone *)zone { return self; }
- (id)retain { return self; }
- (oneway void)release {}
- (id)autorelease { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }

@end