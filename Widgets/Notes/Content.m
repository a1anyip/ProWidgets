//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "Content.h"
#import "Notes.h"
#import "List.h"
#import "PWContentViewController.h"
#import "PWController.h"
#import "PWTheme.h"
#import "PWThemableTextView.h"

@implementation PWWidgetNotesContentView

- (instancetype)init {
	if ((self = [super init])) {
		
		PWTheme *theme = [PWController activeTheme];
		UIColor *textColor = [theme cellTitleTextColor];
		
		_dateLabel = [UILabel new];
		_dateLabel.textColor = textColor;
		_dateLabel.backgroundColor = [UIColor clearColor];
		_dateLabel.textAlignment = NSTextAlignmentCenter;
		_dateLabel.alpha = .5;
		_dateLabel.font = [UIFont systemFontOfSize:14.0];
		[self addSubview:_dateLabel];
		
		CGFloat padding = 10.0;
		_contentView = [PWThemableTextView new];
		_contentView.tintColor = [PWTheme systemBlueColor];
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.selectable = YES;
		_contentView.alwaysBounceVertical = YES;
		_contentView.textContainerInset = UIEdgeInsetsMake(padding / 2 /* top */, padding, padding, padding);
		[self setEditing:NO];
		[self addSubview:_contentView];
		
		UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapped:)] autorelease];
		[_contentView addGestureRecognizer:singleTap];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGSize size = self.frame.size;
	CGFloat width = size.width;
	CGFloat height = size.height;
	CGFloat dateHeight = 35.0;
	
	_dateLabel.frame = CGRectMake(0, 0, width, dateHeight);
	_contentView.frame = CGRectMake(0, dateHeight, width, height - dateHeight);
}

- (NSString *)content {
	return _contentView.text;
}

- (void)setDelegate:(id<UITextViewDelegate>)delegate {
	_contentView.delegate = delegate;
}

- (void)setDate:(NSDate *)date {
	NSDateFormatter *dateFormatter = [(PWWidgetNotes *)[PWController activeWidget] dateFormatter];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *result = [dateFormatter stringFromDate:date];
	_dateLabel.text = result;
}

// from https://gist.github.com/romaonthego/6672863
- (void)setContent:(NSString *)content {
	
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil] autorelease];
	
	PWTheme *theme = [PWController activeTheme];
	UIColor *textColor = [theme cellTitleTextColor];
	
	// set font and text color
	[attributedString setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: textColor } range:NSMakeRange(0, [attributedString length])];
	
	_contentView.attributedText = attributedString;
}

- (void)contentViewTapped:(UITextView *)sender {
	if (!_contentView.editable) {
		[self setEditing:YES];
	}
}

- (void)setEditing:(BOOL)editing {
	
	_editing = editing;
	
	if (editing) {
		
		_contentView.dataDetectorTypes = UIDataDetectorTypeNone;
		_contentView.editable = YES;
		
		NSMutableAttributedString *attributedString = [[_contentView.attributedText mutableCopy] autorelease];
		PWTheme *theme = [PWController activeTheme];
		UIColor *textColor = [theme cellTitleTextColor];
		
		// set font and text color
		[attributedString setAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName: textColor } range:NSMakeRange(0, [attributedString length])];
		
		_contentView.attributedText = attributedString;
		
		[_contentView becomeFirstResponder];
		
	} else {
		
		_contentView.editable = NO;
		_contentView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink | UIDataDetectorTypeAddress | UIDataDetectorTypeCalendarEvent;
		
		//[_contentView setNeedsDisplay];
		//[_contentView setNeedsLayout];
		[_contentView resignFirstResponder];
	}
}

- (void)dealloc {
	[self setDelegate:nil];
	RELEASE_VIEW(_dateLabel)
	RELEASE_VIEW(_contentView)
	[super dealloc];
}

@end

@implementation PWWidgetNotesContentViewController

- (instancetype)initWithNote:(NoteObject *)noteObject {
	if ((self = [super init])) {
		
		_noteObject = [noteObject retain];
		
		PWWidgetNotesContentView *view = self.contentView;
		NSString *content = noteObject.content;
		NSDate *modificationDate = noteObject.modificationDate;
		[view setDelegate:self];
		[view setContent:content];
		[view setDate:modificationDate];
	}
	return self;
}

- (void)load {
	self.actionButtonText = @"";
	self.shouldAutoConfigureStandardButtons = NO;
	self.shouldMaximizeContentHeight = YES;
	[self setHandlerForEvent:[PWContentViewController actionEventName] target:self selector:@selector(actionButtonPressed)];
}

- (PWWidgetNotesContentView *)contentView {
	return (PWWidgetNotesContentView *)self.view;
}

- (NSString *)title {
	return @"";
}

- (void)loadView {
	self.view = [[PWWidgetNotesContentView new] autorelease];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self saveNote];
}

- (void)willBePresentedInNavigationController:(UINavigationController *)navigationController {
	[self configureActionButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	self.actionButtonText = @"Done";
	self.requiresKeyboard = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.actionButtonText = @"";
	self.requiresKeyboard = NO;
}

- (void)textViewDidChange:(UITextView *)textView {
	_edited = YES;
}

- (void)actionButtonPressed {
	PWWidgetNotesContentView *view = (PWWidgetNotesContentView *)self.view;
	[view setEditing:NO];
	[self saveNote];
}

#define REPLACE(a,b,c) a = [a stringByReplacingOccurrencesOfString:b withString:c];

- (void)saveNote {
	
	if (!_edited) {
		LOG(@"No change in note content");
		return;
	}
	
	PWWidgetNotesContentView *view = self.contentView;
	
	// new content
	NSString *content = view.content;
	
	if ([content length] == 0) {
		// remove this note instead
		[_listViewController removeNote:_noteObject];
		[self.widget popViewControllerAnimated:YES];
		return;
	}
	
	// title and summary
	NSString *title;
	NSString *summary;
	NSString *trimmedContent = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSArray *parts = [trimmedContent componentsSeparatedByString:@"\n"];
	if ([parts count] == 1) {
		title = [parts objectAtIndex:0];
		summary = @"";
	} else if ([parts count] >= 2) {
		title = [parts objectAtIndex:0];
		summary = [parts objectAtIndex:1];
	} else { // parts' count is zero, ridiculous?
		return;
	}
	
	// trim title and summary
	title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	summary = [summary stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	NSDate *modificationDate = [NSDate date];
	
	// modify the note object
	_noteObject.title = title;
	_noteObject.summary = summary;
	_noteObject.modificationDate = modificationDate;
	
	// modify the note body
	NoteBodyObject *body = _noteObject.body;
	
	// process body content
	NSString *bodyContent = content;
	REPLACE(bodyContent, @"<", @"&lt;")
	REPLACE(bodyContent, @">", @"&gt;")
	REPLACE(bodyContent, @" ", @"&nbsp;")
	REPLACE(bodyContent, @"\n", @"<br>")
	
	body.content = bodyContent;
	
	// save it
	NoteContext *noteContext = [(PWWidgetNotes *)self.widget noteContext];
	[noteContext saveOutsideApp:NULL];
	
	// update date value
	[self.contentView setDate:modificationDate];
	
	_edited = NO;
}

#undef REPLACE

- (void)dealloc {
	_listViewController = nil;
	RELEASE(_noteObject)
	[super dealloc];
}

@end