//
//  NSSortDescriptor+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 21.11.12.
//
//

#import <Foundation/Foundation.h>

@interface NSSortDescriptor (DWToolbox)

+ (NSArray *)arrayWithSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending;

@end
