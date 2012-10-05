//
//  UIColor+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 22.07.12.
//
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)



- (CGFloat)red
{
	if (CGColorGetNumberOfComponents(self.CGColor))
	{
		return CGColorGetComponents(self.CGColor)[0];
	}
	return 0.0f;
}

- (CGFloat)green
{
	if (CGColorGetNumberOfComponents(self.CGColor))
	{
		return CGColorGetComponents(self.CGColor)[1];
	}
	return 0.0f;
}

- (CGFloat)blue
{
	if (CGColorGetNumberOfComponents(self.CGColor))
	{
		return CGColorGetComponents(self.CGColor)[2];
	}
	return 0.0f;
}

- (CGFloat)alpha
{
	if (CGColorGetNumberOfComponents(self.CGColor))
	{
		return CGColorGetComponents(self.CGColor)[3];
	}	
	return 0.0f;
}

- (UIColor *)lighterColor
{
	CGFloat lighterNumber = 0.2f;
	
	CGFloat red = self.red;
	CGFloat green = self.green;
	CGFloat blue = self.blue;
	red = MIN(1,red + lighterNumber);
	green = MIN(1,green + lighterNumber);
	blue = MIN(1, blue + lighterNumber);
	return [UIColor colorWithRed:red
						   green:green
							blue:blue
						   alpha:self.alpha];
}

- (UIColor *)darkerColor
{
	CGFloat darkerNumber = 0.2f;
	
	CGFloat red = self.red;
	CGFloat green = self.green;
	CGFloat blue = self.blue;
	red = MAX(0.0f,red - darkerNumber);
	green = MAX(0.0f,green - darkerNumber);
	blue = MAX(0.0f, blue - darkerNumber);
	return [UIColor colorWithRed:red
						   green:green
							blue:blue
						   alpha:self.alpha];
	
}

@end
