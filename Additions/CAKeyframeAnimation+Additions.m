//
//  CAKeyframeAnimation+Additions.m
//  The Diary
//
//  Created by Daniel Wetzel on 25.01.12.
//  Copyright (c) 2012 danielkbx. All rights reserved.
//

#import "CAKeyframeAnimation+Additions.h"

@implementation CAKeyframeAnimation (Additions)

+ (CAKeyframeAnimation *)bumpInAnimation:(CATransform3D *)lastTransform
{
	CAKeyframeAnimation *bumpInAnimation= [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	bumpInAnimation.keyTimes = [NSArray arrayWithObjects:
											  [NSNumber numberWithFloat:0.0f],
											  [NSNumber numberWithFloat:0.8f],
											  [NSNumber numberWithFloat:1.0f],nil];
	CATransform3D finalTransform = CATransform3DMakeScale(1.0f, 1.0f, 1.0f);
	
	if (lastTransform != NULL)
	{
		*lastTransform = finalTransform;
	}
						
	bumpInAnimation.values = [NSArray arrayWithObjects:
											[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
											[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
											[NSValue valueWithCATransform3D:finalTransform],								 
											nil];	
	bumpInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	bumpInAnimation.duration = 0.4f;
	bumpInAnimation.delegate = self;
	bumpInAnimation.removedOnCompletion = NO;
	return bumpInAnimation;
}

+ (CAKeyframeAnimation *)bumpOutAnimation:(CATransform3D *)lastTransform
{
	CAKeyframeAnimation *bumpInAnimation= [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	bumpInAnimation.keyTimes = [NSArray arrayWithObjects:
								[NSNumber numberWithFloat:0.0f],
								[NSNumber numberWithFloat:0.08f],
								[NSNumber numberWithFloat:1.0f],nil];
	
	CATransform3D finalTransform = CATransform3DMakeScale(0.01f, 0.01f, 1.0f);
	
	if (lastTransform != NULL)
	{
		*lastTransform = finalTransform;
	}
	
	bumpInAnimation.values = [NSArray arrayWithObjects:
							  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)],
							  [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
							  [NSValue valueWithCATransform3D:finalTransform],								 
							  nil];	
	bumpInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	bumpInAnimation.duration = 0.5f;
	bumpInAnimation.delegate = self;
	bumpInAnimation.removedOnCompletion = NO;
	return bumpInAnimation;
}



@end
