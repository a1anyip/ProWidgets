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

@interface PWWidgetItemTextField : _PWWidgetItemTextInputTraits<UITextFieldDelegate>

@end

@interface PWWidgetItemTextFieldCell : PWWidgetItemCell {
	
	UITextField *_textField;
	UIImageView *_iconView;
}

@end