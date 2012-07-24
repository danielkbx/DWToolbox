//
//  DWTouchpad.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 19.07.12.
//
//

#import "DWTouchpad.h"

@implementation DWTouchpad

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *padPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:7];
	
	[[UIColor whiteColor] setStroke];
	[padPath stroke];
	
}


@end
