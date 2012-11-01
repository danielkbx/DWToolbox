//
//  UIDevice+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 19.07.12.
//
//

#import "UIDevice+Additions.h"

@implementation UIDevice (Additions)

- (BOOL)isIPad
{
	return (self.userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

- (BOOL)hasRetinaDisplay {
	UIScreen *mainScreen = [UIScreen mainScreen];
	return [mainScreen respondsToSelector:@selector(displayLinkWithTarget:selector:)] && (mainScreen.scale == 2.0);
}

- (BOOL)hasRetina4Display {
	UIScreen *mainScreen = [UIScreen mainScreen];
	return (self.hasRetinaDisplay && mainScreen.bounds.size.height > 480.0f);
}

@end
