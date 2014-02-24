//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

typedef void(^PWAlertViewCompletionHandler)(BOOL cancelled, NSString *firstValue, NSString *secondValue);

@interface PWAlertView : UIAlertView<UIAlertViewDelegate> {
	
	PWAlertViewCompletionHandler _completionHandler;
}

@property(nonatomic, copy) PWAlertViewCompletionHandler completionHandler;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle defaultValue:(NSString *)defaultValue cancelButtonTitle:(NSString *)cancelButtonTitle style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion;

@end