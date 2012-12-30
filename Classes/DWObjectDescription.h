//
//  DWTreeNodeObjectDescription.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 13.12.12.
//
//

#import <Foundation/Foundation.h>
#import "DWObjectPropertyDescription.h"

@interface DWObjectDescription : NSObject

@property (nonatomic, strong) NSString *treeNodePath;
@property (nonatomic, strong) Class objectClass;

@property (nonatomic, strong, readonly) NSDictionary *propertyDescriptions;

- (id)initWithTreeNodePath:(NSString *)path class:(Class)class;

- (void)addPropertyDescription:(DWObjectPropertyDescription *)description;
- (DWObjectPropertyDescription *)propertyDescriptionForName:(NSString *)name;
- (DWObjectPropertyDescription *)propertyDescriptionForPath:(NSString *)path;

@end
