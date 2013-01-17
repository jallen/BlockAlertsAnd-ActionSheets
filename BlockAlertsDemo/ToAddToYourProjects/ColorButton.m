//
//  ColorButton.m
//  InstaQuote
//
//  Created by Jared Allen on 1/16/13.
//  Copyright (c) 2013 Peapod Labs. All rights reserved.
//

#import "ColorButton.h"

@interface ColorButton() {
	BOOL _isSelected;
}

@end

@implementation ColorButton

@synthesize cornerRadius;
@synthesize borderWidth;

- (id)initWithFrame:(CGRect)frame {
	if (!(self = [super initWithFrame:frame])) return nil;
	
	self.cornerRadius = 6.f;
	self.borderWidth = 3.5f;
	self.color = [UIColor colorWithRed:56.f/255.f green:192.f/255.f blue:252.f/255.f alpha:1.0]; // a nice blue
	self.backgroundColor = [UIColor clearColor];
  
	self.titleLabel.font = [UIFont boldSystemFontOfSize:20.f];
	self.titleLabel.minimumFontSize = 6;
	self.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.titleLabel.textAlignment = UITextAlignmentCenter;
	self.titleLabel.shadowOffset = CGSizeMake(0, -1);
	self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
	self.backgroundColor = [UIColor clearColor];
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor colorWithWhite:0.3 alpha:1.0] forState:UIControlStateNormal];
	
	return self;
}

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_isSelected = YES;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	if (!CGRectContainsPoint(self.bounds, touchPoint)) {
		if (_isSelected) {
			_isSelected = NO;
			[self setNeedsDisplay];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (_isSelected) {
		_isSelected = NO;
		[self setNeedsDisplay];
	}
	
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	if (CGRectContainsPoint(self.bounds, touchPoint)) {
		[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)drawRect:(CGRect)rect {
	
	//// General Declarations
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat highlightWidth = 1.f;
	
	//// whiteHighlight Drawing
	UIBezierPath* whiteHighlightPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, rect.size.width, rect.size.height)
																																cornerRadius: self.cornerRadius + 2.0];
	[[UIColor colorWithWhite:1.0 alpha:0.2] setFill];
	[whiteHighlightPath fill];
	
	
	//// wellRect Drawing
	UIBezierPath* wellRectPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(self.borderWidth * 0.5,
																																									 self.borderWidth * 0.5,
																																									 rect.size.width - self.borderWidth,
																																									 rect.size.height - self.borderWidth - highlightWidth)
																													cornerRadius: self.cornerRadius];
	CGContextSaveGState(context);
	[self.color setFill];
	[wellRectPath fill];
	
	CGContextRestoreGState(context);
	
	[[UIColor blackColor] setStroke];
	wellRectPath.lineWidth = self.borderWidth;
	[wellRectPath stroke];

	// innerRect Drawing
	UIBezierPath* innerRectPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(self.borderWidth,
																																										self.borderWidth,
																																										rect.size.width - borderWidth * 2,
																																										rect.size.height - self.borderWidth * 2)
																																	cornerRadius: self.cornerRadius - highlightWidth];
	
	//// Gradient Declarations
	NSArray* innerRectColors;
	if (_isSelected) {
		innerRectColors = @[
			(id)[UIColor colorWithWhite:0.0 alpha:0.2].CGColor,
			(id)[UIColor colorWithWhite:0.0 alpha:0.6].CGColor
		];
	} else {
		innerRectColors = @[
			(id)[UIColor colorWithWhite:1.0 alpha:0.7].CGColor,
			(id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor
		];
	}
	CGFloat gradientLocations[] = {0, 1.0};
	CGGradientRef innerRectGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)innerRectColors, gradientLocations);
	
	//// Rectangle Drawing
	CGContextSaveGState(context);
	CGContextSetBlendMode(context, kCGBlendModeHardLight);
	[innerRectPath addClip];
	CGContextDrawLinearGradient(context,
															innerRectGradient,
															CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect)),
															CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect)), 0);
	CGContextRestoreGState(context);
	
	// gradientRectDrawing
	CGFloat gradientRectOffset = 1.f;
	UIBezierPath* gradientRectPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(self.borderWidth + gradientRectOffset,
																																											 self.borderWidth + gradientRectOffset,
																																											 rect.size.width - (self.borderWidth + gradientRectOffset) * 2,
																																											 rect.size.height - highlightWidth - (self.borderWidth + gradientRectOffset) * 2)
																															cornerRadius: self.cornerRadius - highlightWidth - gradientRectOffset];
	
	//// Rectangle Drawing
	CGContextSaveGState(context);
	CGContextSetBlendMode(context, kCGBlendModeSoftLight);
	[gradientRectPath addClip];
	[[UIColor colorWithWhite:0.0 alpha:0.4] setFill];
	[gradientRectPath fill];
	CGContextRestoreGState(context);
	
	//// Cleanup
	CGGradientRelease(innerRectGradient);
	CGColorSpaceRelease(colorSpace);
}


@end
