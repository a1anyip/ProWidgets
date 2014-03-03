//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "header.h"
#import "PWTheme.h"

#define PW_DECLARE_BOOL(ivar, setName) - (BOOL)ivar;\
- (void)set##setName:(NSNumber *)number;

#define PW_DECLARE_COLOR(ivar) @property(nonatomic, copy) UIColor * ivar;

#define PW_DECLARE_IMAGE(ivar, setName) - (UIImage *)ivar##ForOrientation:(PWWidgetOrientation)orientation;\
- (void)set##setName:(UIImage *)image forOrientation:(NSNumber *)orientation;

#define PW_DECLARE_DOUBLE(ivar, setName) - (CGFloat)ivar;\
- (void)set##setName:(NSNumber *)number;

typedef struct PWThemeParsedImageSet {
	
	UIImage *portrait;
	UIImage *landscape;
	
} PWThemeParsedImageSet;

typedef struct PWThemeParsedCellHeight {
	
	struct {
		BOOL defined;
		CGFloat normal;
		CGFloat textarea;
	} portrait;
	
	struct {
		BOOL defined;
		CGFloat normal;
		CGFloat textarea;
	} landscape;
	
} PWThemeParsedCellHeight;

typedef struct PWThemeParsedOverrideSide {
	
	BOOL defined;
	
	CGSize portrait;
	CGSize landscape;
	
} PWThemeParsedOverrideSide;

@interface PWThemeParsed : PWTheme {
	
	// style
	BOOL _wantsDarkKeyboard;
	
	// image
	PWThemeParsedImageSet _sheetBackgroundImage;
	PWThemeParsedImageSet _navigationBarBackgroundImage;
	PWThemeParsedImageSet _cellBackgroundImage;
	PWThemeParsedImageSet _cellSelectedBackgroundImage;
	
	// colors
	UIColor *_tintColor;
	
	UIColor *_sheetForegroundColor;
	UIColor *_sheetBackgroundColor;
	
	UIColor *_navigationBarBackgroundColor;
	UIColor *_navigationTitleTextColor;
	UIColor *_navigationButtonTextColor;
	
	UIColor *_cellSeparatorColor;
	UIColor *_cellBackgroundColor;
	UIColor *_cellTitleTextColor;
	UIColor *_cellValueTextColor;
	UIColor *_cellButtonTextColor;
	UIColor *_cellInputTextColor;
	UIColor *_cellInputPlaceholderTextColor;
	UIColor *_cellPlainTextColor;
	
	UIColor *_cellSelectedBackgroundColor;
	UIColor *_cellSelectedTitleTextColor;
	UIColor *_cellSelectedValueTextColor;
	UIColor *_cellSelectedButtonTextColor;
	
	UIColor *_cellHeaderFooterViewBackgroundColor;
	UIColor *_cellHeaderFooterViewTitleTextColor;
	
	UIColor *_switchThumbColor;
	UIColor *_switchOnColor;
	UIColor *_switchOffColor;
	
	// numerical values
	CGFloat _cornerRadius;
	PWThemeParsedCellHeight _cellHeight;
}

// style
PW_DECLARE_BOOL(wantsDarkKeyboard, WantsDarkKeyboard)

// colors
PW_DECLARE_COLOR(tintColor)

PW_DECLARE_COLOR(sheetForegroundColor)
PW_DECLARE_COLOR(sheetBackgroundColor)

PW_DECLARE_COLOR(navigationBarBackgroundColor)
PW_DECLARE_COLOR(navigationTitleTextColor)
PW_DECLARE_COLOR(navigationButtonTextColor)

PW_DECLARE_COLOR(cellSeparatorColor)
PW_DECLARE_COLOR(cellBackgroundColor)
PW_DECLARE_COLOR(cellTitleTextColor)
PW_DECLARE_COLOR(cellValueTextColor)
PW_DECLARE_COLOR(cellButtonTextColor)
PW_DECLARE_COLOR(cellInputTextColor)
PW_DECLARE_COLOR(cellInputPlaceholderTextColor)
PW_DECLARE_COLOR(cellPlainTextColor)

PW_DECLARE_COLOR(cellSelectedBackgroundColor)
PW_DECLARE_COLOR(cellSelectedTitleTextColor)
PW_DECLARE_COLOR(cellSelectedValueTextColor)
PW_DECLARE_COLOR(cellSelectedButtonTextColor)

PW_DECLARE_COLOR(cellHeaderFooterViewBackgroundColor)
PW_DECLARE_COLOR(cellHeaderFooterViewTitleTextColor)

PW_DECLARE_COLOR(switchThumbColor)
PW_DECLARE_COLOR(switchOnColor)
PW_DECLARE_COLOR(switchOffColor)

// images
PW_DECLARE_IMAGE(sheetBackgroundImage, SheetBackgroundImage)
PW_DECLARE_IMAGE(navigationBarBackgroundImage, NavigationBarBackgroundImage)
PW_DECLARE_IMAGE(cellBackgroundImage, CellBackgroundImage)
PW_DECLARE_IMAGE(cellSelectedBackgroundImage, CellSelectedBackgroundImage)

// doubles
PW_DECLARE_DOUBLE(cornerRadius, CornerRadius)

// cell height
- (CGFloat)heightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation;

- (void)setHeightOfCell:(CGFloat)height forType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation;

@end