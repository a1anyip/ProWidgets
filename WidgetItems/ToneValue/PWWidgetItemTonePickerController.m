//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import <MediaPlayer/MPMediaItem.h>
#import "PWWidgetItemTonePickerController.h"
#import "../PWWidgetItemToneValue.h"
#import "../../PWController.h"
#import "../../PWWidget.h"
#import "../../PWWidgetItem.h"
#import "../../PWThemableTableView.h"
#import "../../PWThemableTableViewCell.h"

char PWWidgetItemTonePickerControllerThemeKey = 0;
extern MPMediaItem *MediaItemForAlarmSound(NSString *sound);

/*
@protocol TKTonePickerStyleProvider <NSObject>

@required
@property(readonly, nonatomic) struct UIEdgeInsets tonePickerHeaderTextPaddingInsets;
@property(readonly, nonatomic) struct UIOffset tonePickerHeaderTextShadowOffset;
@property(readonly, nonatomic) UIColor *tonePickerHeaderTextShadowColor;
@property(readonly, nonatomic) UIColor *tonePickerHeaderTextColor;
@property(readonly, nonatomic) UIFont *tonePickerHeaderTextFont;
@property(readonly, nonatomic) BOOL wantsCustomTonePickerHeaderView;
@property(readonly, nonatomic) UIColor *tonePickerCellBackgroundColor;
@property(readonly, nonatomic) UIColor *tonePickerCellHighlightedTextColor;
@property(readonly, nonatomic) UIColor *tonePickerCellTextColor;
@property(readonly, nonatomic) UIFont *tonePickerCellTextFont;
@property(readonly, nonatomic) UITableViewCellSeparatorStyle tonePickerTableViewSeparatorStyle;
@property(readonly, nonatomic) BOOL tonePickerUsesOpaqueBackground;

- (id)newAccessoryDisclosureIndicatorViewForTonePickerCell;
- (id)newBackgroundViewForSelectedTonePickerCell:(BOOL)arg1;

@end


@interface PWWidgetItemTonePickerStyleProvider : NSObject<TKTonePickerStyleProvider>

@end

@implementation PWWidgetItemTonePickerStyleProvider

- (UIEdgeInsets)tonePickerHeaderTextPaddingInsets {
	return UIEdgeInsetsZero;
}

- (UIOffset)tonePickerHeaderTextShadowOffset {
	return UIOffsetZero;
}

- (UIColor *)tonePickerHeaderTextShadowColor {
	return nil;
}

- (UIFont *)tonePickerHeaderTextFont { return [UIFont boldSystemFontOfSize:14.0];}
- (UIFont *)tonePickerCellTextFont { return [UIFont systemFontOfSize:16.0]; }

- (BOOL)wantsCustomTonePickerHeaderView { return NO; }
- (BOOL)tonePickerUsesOpaqueBackground { return NO; }
- (id)newAccessoryDisclosureIndicatorViewForTonePickerCell { return nil; }
- (id)newBackgroundViewForSelectedTonePickerCell:(BOOL)arg1 { return nil; }

- (UIColor *)tonePickerHeaderTextColor {
	return [UIColor redColor];
}

- (UIColor *)tonePickerCellBackgroundColor {
	return [UIColor blackColor];
}

- (UIColor *)tonePickerCellTextColor {
	return [UIColor redColor];
}

- (UIColor *)tonePickerCellHighlightedTextColor {
	return [UIColor yellowColor];
}

- (UITableViewCellSeparatorStyle)tonePickerTableViewSeparatorStyle {
	return UITableViewCellSeparatorStyleNone;
}

@end
*/

@interface PWThemableTonePicker : TKTonePicker {
	
	PWTheme *_theme;
}

- (instancetype)initWithFrame:(CGRect)frame avController:(id)avController filter:(NSUInteger)filter tonePicker:(BOOL)tonePicker theme:(PWTheme *)theme;

@end

@implementation PWThemableTonePicker

- (instancetype)initWithFrame:(CGRect)frame avController:(id)avController filter:(NSUInteger)filter tonePicker:(BOOL)tonePicker theme:(PWTheme *)theme {
	if ((self = [super initWithFrame:frame avController:avController filter:filter tonePicker:tonePicker])) {
		
		self.frame = frame;
		_theme = theme;
		
		TKToneTableController *tableController = *(TKToneTableController **)instanceVar(self, "_tableController");
		objc_setAssociatedObject(tableController, &PWWidgetItemTonePickerControllerThemeKey, _theme, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		
		[self _reloadData];
	}
	return self;
}
/*
- (void)buildUIWithAVController:(id)avController filter:(NSUInteger)filter tonePicker:(BOOL)tonePicker {
	
	TKToneTableController *tableController = [[TKToneTableController alloc] initWithAVController:avController filter:filter tonePicker:tonePicker];
	object_setInstanceVariable(self, "_tableController", tableController);
	
	[self _buildTable];
	
	TLToneManager *ringtoneManager = [tableController ringtoneManager];
	[ringtoneManager setDelegate:self];
}
*/
- (void)_buildTable {
	
	TKToneTableController *tableController = *(TKToneTableController **)instanceVar(self, "_tableController");
	if (tableController == NULL) return;
	
	UITableView *oldTableView = *(UITableView **)instanceVar(self, "_table");
	
	[tableController setTableView:nil];
	if (oldTableView != NULL) [oldTableView removeFromSuperview];
	
	PWThemableTableView *tableView = [[PWThemableTableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped theme:_theme];
	object_setInstanceVariable(self, "_table", tableView);
	
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.delegate = tableController;
	tableView.dataSource = tableController;
	[self addSubview:tableView];
	[tableController setTableView:tableView];
	[tableView release];
	
	[self _reloadData];
}

- (void)dealloc {
	_theme = nil;
	[super dealloc];
}

@end

@implementation PWWidgetItemTonePickerController

+ (NSString *)nameOfToneWithIdentifier:(NSString *)toneIdentifier andType:(ToneType)toneType {
	
	NSString *toneName = nil;
	
	if (toneType == ToneTypeRingtone) {
		TLToneManager *toneManager = [TLToneManager sharedRingtoneManager];
		toneName = [[toneManager copyNameOfIdentifier:toneIdentifier isValid:NULL] autorelease];
	} else if (toneType == ToneTypeMediaItem) {
		MPMediaItem *item = MediaItemForAlarmSound(toneIdentifier);
		if (item != NULL) {
			toneName = [item valueForProperty:MPMediaItemPropertyTitle];
		}
	}
	
	return toneName == nil ? toneIdentifier : toneName;
}

+ (TonePickerType)tonePickerTypeFromNumber:(NSNumber *)number {
	switch ([number unsignedIntegerValue]) {
		case (NSUInteger)TonePickerTypeBoth:
		default:
			return TonePickerTypeBoth;
		case (NSUInteger)TonePickerTypeOnlyAlertTone:
			return TonePickerTypeOnlyAlertTone;
		case (NSUInteger)TonePickerTypeOnlyRingTone:
			return TonePickerTypeOnlyRingTone;
	}
}

+ (ToneType)toneTypeFromNumber:(NSNumber *)number {
	return [number unsignedIntegerValue] == (NSUInteger)ToneTypeMediaItem ? ToneTypeMediaItem : ToneTypeRingtone;
}

- (instancetype)initWithTonePickerType:(TonePickerType)tonePickerType selectedToneIdentifier:(NSString *)identifier toneType:(ToneType)toneType forWidget:(PWWidget *)widget {
	if ((self = [super initForWidget:widget])) {
		
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.requiresKeyboard = NO;
		self.shouldMaximizeContentHeight = YES;
		
		_tonePickerType = tonePickerType;
		
		// set selected tone identifier
		if (identifier != nil) {
			if (toneType == ToneTypeRingtone)
				[self.tonePicker setSelectedRingtoneIdentifier:identifier];
			else if (toneType == ToneTypeMediaItem)
				[self.tonePicker setSelectedMediaIdentifier:identifier];
		}
	}
	return self;
}

- (void)loadView {
	
	PWTheme *theme = self.theme;
	
	switch (_tonePickerType) {
		case TonePickerTypeBoth:
		default:
			_tonePicker = [[PWThemableTonePicker alloc] initWithFrame:CGRectZero avController:nil filter:31 tonePicker:YES theme:theme];
			[_tonePicker setShowsMedia:NO]; // YES
			[_tonePicker setMediaAtTop:YES];
			break;
		case TonePickerTypeOnlyAlertTone:
			_tonePicker = [[PWThemableTonePicker alloc] initWithFrame:CGRectZero avController:nil filter:31 tonePicker:YES theme:theme];
			[_tonePicker setShowsMedia:NO];
			break;
		case TonePickerTypeOnlyRingTone:
			_tonePicker = [[PWThemableTonePicker alloc] initWithFrame:CGRectZero avController:nil filter:0 tonePicker:YES theme:theme];
			[_tonePicker setShowsMedia:NO]; // YES
			[_tonePicker setMediaAtTop:YES];
			break;
	}
	
	//[_tonePicker setStyleProvider:[[PWWidgetItemTonePickerStyleProvider new] autorelease]];
	[_tonePicker setCustomTableViewCellClass:[PWThemableTableViewCell class]];
	
	[_tonePicker setShowsNone:YES];
	_tonePicker.delegate = self;
	
	self.view = _tonePicker;
	[_tonePicker release];
}

- (TKTonePicker *)tonePicker {
	return (TKTonePicker *)self.view;
}

- (NSString *)title {
	return CT(@"ToneValueSound");
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	if (parent == nil) {
		// ask tone picker to stop playing selected ringtone
		[_tonePicker stopPlayingWithFadeOut:YES];
		[_tonePicker stopPlaying];
	}
}

- (void)ringtonePicker:(TKTonePicker *)picker selectedRingtoneWithIdentifier:(NSString *)identifier {
	LOG(@"ringtonePicker:selectedRingtoneWithIdentifier: <identifier: %@>", identifier);
	
	if ([identifier isKindOfClass:[NSNumber class]]) {
		identifier = [(NSNumber *)identifier stringValue];
	}
	
	self.selectedToneIdentifier = identifier;
	self.selectedToneType = ToneTypeRingtone;
	
	// notify delegate
	[_delegate selectedToneIdentifierChanged:identifier toneType:ToneTypeRingtone];
}

- (void)ringtonePicker:(TKTonePicker *)picker selectedMediaItemWithIdentifier:(NSString *)identifier {
	LOG(@"ringtonePicker:selectedMediaItemWithIdentifier: <identifier: %@>", identifier);
	
	if ([identifier isKindOfClass:[NSNumber class]]) {
		identifier = [(NSNumber *)identifier stringValue];
	}
	
	self.selectedToneIdentifier = identifier;
	self.selectedToneType = ToneTypeMediaItem;
	
	// notify delegate
	[_delegate selectedToneIdentifierChanged:identifier toneType:ToneTypeMediaItem];
}

- (void)dealloc {
	
	_delegate = nil;
	RELEASE(_selectedToneIdentifier)
	
	// ask tone picker to stop playing selected ringtone
	[_tonePicker stopPlayingWithFadeOut:YES];
	[_tonePicker stopPlaying];
	
	[super dealloc];
}

@end