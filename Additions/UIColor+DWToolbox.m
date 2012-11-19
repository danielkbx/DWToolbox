//
//  UIColor+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 22.07.12.
//
//

#import "UIColor+DWToolbox.h"
#import "UIColor+Expanded.h"

#import "DWConfiguration.h"

@implementation UIColor (DWToolbox)

+ (UIColor *)colorFromCustomizationKey:(NSString *)key {
	
	UIColor *color = nil;
	
	static NSMutableDictionary *customColors = nil;
	if (customColors == nil) {
		customColors = [[NSMutableDictionary alloc] init];
	}
	
	id value = [customColors objectForKey:key];
	if ([value isKindOfClass:[NSNull class]]) {
		color = nil;
	} else if (color == nil) {
		id colorString = [[DWConfiguration UICustomizatingConfiguration] customValueForKey:key];
		if (colorString && [colorString isKindOfClass:[NSString class]]) {
			color = [UIColor colorWithHexString:(NSString *)colorString];
		}
		if (color == nil) {
			[customColors setObject:[NSNull null] forKey:key];
		} else {
			[customColors setObject:color forKey:key];
		}
	}
	
	return color;
}

@end