//
//  DWTextStyle.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 19.11.12.
//
//

#import "DWTextStyle.h"
#import "DWTextStyle_Private.h"

#import "DWConfiguration.h"
#import "UIColor+DWToolbox.h"
#import "UIFont+DWToolbox.h"


@implementation DWTextStyle

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[DWTextStyle class]]) {
		return [self isEqualToTextStyle:object];
	}
	return NO;
}

- (BOOL)isEqualToTextStyle:(DWTextStyle *)style {
	if ([style isKindOfClass:[DWTextStyle class]]) {
		if ([self.color.hexStringFromColor isEqualToString:style.color.hexStringFromColor] &&
			[self.font.fontName isEqualToString:style.font.fontName] &&
			self.font.pointSize == style.font.pointSize) {
			return YES;
		}
	}
	return NO;
}

+ (DWTextStyle *)textStyleWithKey:(NSString *)key {
	DWTextStyle *style = [[DWTextStyle alloc] initWithCustomizationKey:key];
	return style;
}

+ (DWTextStyle *)textStyleWithFontKey:(NSString *)fontKey colorKey:(NSString *)colorKey {
	DWTextStyle *style = [[DWTextStyle alloc] initWithCustomizationFontKey:fontKey colorKey:colorKey];
	return style;
}

+ (DWTextStyle *)textStyleWithFontNameKey:(NSString *)fontNameKey fontSizeKey:(NSString *)fontSizeKey colorKey:(NSString *)colorKey {
	DWTextStyle *style = [[DWTextStyle alloc] initWithCustomizationFontNameKey:fontNameKey fontSizeKey:fontSizeKey colorKey:colorKey];
	return style;
}

- (id)initWithCustomizationKey:(NSString *)key {
	if (key.length > 0) {
		NSString *fontKey = [key stringByAppendingString:@".font"];
		NSString *colorKey = [key stringByAppendingString:@".textColor"];
		self = [self initWithCustomizationFontKey:fontKey colorKey:colorKey];
	} else {
		self = nil;
	}
	return self;
}

- (id)initWithCustomizationFontKey:(NSString *)fontKey colorKey:(NSString *)colorKey {
	if (fontKey.length > 0 && colorKey.length > 0) {
		NSString *fontNameKey = [fontKey stringByAppendingString:@".name"];
		NSString *fontSizeKey = [fontKey stringByAppendingString:@".size"];
		self = [self initWithCustomizationFontNameKey:fontNameKey fontSizeKey:fontSizeKey colorKey:colorKey];
	} else {
		self = nil;
	}
		
	return self;
}

- (id)initWithCustomizationFontNameKey:(NSString *)fontNameKey fontSizeKey:(NSString *)fontSizeKey colorKey:(NSString *)colorKey {
	if ((self = [super init])) {
		
		self.fontNameKey = [fontNameKey copy];
		self.fontSizeKey = [fontSizeKey copy];
		self.colorKey = [colorKey copy];
		
		self.color = [UIColor colorFromCustomizationKey:colorKey];
		self.font = [UIFont fontFromConfigurationNameKey:fontNameKey sizeKey:fontSizeKey];
		
	}
	return self;
}

@end