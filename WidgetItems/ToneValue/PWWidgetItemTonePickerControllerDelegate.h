//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "../struct.h"

@protocol PWWidgetItemTonePickerControllerDelegate <NSObject>

@required
- (void)selectedToneIdentifierChanged:(NSString *)identifier toneType:(ToneType)toneType;

@end