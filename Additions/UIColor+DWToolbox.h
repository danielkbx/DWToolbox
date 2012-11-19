//
//  UIColor+Additions.h
//  dwToolbox
//
//  Created by Daniel Wetzel on 22.07.12.
//
//

#import <UIKit/UIKit.h>
#import "UIColor+Expanded.h"

@interface UIColor (DWToolbox)

+ (UIColor *)colorFromCustomizationKey:(NSString *)key;

@end