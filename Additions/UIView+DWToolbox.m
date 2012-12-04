//
//  UIView+Additions.h
//  dwToolbox
//
//  Created by danielkbx on 28.09.10.
//  Copyright 2010 danielkbx. All rights reserved.
//

#import "UIView+DWToolbox.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+DWToolbox.h"

@implementation UIView (DWToolbox)

CGPoint DWMakeCenter(CGPoint point, CGSize size) {
    // make sure that the corners are on integral points
    return (CGPoint){round(point.x) + size.width/2.0 - ((int)(size.width/2)), round(point.y) + size.height/2.0 - ((int)(size.height/2))};
}

CGPoint DWMakeCenterInSize(CGSize containerSize, CGSize size) {
	return DWMakeCenter(CGPointMake(containerSize.width / 2.0f, containerSize.height / 2.0f), size);
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
