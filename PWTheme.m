//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWTheme.h"
#import "PWController.h"
#import "PWContainerView.h"
#import "PWThemableTableViewCell.h"
#import "PWWidget.h"

static NSDictionary *supportedColorString = nil;

@implementation PWTheme

+ (void)load {
	
	if (supportedColorString != nil) return;
	
	supportedColorString = [@{

			// built-in colors
			@"black": @"blackColor",
			@"darkgray": @"darkGrayColor",
			@"lightgray": @"lightGrayColor",
			@"white": @"whiteColor",
			@"gray": @"grayColor",
			@"red": @"redColor",
			@"green": @"greenColor",
			@"blue": @"blueColor",
			@"cyan": @"cyanColor",
			@"yellow": @"yellowColor",
			@"magenta": @"magentaColor",
			@"orange": @"orangeColor",
			@"purple": @"purpleColor",
			@"brown": @"brownColor",
			@"clear": @"clearColor",

			// system colors
			@"lighttext": @"lightTextColor",
			@"darktext": @"darkTextColor",

			// extra supported words
			@"transparent": @"clearColor"
			
		} copy];
}

//////////////////////////////////////////////////////////////////////

/**
 * Initialization
 **/

- (instancetype)initWithName:(NSString *)name bundle:(NSBundle *)bundle {
	if ((self = [super init])) {
		self.name = name;
		self.bundle = bundle;
	}
	return self;
}

//////////////////////////////////////////////////////////////////////

/**
 * Public API
 **/

- (UIImage *)imageNamed:(NSString *)name {
	return [UIImage imageNamed:name inBundle:_bundle];
}

- (UIImage *)imageNamed:(NSString *)name withCapInsets:(UIEdgeInsets)insets {
	return [[self imageNamed:name] resizableImageWithCapInsets:insets];
}

+ (UIColor *)parseColorString:(NSString *)string {
	
	NSString *lowercaseString = [[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// supported color string
	NSString *selectorName = [supportedColorString objectForKey:lowercaseString];
	if (selectorName != nil) {
		UIColor *color = [UIColor performSelector:NSSelectorFromString(selectorName)];
		LOG(@"PWThemePlistParser: Parsed '%@' as built-in color.", lowercaseString);
		return color;
	}
	
	// #RGB / #RRGGBB
	if ([lowercaseString hasPrefix:@"#"]) {
		
		NSString *hex = [lowercaseString stringByReplacingOccurrencesOfString:@"#" withString:@""];
		
		if ([hex length] == 3 || [hex length] == 6) {
			
			// expand to full form
			if([hex length] == 3) {
				hex = [NSString stringWithFormat:@"%@%@%@%@%@%@",
					   [hex substringWithRange:NSMakeRange(0, 1)],[hex substringWithRange:NSMakeRange(0, 1)],
					   [hex substringWithRange:NSMakeRange(1, 1)],[hex substringWithRange:NSMakeRange(1, 1)],
					   [hex substringWithRange:NSMakeRange(2, 1)],[hex substringWithRange:NSMakeRange(2, 1)]];
			}
			
			unsigned int hexValue;
			[[NSScanner scannerWithString:hex] scanHexInt:&hexValue];
			
			CGFloat red = ((hexValue >> 16) & 0xFF) / 255.0f;
			CGFloat green = ((hexValue >> 8) & 0xFF) / 255.0f;
			CGFloat blue = (hexValue & 0xFF) / 255.0f;
			
			LOG(@"PWThemePlistParser: Parsed '%@' as %.2f, %.2f, %.2f, 1.0", lowercaseString, red, green, blue);
			
			return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
		}
	}
	
	// rgb(255, 0, 0)
	// rgba(255, 0, 0, 1.0)
	// hsl(100, 10%, 10%)
	// hsla(100, 10%, 10%, 0.5)
	if ([lowercaseString hasPrefix:@"rgb"] || [lowercaseString hasPrefix:@"hsl"]) {
		
		// ^(rgba?|hsla?)\(\s*(-?[\d\.]+%?)\s*,\s*([\d\.]+%?)\s*,\s*([\d\.]+%?)\s*(?:,\s*([\d\.]+%?)\s*)?\s*\)$
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(rgba?|hsla?)\\(\\s*(-?[\\d\\.]+%?)\\s*,\\s*([\\d\\.]+%?)\\s*,\\s*([\\d\\.]+%?)\\s*(?:,\\s*([\\d\\.]+%?)\\s*)?\\s*\\)$"
																			   options:0
																				 error:nil];
		
		NSTextCheckingResult *match = [regex firstMatchInString:lowercaseString
														options:0
														  range:NSMakeRange(0, [lowercaseString length])];
		
		// invalid format
		if (match == nil) return nil;
		
		typedef enum {
			RGB,
			RGBA,
			HSL,
			HSLA
		} ColorFormat;
		
		ColorFormat format = RGB;
		
		CGFloat value1 = 0.0;
		CGFloat value2 = 0.0;
		CGFloat value3 = 0.0;
		CGFloat alpha = 1.0;
		
		// the first range is the full length of source string
		for (unsigned int i = 0; i < [match numberOfRanges] - 1; i++) {
			
			NSRange range = [match rangeAtIndex:i + 1];
			if (range.location == NSNotFound) continue;
			
			NSString *part = [lowercaseString substringWithRange:range];
			
			if (i == 0) {
				
				// first match represents rgb/rgba/hsl
				if ([part isEqualToString:@"rgba"]) format = RGBA;
				else if ([part isEqualToString:@"hsl"]) format = HSL;
				else if ([part isEqualToString:@"hsla"]) format = HSLA;
				else format = RGB;
				
			} else {
				
				CGFloat doubleValue = [part doubleValue];
				
				if (i == 4 && (format == RGBA || format == HSLA)) {
					
					if (doubleValue < 0.0)
						doubleValue = 0.0;
					else if (doubleValue > 1.0)
						doubleValue = 1.0;
					
					alpha = doubleValue;
					
				} else if (i <= 3) {
					
					if (format == RGB || format == RGBA) {
						
						// convert percentage to decimal
						if ([part hasSuffix:@"%"])
							doubleValue = (doubleValue > 100.0 ? 100.0 : doubleValue) / 100.0;
						else
							doubleValue = (doubleValue > 255.0 ? 255.0 : doubleValue) / 255.0;
						
						// prevent negative number
						if (doubleValue < 0.0)
							doubleValue = 0.0;
						
					} else if (format == HSL || format == HSLA) {
						
						if (i == 1 && ![part hasSuffix:@"%"]) {
							doubleValue = ((((int)doubleValue % 360) + 360) % 360) / 360.0;
						} else if ((i == 2 || i == 3) && [part hasSuffix:@"%"]) {
							doubleValue = (doubleValue > 100.0 ? 100.0 : doubleValue) / 100.0;
						}
					}
					
					if (i == 1) value1 = doubleValue;
					else if (i == 2) value2 = doubleValue;
					else if (i == 3) value3 = doubleValue;
					
				} else {
					break;
				}
			}
		}
		
		LOG(@"PWThemePlistParser: Parsed '%@' as %.2f, %.2f, %.2f, %.2f", lowercaseString, value1, value2, value3, alpha);
		
		if (format == RGB || format == RGBA) {
			return [UIColor colorWithRed:value1 green:value2 blue:value3 alpha:alpha];
		} else if (format == HSL || format == HSLA) {
			return [UIColor colorWithHue:value1 saturation:value2 brightness:value3 alpha:alpha];
		}
	}
	
	return nil;
}

+ (NSString *)hexCodeFromColor:(UIColor *)color {
	
	CGFloat r, g, b;
	if ([color getRed:&r green:&g blue:&b alpha:NULL]) {
		unsigned int rint = (unsigned int)(r * 255);
		unsigned int gint = (unsigned int)(g * 255);
		unsigned int bint = (unsigned int)(b * 255);
		return [NSString stringWithFormat:@"%02x%02x%02x", rint, gint, bint];
	}
	
	CGFloat w;
	if ([color getWhite:&w alpha:NULL]) {
		unsigned int wint = (unsigned int)(w * 255);
		return [NSString stringWithFormat:@"%02x%02x%02x", wint, wint, wint];
	}
	
	return nil;
}

+ (NSString *)RGBAFromColor:(UIColor *)color {
	
	CGFloat r, g, b, a;
	if ([color getRed:&r green:&g blue:&b alpha:&a]) {
		unsigned int rint = (unsigned int)(r * 255);
		unsigned int gint = (unsigned int)(g * 255);
		unsigned int bint = (unsigned int)(b * 255);
		return [NSString stringWithFormat:@"rgba(%u, %u, %u, %f)", rint, gint, bint, a];
	}
	
	CGFloat w;
	if ([color getWhite:&w alpha:&a]) {
		unsigned int wint = (unsigned int)(w * 255);
		return [NSString stringWithFormat:@"rgba(%u, %u, %u, %f)", wint, wint, wint, a];
	}
	
	return nil;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
	
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color {
	
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, 1.0, -1.0);
	transform = CGAffineTransformTranslate(transform, 0.0, -image.size.height);
	CGContextConcatCTM(context, transform);
	
	CGRect flippedRect = CGRectApplyAffineTransform(rect, transform);
	
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	[color setFill];
	CGContextFillRect(context, flippedRect);
	CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
	CGContextDrawImage(context, flippedRect, image.CGImage);
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

+ (UIColor *)adjustColorBrightness:(UIColor *)color colorAdjustment:(CGFloat)adjustment alphaMultiplier:(CGFloat)alphaMultiplier {
#define ADJUST(x) (MAX(0.0, MIN((x) + adjustment, 1.0)))
	CGFloat r, g, b, a;
	if ([color getRed:&r green:&g blue:&b alpha:&a]) {
		return [UIColor colorWithRed:ADJUST(r)
							   green:ADJUST(g)
								blue:ADJUST(b)
							   alpha:MAX(0.0, MIN(a * alphaMultiplier, 1.0))];
	}
	
	CGFloat w;
	if ([color getWhite:&w alpha:&a]) {
		return [UIColor colorWithWhite:ADJUST(w)
								 alpha:MAX(0.0, MIN(a * alphaMultiplier, 1.0))];
	}
	
#undef ADJUST
	return color;
}

+ (UIColor *)darkenColor:(UIColor *)color {
	return [self adjustColorBrightness:color colorAdjustment:-30/255.0 alphaMultiplier:1.0];
}

+ (UIColor *)lightenColor:(UIColor *)color {
	return [self adjustColorBrightness:color colorAdjustment:30/255.0 alphaMultiplier:1.0];
}

+ (UIColor *)translucentColor:(UIColor *)color {
	return [self adjustColorBrightness:color colorAdjustment:0.0 alphaMultiplier:.5];
}

//////////////////////////////////////////////////////////////////////

- (PWBackgroundView *)backgroundView {
	return [PWController sharedInstance].backgroundView;
}

- (PWContainerView *)containerView {
	return [PWController sharedInstance].containerView;
}

- (UINavigationController *)navigationController {
	return [PWController activeWidget].navigationController;
}

- (UINavigationBar *)navigationBar {
	return [PWController activeWidget].navigationController.navigationBar;
}

/**
 * Private methods
 **/

- (void)_setPreferredTintColor:(UIColor *)tintColor {
	[_preferredTintColor release];
	_preferredTintColor = [tintColor copy];
}

- (void)_setPreferredBarTextColor:(UIColor *)tintColor {
	[_preferredBarTextColor release];
	_preferredBarTextColor = [tintColor copy];
}

- (void)_configureAppearance {
	
	PWContainerView *containerView = self.containerView;
	UINavigationBar *bar = self.navigationBar;
	
	// reset sheet background
	UIImageView *containerBackgroundView = self.containerView.containerBackgroundView;
	containerBackgroundView.image = nil;
	containerBackgroundView.backgroundColor = [UIColor clearColor];
	
	// update sheet background
	UIImage *backgroundImage = [self sheetBackgroundImageForOrientation:[PWController currentOrientation]];
	UIColor *backgroundColor = [self sheetBackgroundColor];
	
	if (backgroundImage != nil)
		containerBackgroundView.image = backgroundImage;
	else if (backgroundColor != nil)
		containerBackgroundView.backgroundColor = backgroundColor;
	
	// corner radius
	containerView.layer.cornerRadius = [self cornerRadius];
	
	// configure navigation bar
	bar.titleTextAttributes = @{ UITextAttributeTextColor:[self navigationTitleTextColor] };
	bar.tintColor = [self navigationButtonTextColor];
	bar.barTintColor = [self navigationBarBackgroundColor];
	
	[bar setBackgroundImage:[self navigationBarBackgroundImageForOrientation:PWWidgetOrientationPortrait] forBarMetrics:UIBarMetricsDefault];
	[bar setBackgroundImage:[self navigationBarBackgroundImageForOrientation:PWWidgetOrientationLandscape] forBarMetrics:UIBarMetricsLandscapePhone];
	
	// update separator color in table view cell
	UIColor *separatorColor = [self cellSeparatorColor];
	[PWThemableTableViewCell setSeparatorColor:separatorColor];
}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to configure the theme
 **/

- (void)enterSnapshotMode {}
- (void)exitSnapshotMode {}

// Setup Theme
// for themers to setup the theme
// e.g. set background image
// NOT necessary to adjust sizes yet. DO it in adjustLayout
- (void)setupTheme {}

// Remove Theme
// for themers to remove all subviews added in setupTheme
- (void)removeTheme {}

// Adjust Layout
// for themers to adjust the size and position of different
// UI elements
- (void)adjustLayout {}

//////////////////////////////////////////////////////////////////////

/**
 * Override these methods to customize the theme
 **/

///////////////////////////
////////// Style //////////
///////////////////////////

- (BOOL)wantsDarkKeyboard {
	return NO;
}

////////////////////////////
////////// Images //////////
////////////////////////////

- (UIImage *)sheetBackgroundImageForOrientation:(PWWidgetOrientation)orientation {
	return nil;
}

- (UIImage *)navigationBarBackgroundImageForOrientation:(PWWidgetOrientation)orientation {
	return nil;
}

- (UIImage *)cellBackgroundImageForOrientation:(PWWidgetOrientation)orientation {
	return nil;
}

- (UIImage *)cellSelectedBackgroundImageForOrientation:(PWWidgetOrientation)orientation {
	return nil;
}

////////////////////////////
////////// Colors //////////
////////////////////////////

- (UIColor *)tintColor {
	return [self.class defaultTintColor];
}

- (UIColor *)sheetForegroundColor {
	return [self.class defaultSheetForegroundColor];
}

- (UIColor *)sheetBackgroundColor {
	return [self.class defaultSheetBackgroundColor];
}

- (UIColor *)navigationBarBackgroundColor {
	return [self.class defaultNavigationBarBackgroundColor];
}

- (UIColor *)navigationTitleTextColor {
	return [self.class defaultNavigationTitleTextColor];
}

- (UIColor *)navigationButtonTextColor {
	return [self.class defaultNavigationButtonTextColor];
}

- (UIColor *)cellSeparatorColor {
	return [self.class defaultCellSeparatorColor];
}

- (UIColor *)cellBackgroundColor {
	return [self.class defaultCellBackgroundColor];
}

- (UIColor *)cellTitleTextColor {
	return [self.class defaultCellTitleTextColor];
}

- (UIColor *)cellValueTextColor {
	return [self.class defaultCellValueTextColor];
}

- (UIColor *)cellButtonTextColor {
	return [self.class defaultCellButtonTextColor];
}

- (UIColor *)cellInputTextColor {
	return [self.class defaultCellInputTextColor];
}

- (UIColor *)cellInputPlaceholderTextColor {
	return [self.class defaultCellInputPlaceholderTextColor];
}

- (UIColor *)cellPlainTextColor {
	return [self.class defaultCellPlainTextColor];
}

- (UIColor *)cellSelectedBackgroundColor {
	return [self.class defaultCellSelectedBackgroundColor];
}

- (UIColor *)cellSelectedTitleTextColor {
	return [self.class defaultCellSelectedTitleTextColor];
}

- (UIColor *)cellSelectedValueTextColor {
	return [self.class defaultCellSelectedValueTextColor];
}

- (UIColor *)cellSelectedButtonTextColor {
	return [self.class defaultCellSelectedButtonTextColor];
}

- (UIColor *)cellHeaderFooterViewBackgroundColor {
	return [self.class defaultCellHeaderFooterViewBackgroundColor];
}

- (UIColor *)cellHeaderFooterViewTitleTextColor {
	return [self.class defaultCellHeaderFooterViewTitleTextColor];
}

- (UIColor *)switchThumbColor {
	return [self.class defaultSwitchThumbColor];
}

- (UIColor *)switchOnColor {
	return [self.class defaultSwitchOnColor];
}

- (UIColor *)switchOffColor {
	return [self.class defaultSwitchOffColor];
}

//////////////////////////////////////////
////////// Sizes and Dimensions //////////
//////////////////////////////////////////

- (CGFloat)cornerRadius {
	return [self.class defaultCornerRadius];
}

- (CGFloat)heightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation {
	return [self.class defaultHeightOfCellOfType:type forOrientation:orientation];
}

//////////////////////////////////////////////////////////////////////

/**
 * Default theme values
 **/

////////////////////////////
////////// Colors //////////
////////////////////////////

+ (UIColor *)defaultTintColor {
	return nil;
}

+ (UIColor *)defaultSheetForegroundColor {
	return [UIColor blackColor];
}

+ (UIColor *)defaultSheetBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)defaultNavigationBarBackgroundColor {
	return [UIColor whiteColor];
}

+ (UIColor *)defaultNavigationTitleTextColor {
	return [UIColor blackColor];
}

+ (UIColor *)defaultNavigationButtonTextColor {
	return [self systemBlueColor];
}

+ (UIColor *)defaultCellSeparatorColor {
	return [UIColor colorWithWhite:0 alpha:0.2];
}

+ (UIColor *)defaultCellBackgroundColor {
	return [UIColor clearColor];
}

+ (UIColor *)defaultCellTitleTextColor {
	return [UIColor blackColor];
}

+ (UIColor *)defaultCellValueTextColor {
	return [UIColor colorWithWhite:.5 alpha:1.0];
}

+ (UIColor *)defaultCellButtonTextColor {
	return [self systemBlueColor];
}

+ (UIColor *)defaultCellInputTextColor {
	return [UIColor blackColor];
}

+ (UIColor *)defaultCellInputPlaceholderTextColor {
	return [UIColor colorWithWhite:0 alpha:.2];
}

+ (UIColor *)defaultCellPlainTextColor {
	return [UIColor colorWithWhite:.5 alpha:1.0];
}

+ (UIColor *)defaultCellSelectedBackgroundColor {
	return [UIColor colorWithWhite:.9 alpha:1.0];
}

+ (UIColor *)defaultCellSelectedTitleTextColor {
	return [UIColor blackColor];
}

+ (UIColor *)defaultCellSelectedValueTextColor {
	return [UIColor colorWithWhite:.5 alpha:1.0]; // same as defaultCellValueTextColor
}

+ (UIColor *)defaultCellSelectedButtonTextColor {
	return [self systemBlueColor];
}

+ (UIColor *)defaultCellHeaderFooterViewBackgroundColor {
	return [UIColor colorWithWhite:.85 alpha:1.0];
}

+ (UIColor *)defaultCellHeaderFooterViewTitleTextColor {
	return [UIColor colorWithWhite:.5 alpha:1.0];
}

+ (UIColor *)defaultSwitchThumbColor {
	return nil;
}

+ (UIColor *)defaultSwitchOnColor {
	return nil;
}

+ (UIColor *)defaultSwitchOffColor {
	return nil;
}

//////////////////////////////////////////
////////// Sizes and Dimensions //////////
//////////////////////////////////////////

+ (CGFloat)defaultCornerRadius {
	return 0.0;
}

+ (CGFloat)defaultHeightOfCellOfType:(PWWidgetCellType)type forOrientation:(PWWidgetOrientation)orientation {
	switch (type) {
		case PWWidgetCellTypeNormal:
		default:
			return 44.0;
		case PWWidgetCellTypeTextArea:
			return 44.0 * 3;
	}
}

//////////////////////////////////////////////////////////////////////

/**
 * System colors
 **/

+ (UIColor *)systemBlueColor {
	return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]; // default iOS 7 blue
}

//////////////////////////////////////////////////////////////////////

- (void)dealloc {
	
	DEALLOCLOG;
	
	RELEASE(_name)
	RELEASE(_bundle)
	RELEASE(_preferredTintColor)
	RELEASE(_preferredBarTextColor)
	
	[super dealloc];
}

@end