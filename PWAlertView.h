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

/**
 *  The block completion handler.
 */
@property(nonatomic, copy) PWAlertViewCompletionHandler completionHandler;

/**
 *  Wrapper method for initializing an alert view with block completion handler.
 *
 *  @param title             The string that appears in the receiver’s title bar.
 *  @param message           Descriptive text that provides more details than the title.
 *  @param buttonTitle       The title of the button next to cancel button or nil if there is only cancel button.
 *  @param cancelButtonTitle The title of the cancel button or nil if there is no cancel button.
 *  @param defaultValue      The default value of the first text field or nil if there is no default value or no text field.
 *  @param style             The kind of alert displayed to the user.
 *  @param completion        The block completion handler.
 *
 *  @return Newly initialized alert view.
 */
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle cancelButtonTitle:(NSString *)cancelButtonTitle defaultValue:(NSString *)defaultValue style:(UIAlertViewStyle)style completion:(PWAlertViewCompletionHandler)completion ;

@end