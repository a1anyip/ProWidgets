//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "item.h"
#import "_PWWidgetItemTextInputTraits.h"

@interface PWWidgetItemTextArea : _PWWidgetItemTextInputTraits<UITextViewDelegate>

@end

@interface PWWidgetItemTextAreaCell : PWWidgetItemCell {
	
	UITextView *_textView;
}

@end