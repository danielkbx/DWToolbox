//
//  DWConfiguration.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 02.10.12.
//  Copyright (c) 2012 Daniel Wetzel. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 DWConfiguration provides an easy way to custimize the look of you app by defining a set of fonts, sizes and colors in a file called configuration.plist (you can set another).
 This file can contain any other setting which can be read by calling customStringForKey:.
 
 The use the UI customization:
 
 1.) Instanciate the class
	- defaultConfiguration uses "configuration.plist" as file
	- initWithFilename: uses the given filename
 2.) call applyUICustomizations
 3.) You can access the configuration that was applied before by calling UICustomizatingConfiguration on the class
 
 */

typedef enum {
	DWConfigurationTintColorNoElement					= 0 << 0,
	DWConfigurationTintColorNavigationbarElement		= 1 << 0,
	DWConfigurationTintColorTabbarElement				= 1 << 1,
	DWConfigurationTintColorButtonElement				= 1 << 2,
} DWConfigurationTintColorElements;

extern NSString * const DWConfigurationUICustomizationAppliedNotification;

@interface DWConfiguration : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;

+ (DWConfiguration *)defaultConfiguration;
+ (DWConfiguration *)UICustomizatingConfiguration;

- (id)initWithFilename:(NSString *)filename;

- (id)customValueForKey:(NSString *)key;

#pragma mark - UI

- (void)applyUICustomizations;
- (void)applyUICustomizationsWithOptions:(NSUInteger)options;

@end
