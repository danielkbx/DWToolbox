//
//  UIView+Additions.h
//  dwToolbox
//
//  Created by danielkbx on 28.09.10.
//  Copyright 2010 danielkbx. All rights reserved.
//

#import <Foundation/Foundation.h>

CGPoint DWMakeCenter(CGPoint point, CGSize size);
CGPoint DWMakeCenterInSize(CGSize containerSize, CGSize size);

@interface UIView (DWToolbox)

- (UIImage *)image;

@end
