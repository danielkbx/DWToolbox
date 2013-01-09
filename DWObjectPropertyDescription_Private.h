//
//  DWObjectPropertyDescription_Private.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 16.12.12.
//
//

#import "DWObjectPropertyDescription.h"

@interface DWObjectPropertyDescription ()

@property (nonatomic, weak) id object;

- (id)value;
- (BOOL)assignValue:(id)value;

@end
