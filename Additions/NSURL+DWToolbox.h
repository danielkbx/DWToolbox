//
//  NSURL+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 15.04.13.
//
//

#import <Foundation/Foundation.h>

@interface NSURL (DWToolbox)

- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;

@end
