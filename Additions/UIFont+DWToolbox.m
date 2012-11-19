//
//  UIFont+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 19.11.12.
//
//

#import "UIFont+DWToolbox.h"

#import "DWConfiguration.h"

@implementation UIFont (DWToolbox)

+ (UIFont *)fontFromConfigurationKey:(NSString *)key {
	assert(key);
	NSString *nameKey = [key stringByAppendingString:@".name"];
	NSString *sizeKey = [key stringByAppendingString:@".size"];
	return [self fontFromConfigurationNameKey:nameKey sizeKey:sizeKey];
}

+ (UIFont *)fontFromConfigurationNameKey:(NSString *)nameKey sizeKey:(NSString *)sizeKey {
	assert(nameKey);
	assert(sizeKey);
	
	UIFont *font = nil;
	
	id nameString = [[DWConfiguration UICustomizatingConfiguration] customValueForKey:nameKey];
	id sizeNumber = [[DWConfiguration UICustomizatingConfiguration] customValueForKey:sizeKey];
	
	
	if (![sizeNumber isKindOfClass:[NSNumber class]]) {
		sizeNumber = [NSNumber numberWithFloat:[UIFont labelFontSize]];
	}
	
	CGFloat fontSize = ((NSNumber *)sizeNumber).floatValue;
	NSString *fontName = nil;
	if ([nameString isKindOfClass:[NSString class]]) {
		fontName = ((NSString *)nameString);
	}
	
	if (fontName.length == 0) {
		fontName = @"system";
	}
	
	font = [UIFont fontWithCustomName:fontName size:fontSize];
	
	return font;
}

+ (UIFont *)customFontWithSize:(CGFloat)fontSize {
	
	UIFont *font = nil;
	NSString *fontName = nil;
	id nameString = [[DWConfiguration UICustomizatingConfiguration] customValueForKey:@"general.font.name"];
	if (![nameString isKindOfClass:[NSString class]]) {
		fontName = @"system";
	} else {
		fontName = ((NSString *)nameString);
	}
	
	font = [self fontWithCustomName:fontName size:fontSize];

	return font;
}

+ (UIFont *)customFontWithSizeKey:(NSString *)sizeKey {
	
	id sizeNumber = [[DWConfiguration UICustomizatingConfiguration] customValueForKey:sizeKey];
	if (![sizeNumber isKindOfClass:[NSNumber class]]) {
		sizeNumber = [NSNumber numberWithFloat:[UIFont labelFontSize]];
	}
	
	CGFloat fontSize = ((NSNumber *)sizeNumber).floatValue;
	return [self customFontWithSize:fontSize];
}

+ (UIFont *)fontWithCustomName:(NSString *)fontName size:(CGFloat)fontSize {

	UIFont *font = nil;
	
	if ([fontName isEqualToString:@"system"]) {
		font = [UIFont systemFontOfSize:fontSize];
	} else if ([fontName isEqualToString:@"bold"]) {
		font = [UIFont boldSystemFontOfSize:fontSize];
	} else if ([fontName isEqualToString:@"italic"]) {
		font = [UIFont italicSystemFontOfSize:fontSize];
	} else {
		font = [UIFont fontWithName:fontName size:fontSize];
	}
	
	return font;
}

@end
