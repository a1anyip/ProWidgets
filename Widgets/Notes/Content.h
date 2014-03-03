//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"

@class PWWidgetNotesListViewController;

@interface PWWidgetNotesContentView : UIView {
	
	BOOL _editing;
	UILabel *_dateLabel;
	UITextView *_contentView;
}

@property(nonatomic, readonly) BOOL editing;

- (NSString *)content;

- (void)setDelegate:(id<UITextViewDelegate>)delegate;
- (void)setDate:(NSDate *)date;
- (void)setContent:(NSString *)content;

- (void)setEditing:(BOOL)editing;

@end

@interface PWWidgetNotesContentViewController : PWContentViewController<UITextViewDelegate> {
	
	BOOL _edited;
	PWWidgetNotesListViewController *_listViewController;
	NoteObject *_noteObject;
}

@property(nonatomic, assign) PWWidgetNotesListViewController *listViewController;

- (instancetype)initWithNote:(NoteObject *)noteObject;
- (void)actionButtonPressed;
- (void)saveNote;

@end