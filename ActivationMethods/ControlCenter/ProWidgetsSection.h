//
//  ProWidgetsSection.h
//  ProWidgets
//
//  Created by Alan on 29.01.2014.
//  Copyright (c) 2014 Alan. All rights reserved.
//

#import "CCSection-Protocol.h"
#import "ProWidgetsSectionView.h"
#import "interface.h"

@interface ProWidgetsSection : NSObject<CCSection>

@property (nonatomic, retain) ProWidgetsSectionView *view;
@property (nonatomic, assign) UIViewController <CCSectionDelegate> *delegate;

@end
