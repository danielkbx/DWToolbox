//
//  NSDateFormatter+DWToolbox.h
//  DWToolbox
//
//  Created by Daniel Wetzel on 16.11.12.
//
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (DWToolbox)

/*
 Both methods return always the same instance when passing the same style parameters.
 Therefore, you do not need to use static (or class) variables.
 */
+ (NSDateFormatter *)dateFormatterWithStyle:(NSDateFormatterStyle)style;
+ (NSDateFormatter *)dateFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

+ (NSDateFormatter *)relativeDateFormatter;

@end
