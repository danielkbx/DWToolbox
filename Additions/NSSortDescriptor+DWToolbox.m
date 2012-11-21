//
//  NSSortDescriptor+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 21.11.12.
//
//

#import "NSSortDescriptor+DWToolbox.h"

@implementation NSSortDescriptor (DWToolbox)

+ (NSArray *)arrayWithSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending {
	
	static NSMutableDictionary *staticDescriptors = nil;
	if (staticDescriptors == nil) {
		staticDescriptors = [[NSMutableDictionary alloc] init];
	}
	
	NSString *staticKey = [NSString stringWithFormat:@"%@-%@",key, (ascending) ? @"a" : @"d"];
	
	NSArray *descriptors = [staticDescriptors objectForKey:staticKey];
	if (descriptors == nil) {
		
		NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending];
		descriptors = [NSArray arrayWithObject:descriptor];
		[staticDescriptors setObject:descriptors forKey:staticKey];
		
	}
	return descriptors;
}

@end
