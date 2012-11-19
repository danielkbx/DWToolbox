//
//  DWConfiguration.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 02.10.12.
//  Copyright (c) 2012 Daniel Wetzel. All rights reserved.
//

#import "DWConfiguration.h"

#import "UIColor+DWToolbox.h"
#import "NSString+DWToolbox.h"

#define kSSConfigurationDefaultName @"configuration"		// this means we look for a file called configuration.plist in the main bundle

NSString * const DWConfigurationUICustomizationAppliedNotification = @"DWConfigurationUICustomizationAppliedNotification";

static DWConfiguration *UIConfiguration;

@interface DWConfiguration ()

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong, readwrite) NSString *identifier;

@end

@implementation DWConfiguration

+ (DWConfiguration *)defaultConfiguration {
	
	static DWConfiguration *defaultConfiguration = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultConfiguration = [[DWConfiguration alloc] initWithFilename:kSSConfigurationDefaultName];
	});
	
	return defaultConfiguration;
}

+ (DWConfiguration *)UICustomizatingConfiguration {
	return UIConfiguration;
}

- (id)initWithFilename:(NSString *)filename {
	if ((self = [super init])) {
		
		NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"plist"];
		if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path] isDirectory:NO]) {
			
			self.data = [NSDictionary dictionaryWithContentsOfURL:fileURL];
			self.identifier = [filename MD5];
		} else {
			NSException *e = [[NSException alloc] initWithName:@"ConfigurationFileNotFoundException" reason:@"Could not load configuration file, does not exist" userInfo:nil];
			[e raise];
		}
	}
	return self;
}

- (id)customValueForKey:(NSString *)key {
	return [self->_data objectForKey:key];
}

- (void)applyUICustomizations {
	[self applyUICustomizationsWithOptions:
	 DWConfigurationTintColorNavigationbarElement |
	 DWConfigurationTintColorTabbarElement |
	 DWConfigurationTintColorButtonElement];
}

- (void)applyUICustomizationsWithOptions:(NSUInteger)options {
	
	DWLog(@"Applying UI costumizations");
	
	UIConfiguration = self;

	BOOL applyToNavigationbar = ((options | DWConfigurationTintColorNavigationbarElement) == options);
	BOOL applyToTabbar = ((options | DWConfigurationTintColorTabbarElement) == options);
	BOOL applyToButtons = ((options | DWConfigurationTintColorButtonElement) == options);
	
	UIColor *generalTintColor = [UIColor colorFromCustomizationKey:@"general.tintColor"];
	if (generalTintColor) {
		if (applyToNavigationbar) {
			[[UINavigationBar appearance] setTintColor:generalTintColor];
		}
		if (applyToTabbar) {
			[[UITabBar appearance] setTintColor:generalTintColor];
		}
		if (applyToButtons) {
			[[UIButton appearance] setTintColor:generalTintColor];
		}
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DWConfigurationUICustomizationAppliedNotification object:self];
}

@end
