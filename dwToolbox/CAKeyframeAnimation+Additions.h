//
//  CAKeyframeAnimation+Additions.h
//  The Diary
//
//  Created by Daniel Wetzel on 25.01.12.
//  Copyright (c) 2012 danielkbx. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAKeyframeAnimation (Additions)

+ (CAKeyframeAnimation *)bumpInAnimation:(CATransform3D *)lastTransform;
+ (CAKeyframeAnimation *)bumpOutAnimation:(CATransform3D *)lastTransform;

@end
