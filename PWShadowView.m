//
//  ProWidgets
//
//  1.1.0
//
//  Created by Alan Yip on 6 Jul 2014
//  Copyright 2014 Alan Yip. All rights reserved.
//

#import "PWShadowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PWShadowView

- (instancetype)initWithCornerRadius:(CGFloat)cornerRadius {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.image = [self generateShadowImage:cornerRadius];
	}
	return self;
}

- (UIImage *)generateShadowImage:(CGFloat)cornerRadius {
	
	UIColor *shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
	
	CGFloat edge = PWShadowViewRadius + cornerRadius;
	CGFloat length = edge * 2 + 1.0;
	CGSize size = CGSizeMake(length, length);
	CGRect rect = CGRectMake(PWShadowViewRadius, PWShadowViewRadius, cornerRadius * 2 + 1.0, cornerRadius * 2 + 1.0);
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// add a clip to remove the filling color
	CGRect boundingRect = CGContextGetClipBoundingBox(context);
	CGContextAddRect(context, boundingRect);
	CGContextAddPath(context, path.CGPath);
	CGContextEOClip(context);
	[[UIColor blackColor] setFill];
	CGContextAddPath(context, path.CGPath);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), PWShadowViewRadius, shadowColor.CGColor);
	CGContextSetBlendMode (context, kCGBlendModeNormal);
	CGContextFillPath(context);
	
	UIImage *rendered = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [rendered resizableImageWithCapInsets:UIEdgeInsetsMake(edge, edge, edge, edge) resizingMode:UIImageResizingModeStretch];
}

@end