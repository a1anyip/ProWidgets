//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWThemeParsed.h"

#define PW_IMP_IMAGE(ivar, setName) - (UIImage *)ivar##ForOrientation:(PWWidgetOrientation)orientation {\
	PWThemeParsedImageSet set = _##ivar;\
	UIImage *image = orientation == PWWidgetOrientationPortrait ? set.portrait : set.landscape;\
	return image == nil ? [super ivar##ForOrientation:orientation] : image;\
}\
\
- (void)set##setName:(UIImage *)image forOrientation:(NSNumber *)orientation {\
	if ((PWWidgetOrientation)[orientation intValue] == PWWidgetOrientationPortrait)\
		_##ivar.portrait = [image retain];\
	else\
		_##ivar.landscape = [image retain];\
}

#define PW_IMP_COLOR(ivar) - (UIColor *)ivar {\
	UIColor *color = _##ivar;\
	LOG(@"PWThemeParsed: %@ / %@ / %@", @#ivar, color, [super ivar]);\
	return color == nil ? [super ivar] : color;\
}

#define PW_IMP_BOOL(ivar, setName) - (BOOL)ivar {\
	return _##ivar;\
}\
\
- (void)set##setName:(NSNumber *)number {\
	_##ivar = [number boolValue];\
}

#define PW_IMP_DOUBLE(ivar, setName) - (CGFloat)ivar {\
	return _##ivar;\
}\
\
- (void)set##setName:(NSNumber *)number {\
	_##ivar = [number doubleValue];\
}

#define PW_RELEASE_IMAGE(ivar) [_##ivar.portrait release], [_##ivar.landscape release], _##ivar.portrait = nil, _##ivar.landscape = nil;
#define PW_RELEASE(ivar) [_##ivar release], _##ivar = nil;

@implementation PWThemeParsed

// style
PW_IMP_BOOL(wantsDarkKeyboard, WantsDarkKeyboard)

// images
PW_IMP_IMAGE(sheetBackgroundImage, SheetBackgroundImage)
PW_IMP_IMAGE(navigationBarBackgroundImage, NavigationBarBackgroundImage)
PW_IMP_IMAGE(cellBackgroundImage, CellBackgroundImage)
PW_IMP_IMAGE(cellSelectedBackgroundImage, CellSelectedBackgroundImage)

// colors
PW_IMP_COLOR(sheetBackgroundColor)

PW_IMP_COLOR(navigationBarBackgroundColor)
PW_IMP_COLOR(navigationTitleTextColor)
PW_IMP_COLOR(navigationButtonTextColor)

PW_IMP_COLOR(cellTintColor)
PW_IMP_COLOR(cellSeparatorColor);
PW_IMP_COLOR(cellBackgroundColor)
PW_IMP_COLOR(cellTitleTextColor)
PW_IMP_COLOR(cellValueTextColor)
PW_IMP_COLOR(cellButtonTextColor)
PW_IMP_COLOR(cellInputTextColor)
PW_IMP_COLOR(cellInputPlaceholderTextColor)
PW_IMP_COLOR(cellPlainTextColor)

PW_IMP_COLOR(cellSelectedBackgroundColor)
PW_IMP_COLOR(cellSelectedTitleTextColor)
PW_IMP_COLOR(cellSelectedValueTextColor)
PW_IMP_COLOR(cellSelectedButtonTextColor)

PW_IMP_COLOR(cellHeaderFooterViewBackgroundColor)
PW_IMP_COLOR(cellHeaderFooterViewTitleTextColor)

PW_IMP_COLOR(cellSwitchOnColor)
PW_IMP_COLOR(cellSwitchOffColor)

// doubles
PW_IMP_DOUBLE(cornerRadius, CornerRadius)

// cell height
- (CGFloat)heightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation {
	
	PWThemeParsedCellHeight set = _cellHeight;
	
	switch (orientation) {
		case PWWidgetOrientationPortrait:
			if (set.portrait.defined) {
				return type == PWWidgetCellTypeTextArea ? set.portrait.textarea : set.portrait.normal;
			}
			break;
			
		case PWWidgetOrientationLandscape:
			if (set.landscape.defined) {
				return type == PWWidgetCellTypeTextArea ? set.landscape.textarea : set.landscape.normal;
			}
			break;
	}
	
	return [super heightOfCellOfType:type forOrientation:orientation];
}

- (void)setHeightOfCell:(CGFloat)height forType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation {
	
	switch (orientation) {
		case PWWidgetOrientationPortrait:
			
			_cellHeight.portrait.defined = YES;
			
			if (type == PWWidgetCellTypeTextArea)
				_cellHeight.portrait.textarea = height;
			else
				_cellHeight.portrait.normal = height;
			
			break;
			
		case PWWidgetOrientationLandscape:
			
			_cellHeight.landscape.defined = YES;
			
			if (type == PWWidgetCellTypeTextArea)
				_cellHeight.landscape.textarea = height;
			else
				_cellHeight.landscape.normal = height;
			
			break;
	}
}

- (void)dealloc {
	
	// release images in sets
	PW_RELEASE_IMAGE(sheetBackgroundImage)
	PW_RELEASE_IMAGE(navigationBarBackgroundImage)
	PW_RELEASE_IMAGE(cellBackgroundImage)
	PW_RELEASE_IMAGE(cellSelectedBackgroundImage)
	
	// release colors
	PW_RELEASE(sheetBackgroundColor)
	
	PW_RELEASE(cellTintColor)
	PW_RELEASE(cellSeparatorColor)
	PW_RELEASE(cellBackgroundColor)
	PW_RELEASE(cellTitleTextColor)
	PW_RELEASE(cellValueTextColor)
	PW_RELEASE(cellButtonTextColor)
	PW_RELEASE(cellInputTextColor)
	PW_RELEASE(cellPlainTextColor)
	
	PW_RELEASE(cellSelectedBackgroundColor)
	PW_RELEASE(cellSelectedTitleTextColor)
	PW_RELEASE(cellSelectedValueTextColor)
	PW_RELEASE(cellSelectedButtonTextColor)
	
	PW_RELEASE(cellHeaderFooterViewBackgroundColor)
	PW_RELEASE(cellHeaderFooterViewTitleTextColor)
	
	PW_RELEASE(cellSwitchOnColor)
	PW_RELEASE(cellSwitchOffColor)
	
	[super dealloc];
}

@end