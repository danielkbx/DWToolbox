//
//  UIView+Additions.h
//  dwToolbox
//
//  Created by danielkbx on 28.09.10.
//  Copyright 2010 danielkbx. All rights reserved.
//

#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Additions.h"

@implementation UIView (Additions)

CGPoint DWMakeCenter(CGPoint point, CGSize size) {
    // make sure that the corners are on integral points
    return (CGPoint){round(point.x) + size.width/2.0 - ((int)(size.width/2)), round(point.y) + size.height/2.0 - ((int)(size.height/2))};
}


- (UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor clearColor] setFill];
	CGContextFillRect(context, self.bounds);
    [self.layer renderInContext:context];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
