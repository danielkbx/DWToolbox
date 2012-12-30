//
//  NSObject+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.11.12.
//
//

#import "NSObject+DWToolbox.h"
#import <objc/runtime.h>

#import "DWObjectPropertyDescription_Private.h"

@implementation NSObject (DWToolbox)

- (NSDictionary *)propertyDescriptions {
	
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	
	unsigned int outCount, i;
	objc_property_t *propertiesList = class_copyPropertyList([self class], &outCount);
	for (i = 0; i < outCount; i++) {
		objc_property_t property = propertiesList[i];
		
		DWObjectPropertyDescription *description = [[DWObjectPropertyDescription alloc] initWithObjc_Property:property];
		if (description) {
			description.object = self;
			[properties setObject:description forKey:description.name];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:properties];
}

- (NSArray *)properties {
	return [[self propertyDescriptions] allKeys];
}

- (DWObjectPropertyDescription *)propertyDescriptionForName:(NSString *)name {
	NSDictionary *descriptions = [self propertyDescriptions];
	for (NSString *propertyName in descriptions) {
		DWObjectPropertyDescription *description = [descriptions objectForKey:propertyName];
		if ([propertyName isEqualToString:name]) {
			return description;
		}
	}
	return nil;
}

@end
