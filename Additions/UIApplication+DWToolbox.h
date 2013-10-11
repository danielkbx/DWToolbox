//
//  UIApplication+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 11.10.13.
//
//

#import <UIKit/UIKit.h>

@interface UIApplication (DWToolbox)

@property (nonatomic, assign) NSUInteger activityCounter;

- (void)increaseActivityCounter;
- (void)decreaseActivityCounter;

@end
