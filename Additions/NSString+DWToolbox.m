//
//  NSString+Additions.m
//  dwToolbox
//
//  Created by Daniel Wetzel on 10.10.12.
//
//

#import "NSString+DWToolbox.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (DWToolbox)

- (BOOL)isEmailAddress {
	
	static NSPredicate * mailPredicate= nil;
	if (mailPredicate == nil) {
		mailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
	}
    return [mailPredicate evaluateWithObject:self];
}

- (NSString *)MD5 {

	const char *utf8Self = [self UTF8String];
	unsigned char MD5Buffer[CC_MD5_DIGEST_LENGTH];
	
	CC_MD5(utf8Self, strlen(utf8Self), MD5Buffer);
	
	NSMutableString *MD5String = [NSMutableString stringWithCapacity:2*CC_MD5_DIGEST_LENGTH];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[MD5String appendFormat:@"%02x",MD5Buffer[i]];
	}
	
	return [NSString stringWithString:MD5String];
}

#pragma mark - DWURLConnection

- (NSString *)POSTValueRepresentation {
	return self;
}

@end
