//
//  NSBundle+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import "NSBundle+DWToolbox.h"

@implementation NSBundle (DWToolbox)

+ (NSBundle *)bundleNamed:(NSString *)name {
	
	static NSMutableDictionary *loadedBundles = nil;
	if (loadedBundles == nil) {
		loadedBundles = [[NSMutableDictionary alloc] init];
	}
	
	id loadedBundle = [loadedBundles objectForKey:name];
	
	if (loadedBundle == nil) {
		loadedBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:name withExtension:@"bundle"]];
		if (loadedBundle) {
			[loadedBundles setObject:loadedBundle forKey:name];
		} else {
			[loadedBundles setObject:[NSNull null] forKey:name];
		}
	}
	
	if ([loadedBundle isKindOfClass:[NSBundle class]]) {
		return loadedBundle;
	} else {
		return nil;
	}
}

@end
