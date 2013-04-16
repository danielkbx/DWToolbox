//
//  NSURL+DWToolbox.m
//  DWToolbox
//
//  Created by Daniel Wetzel on 15.04.13.
//
//

#import "NSURL+DWToolbox.h"

@implementation NSURL (DWToolbox)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if ([queryString length] > 2) {
				
		NSString *URLString = [self absoluteString];
		if ([self.absoluteString rangeOfString:@"?"].location == NSNotFound) {
			URLString = [URLString stringByAppendingFormat:@"?%@", queryString];
		} else {
			URLString = [URLString stringByAppendingFormat:@"&%@", queryString];
		}
		
		return [NSURL URLWithString:URLString];
	}
    return self;
}

@end
