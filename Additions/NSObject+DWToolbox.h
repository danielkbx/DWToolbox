//
//  NSObject+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.11.12.
//
//

#import <Foundation/Foundation.h>

#import "NSString+DWToolbox.h"
#import "DWObjectPropertyDescription.h"
#import "DWTreeNode.h"

@interface NSObject (DWToolbox)

- (NSArray *)properties;	// returns an array of strings
- (DWObjectPropertyDescription *)propertyDescriptionForName:(NSString *)name;

@end
