//
//  DWTreeNodeObjectDescription.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import "DWObjectDescription.h"

@interface DWObjectDescription () {
	
	NSMutableDictionary *_propertyDescriptions;
	
}

@end

@implementation DWObjectDescription

@synthesize propertyDescriptions = _propertyDescriptions;

- (id)initWithTreeNodePath:(NSString *)path class:(Class)class {
	if ((self = [super init])) {
		self.treeNodePath = path;
		self.objectClass = class;
		self->_propertyDescriptions = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)addPropertyDescription:(DWObjectPropertyDescription *)description {
	if (description.name && description.path) {
		[self->_propertyDescriptions setObject:description forKey:description.path];
	}
}

- (DWObjectPropertyDescription *)propertyDescriptionForName:(NSString *)name {
	for (DWObjectPropertyDescription *property in self->_propertyDescriptions) {
		if ([property.name isEqualToString:name]) {
			return property;
			break;
		}
	}
	return nil;
}

- (DWObjectPropertyDescription *)propertyDescriptionForPath:(NSString *)path {
	return [self->_propertyDescriptions objectForKey:path];
}


@end
