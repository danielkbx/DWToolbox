//
//  UIColor+Additions.h
//  dwToolbox
//
//  Created by Daniel Wetzel on 28.08.13.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (DWToolbox)

- (NSString*)stringFromDateWithStyle:(NSDateFormatterStyle)style localeIdentifier:(NSString*)localeIdent;
- (NSString*)stringFromDateWithLongStyle;
- (NSString*)stringFromDateWithFullStyle;

- (NSDate *)noon;
- (NSDate *)midnight;

+ (NSDate *)today;
+ (NSDate *)yesterday;
+ (NSDate *)tomorrow;

+ (NSDate *)dayBeforeDay:(NSDate *)day;
+ (NSDate *)dayAfterDay:(NSDate *)day;

- (BOOL)isBeforeDate:(NSDate *)otherDate;
- (BOOL)isAfterDate:(NSDate *)otherDate;
- (BOOL)isPast;
- (BOOL)isToday;
- (BOOL)isFuture;
- (BOOL)isEqualToTheDay:(NSDate*)date;

- (NSString *)relativeTimeText;

@end
