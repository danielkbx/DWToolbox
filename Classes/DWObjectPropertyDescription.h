//
//  DWObjectPropertyDescription.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.12.12.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef enum {
	DWPropertyAccessModeReadonly,
	DWPropertyAccessModeAssign,
	DWPropertyAccessModeRetain,
	DWPropertyAccessModeCopy,
	DWPropertyAccessModeWeak,
} DWPropertyAccessMode;

@interface DWObjectPropertyDescription : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign, readonly) NSString *typeString;
@property (nonatomic, assign, readonly) DWPropertyAccessMode accessMode;
@property (nonatomic, strong, readonly) NSString *backingVariableName;
@property (nonatomic, assign, readonly) BOOL atomic;
@property (nonatomic, assign, readonly) BOOL dynamic;


@property (nonatomic, readonly) BOOL isObjectProperty;

- (id)initWithObjc_Property:(objc_property_t)property;


@end