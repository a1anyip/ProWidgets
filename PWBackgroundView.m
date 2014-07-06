//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWBackgroundView.h"
#import "PWController.h"

@implementation PWBackgroundView

- (instancetype)init {
	if ((self = [super init])) {
		self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:PWBackgroundViewAlpha];
		self.alpha = 0.0;
	}
	return self;
}

- (void)show {
	
	self.alpha = 0.0;
	[UIView animateWithDuration:PWAnimationDuration animations:^{
		self.alpha = 1.0;
	}];
}

- (void)hide {
	
	[self clearMask];
	
	self.alpha = 1.0;
	[UIView animateWithDuration:PWAnimationDuration animations:^{
		self.alpha = 0.0;
	}];
}

- (void)createMask {
	
	if (_mask == nil) {
		_mask = [[CAShapeLayer layer] retain];
		_mask.fillRule = kCAFillRuleEvenOdd;
		_mask.fillColor = [UIColor blackColor].CGColor;
	}
	
	// update frame
	_mask.frame = self.bounds;
	
	if (self.layer.mask == nil) {
		self.layer.mask = _mask;
	}
}

- (void)clearMask {
	
	self.layer.mask = nil;
	RELEASE(_mask)
	
	if (_finalPath != NULL) {
		CGPathRelease(_finalPath);
		_finalPath = NULL;
	}
	
	_finalPathCount = 0;
}

- (void)setMaskRect:(CGRect)rect fromRect:(CGRect)fromRect cornerRadius:(CGFloat)cornerRadius animationType:(PWBackgroundViewAnimationType)animationType presentationStyle:(PWWidgetPresentationStyle)presentationStyle {
	
	LOG(@"setMaskRect <rect: %@> <fromRect: %@> <animationType: %d> <presentationStyle: %d>", NSStringFromCGRect(rect), NSStringFromCGRect(fromRect), (int)animationType, presentationStyle);
	
	// to ensure the mask is created
	[self createMask];
	
	CAShapeLayer *mask = _mask;
	
	// to rect
	CGRect toRect = rect;
	toRect.origin.x += PWSheetMotionEffectDistance; // correct the extra distance due to motion effect
	toRect.origin.y += PWSheetMotionEffectDistance;
	
	CGFloat adjustment = 0.3;
	toRect = CGRectInset(toRect, adjustment, adjustment);
	
	// create a shape with given mask rect and corner radius
	UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.bounds];
	UIBezierPath *toRoundedPath = [UIBezierPath bezierPathWithRoundedRect:toRect cornerRadius:cornerRadius];
	[toPath appendPath:toRoundedPath];
	[toPath setUsesEvenOddFillRule:YES];
	
	CGPathRef fromCGPath = NULL;
	CGPathRef toCGPath = toPath.CGPath;
	
	if (animationType == PWBackgroundViewAnimationTypePresentation || animationType == PWBackgroundViewAnimationTypeMaximization) {
		
		if (animationType == PWBackgroundViewAnimationTypePresentation) {
			
			CGSize screenSize = [[UIScreen mainScreen] bounds].size;
			CGFloat screenHeight = [PWController isLandscape] ? screenSize.width : screenSize.height;
			
			switch (presentationStyle) {
				
				case PWWidgetPresentationStyleZoom:
				{
					// from rect
					CGFloat scale = 1.2;
					
					fromRect = rect;
					fromRect.size.width *= scale;
					fromRect.size.height *= scale;
					fromRect.origin.x -= (fromRect.size.width - rect.size.width) / 2;
					fromRect.origin.y -= (fromRect.size.height - rect.size.height) / 2;
					
				} break;
				
				case PWWidgetPresentationStyleFade:
				{
					// rect unchanged
					fromRect = rect;
					
				} break;
					
				case PWWidgetPresentationStyleSlideUp:
				{
					fromRect = rect;
					fromRect.origin.y = screenHeight;
					
				} break;
				
				case PWWidgetPresentationStyleSlideDown:
				{
					fromRect = rect;
					fromRect.origin.y = -fromRect.size.height;
					
				} break;
				
				default: break;
			}
		}
		
		fromRect.origin.x += PWSheetMotionEffectDistance; // correct the extra distance due to motion effect
		fromRect.origin.y += PWSheetMotionEffectDistance;
		
		UIBezierPath *fromPath = [UIBezierPath bezierPathWithRect:self.bounds];
		UIBezierPath *fromRoundedPath = [UIBezierPath bezierPathWithRoundedRect:fromRect cornerRadius:cornerRadius];
		[fromPath appendPath:fromRoundedPath];
		[fromPath setUsesEvenOddFillRule:YES];
		
		fromCGPath = fromPath.CGPath;
	}
	
	if (animationType != PWBackgroundViewAnimationTypeNone) {
		
		CAMediaTimingFunction *function = nil;
		
		if (animationType == PWBackgroundViewAnimationTypePresentation || animationType == PWBackgroundViewAnimationTypeMaximization)
			function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		else
			function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:(animationType == PWBackgroundViewAnimationTypeMaximization ? PWMaxMinimizationDuration : PWAnimationDuration)];
		[CATransaction setAnimationTimingFunction:function];
		
		// there is another animation ongoing
		if (_finalPath != NULL) CGPathRelease(_finalPath);
		_finalPath = CGPathRetain(toCGPath);
		
		NSUInteger count = ++_finalPathCount;
		[CATransaction setCompletionBlock:^{
			if (_mask != nil && _finalPath != NULL && _finalPathCount == count) {
				_mask.path = _finalPath;
				[_mask removeAllAnimations];
				CGPathRelease(_finalPath), _finalPath = NULL;
			} else {
				LOG(@"PWBackgroundView: count does not match _finalPathCount");
			}
		}];
		
		CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
		if (fromCGPath != NULL) {
			pathAnimation.fromValue = (id)fromCGPath;
		}
		pathAnimation.toValue = (id)toCGPath;
		pathAnimation.fillMode = kCAFillModeForwards;
		pathAnimation.removedOnCompletion = NO;
		
		[mask addAnimation:pathAnimation forKey:@"path"];
		[CATransaction commit];
		
	} else {
		mask.path = toCGPath;
	}
}

- (void)dealloc {
	DEALLOCLOG;
	[self clearMask];
	[super dealloc];
}

@end