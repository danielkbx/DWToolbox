//
//  UIColor+Additions.h
//  dwToolbox
//
//  Created by Daniel Wetzel on 22.07.12.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorFromHexString:(NSString*)hexString;

@property (nonatomic, readonly) CGFloat red;
@property (nonatomic, readonly) CGFloat green;
@property (nonatomic, readonly) CGFloat blue;
@property (nonatomic, readonly) CGFloat alpha;

@property (nonatomic, readonly) UIColor *lighterColor;
@property (nonatomic, readonly) UIColor *darkerColor;

@end
