#import <UIKit/UIKit.h>
#import "../../header.h"
#import "interface.h"
#import "PWWidget.h"
#import "PWWidgetItem.h"
#import "PWContentItemViewController.h"
#import "PWContentViewController.h"
#import "WidgetItems/items.h"

typedef enum {
	
	PWWidgetBrowserDefaultSafari = 0,
	PWWidgetBrowserDefaultChrome = 1
	
} PWWidgetBrowserDefault;

typedef enum {
	
	PWWidgetBrowserInterfaceWeb = 1,
	PWWidgetBrowserInterfaceBookmark = 2
	
} PWWidgetBrowserInterface;