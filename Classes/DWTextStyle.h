//
//  DWTextStyle.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 19.11.12.
//
//

#import <Foundation/Foundation.h>
/**
 
 DWTextStyle loads and holds attributes for texts which can be used e.g. with DWLabel.
 To load the settings from a DWConfiguration instance, this instance must be the applied configuration. Therefore, you must call
 applyUICustomizations on this DWConfiguration instance.
 
 
 
 */
@interface DWTextStyle : NSObject

@property (nonatomic, copy) UIFont *font;
@property (nonatomic, copy) UIColor *color;

@property (nonatomic, strong, readonly) NSString *fontNameKey;
@property (nonatomic, strong, readonly) NSString *fontSizeKey;
@property (nonatomic, strong, readonly) NSString *colorKey;

+ (DWTextStyle *)textStyleWithKey:(NSString *)key;
+ (DWTextStyle *)textStyleWithFontKey:(NSString *)fontKey colorKey:(NSString *)colorKey;
+ (DWTextStyle *)textStyleWithFontNameKey:(NSString *)fontNameKey fontSizeKey:(NSString *)fontSizeKey colorKey:(NSString *)colorKey;

- (id)initWithCustomizationKey:(NSString *)key;
- (id)initWithCustomizationFontKey:(NSString *)fontKey colorKey:(NSString *)colorKey;
- (id)initWithCustomizationFontNameKey:(NSString *)fontNameKey fontSizeKey:(NSString *)fontSizeKey colorKey:(NSString *)colorKey;

- (BOOL)isEqualToTextStyle:(DWTextStyle *)style;

@end
