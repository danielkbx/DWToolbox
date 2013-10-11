//
//  UIApplication+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 11.10.13.
//
//

#import "UIApplication+DWToolbox.h"

#import <objc/runtime.h>

@implementation UIApplication (DWToolbox)

- (void)setActivityCounter:(NSUInteger)activityCounter {
	objc_setAssociatedObject(self, @selector(activityCounter), [NSNumber numberWithUnsignedInteger:activityCounter], OBJC_ASSOCIATION_COPY);
}

- (NSUInteger)activityCounter {
	NSNumber *number = objc_getAssociatedObject(self, @selector(activityCounter));
	return [number unsignedIntegerValue];
}

- (void)increaseActivityCounter {
	@synchronized(self) {
		self.activityCounter++;
		[self setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)decreaseActivityCounter {
	@synchronized(self) {
		if (self.activityCounter > 0) {
			self.activityCounter--;
			if (self.activityCounter <= 0) {
				[self setNetworkActivityIndicatorVisible:NO];
			}
		}
	}
}

@end
