//
//  DWCheckbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import "DWStatusLight.h"

#import "UIImage+DWToolbox.h"
#import "NSBundle+DWToolbox.h"
#import "UIColor+DWToolbox.h"
#import "UIColor+Expanded.h"

@interface DWStatusLight ()

@end

@implementation DWStatusLight

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self prepareControl];
    }
    return self;
}

- (void)awakeFromNib {
	[self prepareControl];
	[self sizeToFit];
}

- (void)prepareControl {
	self.backgroundColor = [UIColor clearColor];
	self.borderColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
	self.lightColor = [UIColor colorWithHexString:@"#3dba72"];
}

- (void)setLightColor:(UIColor *)lightColor {
	if (lightColor != self.lightColor) {
		self->_lightColor = lightColor;
		[self setNeedsDisplay];
	}
}

- (void)setBorderColor:(UIColor *)borderColor {
	if (borderColor != self.borderColor) {
		self->_borderColor = borderColor;
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect circleRect = CGRectInset(self.bounds, 3.0f, 3.0f);
	
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
	
	[self.lightColor setFill];
	[circlePath fill];
	
	[self.borderColor setStroke];
	circlePath.lineWidth = 2.0f;
	[circlePath stroke];
	
	CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
	size_t numberOfLocations = 2;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat colors[8] = { 1.0, 1.0, 1.0, 0.6,  1.0, 1.0, 1.0, 0.2 };
	
	CGGradientRef roundGradient = CGGradientCreateWithColorComponents(rgbColorspace, colors, locations, numberOfLocations);
	
	CGRect currentBounds = self.bounds;
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
	
	CGContextSaveGState(context);
	CGContextAddEllipseInRect(context, CGRectInset(circleRect, -1.0f, -1.0f));
	CGContextClip(context);
	CGContextDrawLinearGradient(context, roundGradient, topCenter, midCenter, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(roundGradient);
	CGColorSpaceRelease(rgbColorspace);
	
}

@end
