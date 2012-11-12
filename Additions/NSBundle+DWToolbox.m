//
//  NSBundle+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 12.11.12.
//
//

#import "NSBundle+DWToolbox.h"

@implementation NSBundle (DWToolbox)

+ (NSBundle *)toolboxAssetsBundle {
    static NSBundle *toolboxBundle = nil;
	if (toolboxBundle == nil) {
        toolboxBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"DWToolbox Assets" withExtension:@"bundle"]];
	}
    return toolboxBundle;
}

@end
