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

@end
