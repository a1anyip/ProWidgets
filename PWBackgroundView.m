//
//  ProWidgets
//
//  1.0.0
//
//  Created by Alan Yip on 18 Jan 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWBackgroundView.h"

@implementation PWBackgroundView

- (instancetype)init {
	if ((self = [super init])) {
		self.userInteractionEnabled = YES;
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:PWBackgroundViewAlpha];
		self.alpha = 0.0;
	}
	return self;
}

- (void)show:(BOOL)shouldAnimateTransform {
	
	[self clearMask];
	self.shouldAnimateTransform = shouldAnimateTransform;
	
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
}

- (void)setMaskRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius animated:(BOOL)animated {
	
	LOG(@"setMaskRect ***** %@ <animated: %@> <_shouldAnimateTransform: %@>", NSStringFromCGRect(rect), animated ? @"YES" : @"NO", _shouldAnimateTransform ? @"YES" : @"NO");
	
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
	
	if (_shouldAnimateTransform) {
		
		// from rect
		CGFloat scale = 1.2;
		CGRect fromRect = rect;
		fromRect.size.width *= scale;
		fromRect.size.height *= scale;
		fromRect.origin.x -= (fromRect.size.width - rect.size.width) / 2;
		fromRect.origin.y -= (fromRect.size.height - rect.size.height) / 2;
		fromRect.origin.x += PWSheetMotionEffectDistance; // correct the extra distance due to motion effect
		fromRect.origin.y += PWSheetMotionEffectDistance;
		
		UIBezierPath *fromPath = [UIBezierPath bezierPathWithRect:self.bounds];
		UIBezierPath *fromRoundedPath = [UIBezierPath bezierPathWithRoundedRect:fromRect cornerRadius:cornerRadius];
		[fromPath appendPath:fromRoundedPath];
		[fromPath setUsesEvenOddFillRule:YES];
		
		fromCGPath = fromPath.CGPath;
		
	} else {
		fromCGPath = mask.path; // current mask path
	}
	
	if (animated || _shouldAnimateTransform) {
		
		CAMediaTimingFunction *function = nil;
		
		if (_shouldAnimateTransform)
			function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		else
			function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		[CATransaction begin];
		[CATransaction setAnimationDuration:PWAnimationDuration];
		[CATransaction setAnimationTimingFunction:function];
		
		// to make sure no
		__block CAShapeLayer *blockMask = [_mask retain];
		__block CGPathRef blockToCGPath = CGPathRetain(toCGPath);
		[CATransaction setCompletionBlock:^{
			if (blockMask != nil && blockToCGPath != NULL) {
				blockMask.path = blockToCGPath;
			}
			CGPathRelease(blockToCGPath), blockToCGPath = NULL;
			[blockMask release], blockMask = nil;
		}];
		
		CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
		pathAnimation.fromValue = (id)fromCGPath;
		pathAnimation.toValue = (id)toCGPath;
		pathAnimation.fillMode = kCAFillModeForwards;
		pathAnimation.removedOnCompletion = NO;
		
		[mask addAnimation:pathAnimation forKey:@"path"];
		[CATransaction commit];
		
		// reset flag
		_shouldAnimateTransform = NO;
		
	} else {
		mask.path = toCGPath;
	}
}

- (void)dealloc {
	DEALLOCLOG;
	self.layer.mask = nil;
	RELEASE(_mask)
	[super dealloc];
}

@end