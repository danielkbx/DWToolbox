//
//  UIFont+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 19.11.12.
//
//

#import <UIKit/UIKit.h>

@interface UIFont (DWToolbox)

+ (UIFont *)fontFromConfigurationKey:(NSString *)key;
+ (UIFont *)fontFromConfigurationNameKey:(NSString *)nameKey sizeKey:(NSString *)sizeKey;

+ (UIFont *)customFontWithSize:(CGFloat)size;
+ (UIFont *)customFontWithSizeKey:(NSString *)sizeKey;

@end
