//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@interface PWThemePlistParser : NSObject

/**
 *  Parse a specified theme dictionary and retrieve its parsed theme instance.
 *
 *  @param dict   The theme dictionary to be parsed.
 *  @param bundle The theme bundle.
 *  @param widget The widget that the theme will be applied to.
 *
 *  @return The parsed theme instance.
 */
+ (PWTheme *)parse:(NSDictionary *)dict inBundle:(NSBundle *)bundle forWidget:(PWWidget *)widget;

@end