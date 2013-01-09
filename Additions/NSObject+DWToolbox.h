//
//  NSObject+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.11.12.
//
//

#import <Foundation/Foundation.h>

#import "DWObjectPropertyDescription.h"

@interface NSObject (DWToolbox)

- (NSArray *)properties;				// returns an array of strings (the names of the properties)
- (NSDictionary *)propertyDescriptions;	// returns the names as keys, DWObjectPropertyDescription objects as values
- (DWObjectPropertyDescription *)propertyDescriptionForName:(NSString *)name;

@end
