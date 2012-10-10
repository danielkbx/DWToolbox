//
//  NSString+Additions.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 10.10.12.
//
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEmailAddress {
	
	static NSPredicate * mailPredicate= nil;
	if (mailPredicate == nil) {
		mailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
	}
    return [mailPredicate evaluateWithObject:self];
}

@end
