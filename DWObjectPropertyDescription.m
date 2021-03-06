 //
//  DWObjectPropertyDescription.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 14.12.12.
//
//

#import "DWObjectPropertyDescription.h"
#import "DWObjectPropertyDescription_Private.h"

#import "NSObject+DWToolbox.h"
#import <CoreLocation/CoreLocation.h>

@interface DWObjectPropertyDescription ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite) NSString *typeString;
@property (nonatomic, assign, readwrite) DWPropertyTypeType typeType;
@property (nonatomic, assign, readwrite) DWPropertyAccessMode accessMode;
@property (nonatomic, strong, readwrite) NSString *backingVariableName;
@property (nonatomic, assign, readwrite) BOOL atomic;
@property (nonatomic, assign, readwrite) BOOL dynamic;

@end

@implementation DWObjectPropertyDescription

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@[%@]",[super description], self.name, self.typeString];
}

- (id)initWithObjc_Property:(objc_property_t)property {
	if ((self = [super init])) {
		self.name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
		NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
		
		NSArray *attributes = [propertyAttributes componentsSeparatedByString:@","];
		if (attributes.count >= 2) {
			
			NSString *typeString = attributes[0];
			if ([typeString hasPrefix:@"T"]) {
				typeString = [typeString substringFromIndex:1];
			}
			
			if ([typeString hasPrefix:@"@"]) {
				
				self.typeType = DWPropertyTypeObject;
				NSCharacterSet *typeTrimCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"@\""];
				typeString = [typeString stringByTrimmingCharactersInSet:typeTrimCharacterSet];
				if (typeString.length == 0) {
					typeString = @"id";
				}
				
			} else if ([typeString hasPrefix:@"{"]) {
				typeString = [typeString substringFromIndex:1];
				typeString = [typeString substringToIndex:[typeString rangeOfString:@"="].location];
				self.typeType = DWPropertyTypeValueBacked;
			} else if (typeString.length == 1) {
				self.typeType = DWPropertyTypeNumberBacked;
			}
			
						
			self.typeString = typeString;

			
			NSString *backingVariableString = [attributes lastObject];
			if ([backingVariableString hasPrefix:@"V"]) {
				backingVariableString = [backingVariableString substringFromIndex:1];
			}
			if (backingVariableString.length > 0) {
				self.backingVariableName = backingVariableString;
			}
			
			self.accessMode = (self.typeType == DWPropertyTypeObject) ? DWPropertyAccessModeRetain : DWPropertyAccessModeAssign;
			self.atomic = YES;
			self.dynamic = NO;
			if (attributes.count > 2) {
				for (int i = 1; i < attributes.count - 1; i++) {
					NSString *attribute = [attributes objectAtIndex:i];
					if ([attribute isEqualToString:@"R"]) {
						self.accessMode = DWPropertyAccessModeReadonly;
					} else if ([attribute isEqualToString:@"C"]) {
						self.accessMode = DWPropertyAccessModeCopy;
					} else if ([attribute isEqualToString:@"&"]) {
						self.accessMode = DWPropertyAccessModeRetain;
					} else if ([attribute isEqualToString:@"W"]) {
						self.accessMode = DWPropertyAccessModeWeak;
					} else if ([attribute isEqualToString:@"N"]) {
						self.atomic = NO;
					} else if ([attribute isEqualToString:@"D"]) {
						self.dynamic = YES;
					}
				}
			}
			
		} else {
			self = nil;
		}
		
		
	}
	return self;
}

- (BOOL)assignValue:(id)value {
	BOOL success = NO;
	if (self.object) {
		if (self.typeType == DWPropertyTypeObject) {
			Class targetClass = NSClassFromString(self.typeString);
			if ([value isKindOfClass:targetClass]) {
				[self.object setValue:value forKey:self.name];
				success = YES;
			}
		} else {
			if ([value isKindOfClass:[NSNumber class]]) {
				NSCharacterSet *numberEncodings = [NSCharacterSet characterSetWithCharactersInString:@"islqCISLQfdB"];
				if ([self.typeString rangeOfCharacterFromSet:numberEncodings].location != NSNotFound) {
					[self.object setValue:value forKey:self.name];
					success = YES;
				}
			}
		}
}
return success;
}

- (id)value {
	return [self.object valueForKey:self.name];
}

@end