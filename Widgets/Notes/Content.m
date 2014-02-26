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
		_contentView = [UITextView new];
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
	/*
	NSAttributedString *attributedString = _contentView.attributedText;
	NSDictionary *documentAttributes = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType };
	NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:documentAttributes error:NULL];
	NSString *htmlString = [[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] autorelease];
	return htmlString;
	*/
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
	
	if (editing) {
		
		_edited = YES;
		
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
		[_contentView setNeedsDisplay];
		[_contentView setNeedsLayout];
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
	if (self.contentView.edited) {
		[self saveNote];
	}
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

- (void)actionButtonPressed {
	PWWidgetNotesContentView *view = (PWWidgetNotesContentView *)self.view;
	[view setEditing:NO];
	[self saveNote];
}

#define REPLACE(a,b,c) a = [a stringByReplacingOccurrencesOfString:b withString:c];

- (void)saveNote {
	
	PWWidgetNotesContentView *view = self.contentView;
	
	// new content
	NSString *content = view.content;
	NSString *bodyContent = content;
	
	if ([content length] == 0) {
		// remove this note instead
		[_listViewController removeNote:_noteObject];
		[[PWController activeWidget] popViewControllerAnimated:YES];
		return;
	}
	
	// process body content
	REPLACE(bodyContent, @"<", @"&lt;")
	REPLACE(bodyContent, @">", @"&gt;")
	
	// old content
	NSString *oldContent = [_noteObject content];
	
	LOG(@"PWWidgetNotesContentViewController: original content: %@", oldContent);
	
	// process old content
	REPLACE(oldContent, @"&nbsp;", @" ")
	REPLACE(oldContent, @"<div><br></div>", @"\n")
	REPLACE(oldContent, @"<br>", @"\n")
	REPLACE(oldContent, @"<br/>", @"\n")
	REPLACE(oldContent, @"<div>", @"\n")
	REPLACE(oldContent, @"</div>", @"")
	REPLACE(oldContent, @"<p>", @"")
	REPLACE(oldContent, @"</p>", @"\n")
	
	LOG(@"PWWidgetNotesContentViewController: old content: %@", oldContent);
	LOG(@"PWWidgetNotesContentViewController: new content: %@", bodyContent);
	
	if ([oldContent isEqualToString:bodyContent]) {
		LOG(@"PWWidgetNotesContentViewController: Not saving note because the content did not change.");
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
	
	REPLACE(bodyContent, @" ", @"&nbsp;")
	REPLACE(bodyContent, @"\n", @"<br>")
	
	body.content = bodyContent;
	
	// save it
	NoteContext *noteContext = [(PWWidgetNotes *)[PWController activeWidget] noteContext];
	[noteContext saveOutsideApp:NULL];
	
	// update date value
	[self.contentView setDate:modificationDate];
}

#undef REPLACE

- (void)dealloc {
	_listViewController = nil;
	RELEASE(_noteObject)
	[super dealloc];
}

@end